import os
import struct
import math
import numpy
import cffi
import wave
import time
from pynq import PL
from pynq import GPIO
from pynq.uio import get_uio_index
from pynq import DefaultIP

LIB_SEARCH_PATH = os.path.dirname(os.path.realpath(__file__))

class AudioDirect(DefaultIP):

    def __init__(self, description, gpio_name=None): # not changed
        """Return a new Audio object based on the hierarchy description.
        
        Parameters
        ----------
        description : dict
            The hierarchical description of the hierarchy
        gpio_name : str
            The name of the audio path selection GPIO. If None then the GPIO
            pin in the hierarchy is used, otherwise the gpio_name is searched
            in the list of pins on the hierarchy and the PL.gpio_dict.

        """
        super().__init__(description)

        if gpio_name is None:
            if len(self._gpio) == 0:
                raise RuntimeError('Could not find audio path select GPIO.')
            elif len(self._gpio) > 1:
                raise RuntimeError('Multiple possible audio path select GPIO.')
            pin_name = next(iter(self._gpio.keys()))
            self.gpio = getattr(self, pin_name)
        else:
            if gpio_name in self._gpio:
                self.gpio = getattr(self, gpio_name)
            elif gpio_name in PL.gpio_dict:
                pin = GPIO.get_gpio_pin(PL.gpio_dict[gpio_name]['index'])
                self.gpio = GPIO(pin, 'out')
            else:
                raise RuntimeError('Provided gpio_name not found.')

        self._ffi = cffi.FFI()
        self._libaudio = self._ffi.dlopen(LIB_SEARCH_PATH + "/libaudio.so")
        self._ffi.cdef("""unsigned int Xil_Out32(unsigned int Addr, 
                                                 unsigned int Value);""")
        self._ffi.cdef("""unsigned int Xil_In32(unsigned int Addr);""")
        self._ffi.cdef("""void record(unsigned int BaseAddr, 
                                      unsigned int * BufAddr, 
                                      unsigned int Num_Samles_32Bit);""")
        self._ffi.cdef("""void play(unsigned int BaseAddr, 
                                    unsigned int * BufAddr, 
                                    unsigned int Num_Samles_32Bit);""")
        
        char_adrp = self._ffi.from_buffer(self.mmio.array)
        self._uint_adrpv = self._ffi.cast('unsigned int', char_adrp)
        
        self.buffer = numpy.zeros(0).astype(numpy.int)
        self.sample_rate = 0
        self.sample_len = 0

    bindto = ['xilinx.com:user:audio_direct:1.1']

    def record(self, seconds): # changed
        """Record PCM data from audio controller to audio buffer.
        
        The sample rate is 37.5kHz for PCM data given the decimation settings.
        
        Parameters
        ----------
        seconds : float
            The number of seconds to be recorded (must be between 0 and 60).
                
        Returns
        -------
        None
        """
        if not 0 < seconds <= 60:
            raise ValueError("Recording time has to be in (0,60].")

        # Here we use 37.5kHz to match the PCM sampling rate given the decimation settings
        num_samples_32b = math.ceil(seconds * 37500)
        
        # Create data buffer
        self.buffer = numpy.zeros(num_samples_32b, dtype=numpy.int32)
        char_datp = self._ffi.from_buffer(self.buffer)
        uint_datp = self._ffi.cast('unsigned int*', char_datp)
        
        # Record
        start = time.time()
        self._libaudio.record(self._uint_adrpv, uint_datp, num_samples_32b)
        end = time.time()
        print(f"time: {end-start}")
        self.sample_rate = num_samples_32b / (end - start)
        self.sample_len = num_samples_32b
        
    def play(self): # no change
        """Play audio buffer via audio jack.
        
        Returns
        -------
        None
        
        """
        char_datp = self._ffi.from_buffer(self.buffer)
        uint_datp = self._ffi.cast('unsigned int*', char_datp)
        
        self._libaudio.play(self._uint_adrpv, uint_datp, len(self.buffer))
        
    def bypass_start(self): # no change
        """Stream audio controller input directly to output.
        
        Returns
        -------
        None
        
        """
        self.gpio.write(1)

    def bypass_stop(self): # no change
        """Stop streaming input to output directly.
        
        Returns
        -------
        None
        
        """
        self.gpio.write(0)

    def save(self, file): # changed
        """Save audio buffer content to a WAV file.
        
        The recorded file is 32-bit PCM WAV format.
        
        Parameters
        ----------
        file : string
            File name, with a default extension of `wav`.
                
        Returns
        -------
        None
        """
        if self.buffer.dtype.type != numpy.int32:
            raise ValueError("Internal audio buffer should be of type int32.")
        if not isinstance(file, str):
            raise ValueError("File name has to be a string.")
        
        if os.path.isdir(os.path.dirname(file)):
            file_abs = file
        else:
            file_abs = os.getcwd() + '/' + file
            
        # Convert to float for processing
        audio_data = self.buffer.astype(numpy.float32)
        
        # Remove DC offset
        audio_data -= numpy.mean(audio_data)
        
        # Normalize with headroom
        peak_val = numpy.max(numpy.abs(audio_data))
        if peak_val == 0:
            peak_val = 1e-7  # Avoid division by zero
        audio_data /= peak_val
        
        # Scale to int32 range with headroom
        max_int32 = numpy.iinfo(numpy.int32).max
        audio_data *= 0.99 * max_int32
        
        # Convert back to int32
        audio_data = audio_data.astype(numpy.int32)
                
        with wave.open(file_abs, 'wb') as wav_file:
            wav_file.setnchannels(1)  # mono
            wav_file.setsampwidth(4)  # 4 bytes for 32-bit
            wav_file.setframerate(self.sample_rate)
            wav_file.setnframes(self.sample_len)
            wav_file.setcomptype('NONE', "not compressed")
            
            # Write each sample as 32-bit little-endian
            for sample in audio_data:
                wav_file.writeframes(struct.pack('<i', sample))
            
    def load(self, file): # not changed
        """Loads file into internal audio buffer.
        
        The recorded file is of format `*.pdm`.
        
        Note
        ----
        The file will be searched in the specified path, or in the 
        working directory in case the path does not exist.
        
        Parameters
        ----------
        file : string
            File name, with a default extension of `pdm`.
            
        Returns
        -------
        None
        
        """
        if not isinstance(file, str):
            raise ValueError("File name has to be a string.")
            
        if os.path.isdir(os.path.dirname(file)):
            file_abs = file
        else:
            file_abs = os.getcwd() + '/' + file
            
        with wave.open(file_abs, 'rb') as pdm_file:
            temp_buffer = numpy.fromstring(pdm_file.readframes(
                                        pdm_file.getnframes()), dtype='<u2')
            self.sample_rate = pdm_file.getframerate()
            self.sample_len = pdm_file.getnframes()
            self.buffer = temp_buffer.astype(numpy.int32)

    @staticmethod
    def info(file): # erm ignore right now
        """Prints information about the sound files.

        The information includes name, channels, samples, frames, etc.

        Note
        ----
        The file will be searched in the specified path, or in the
        working directory in case the path does not exist.

        Parameters
        ----------
        file : string
            File name, with a default extension of `pdm`.

        Returns
        -------
        None

        """
        if not isinstance(file, str):
            raise ValueError("File name has to be a string.")

        if os.path.isdir(os.path.dirname(file)):
            file_abs = file
        else:
            file_abs = os.getcwd() + '/' + file

        with wave.open(file_abs, 'rb') as sound_file:
            print("File name:          " + file)
            print("Number of channels: " + str(sound_file.getnchannels()))
            print("Sample width:       " + str(sound_file.getsampwidth()))
            print("Sample rate:        " + str(sound_file.getframerate()))
            print("Number of frames:   " + str(sound_file.getnframes()))
            print("Compression type:   " + str(sound_file.getcomptype()))
            print("Compression name:   " + str(sound_file.getcompname()))