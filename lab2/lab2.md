# Lab 2: Audio Processing

## 2.1 Exploring the BaseOverlay

In this section, we will do a brief exploration of the BaseOverlay and understand its usecase in the upcoming parts of the lab.

## 2.2 Audio Processing (Software)

In this section, we will learn how to utilise the BaseOverlay and implement some basic audio processing in software.

In order to make a Whisper API call, we need to send the audio in a format that is accepted by Whisper. Unfortunately, the PYNQ-Z1 board's onboard microphone is a MEMS (Micro-Electro-Mechanical Systems) microphone, which usually records in PDM (pulse density modulation) format.

A brief overview of the format types:
- PDM (pulse density modulation) -> Record: MEMS microphones use PDM because it offers a straightforward, noise-immune digital output that is compact and cost-effective.
- PCM (pulse code modulation) -> Storage: PCM is the standard for digital audio because it aligns well with digital processing, maintains audio quality, and serves as the basis for compression formats.
- PWM (pulse width modulation) -> Playback : PWM is used for audio playback because it efficiently drives output devices, simplifies DAC implementation, and is power-efficient.

Please go ahead and explore the characteristics and details of these different formats, where you should find familiar information related to your Signals and Systems / Communications modules. 

The BaseOverlay provides you with PDM to PWM conversions to allow for playback from the audio buffer, as demonstrated in section 2.1. But to utilise Whisper, we need to convert the recorded PDM files into PCM, which can then be wrapped as a common audio file format such as `.wav` or `.mp3`, before making an API call. 

Let's start by...


Here, we implement a software PDM-PCM conversion in Python...

https://tomverbeure.github.io/2020/09/30/Moving-Average-and-CIC-Filters.html
https://www.youtube.com/watch?v=8RbUSaZ9RGY
https://docs.amd.com/v/u/en-US/pg140-cic-compiler 

## 2.3 Audio Processing (Hardware)

Brace yourselves, this will be the longest section of the labs, where you will get to understand how exactly the PYNQ acts as a "embedded Python wrapper" which allows you to interact with your block design's components. Here we will take more of a embedded systems approach and modify both the BaseOverlay and also learn to write your own drivers to interact with those components. The end goal is to create a hardware-based solution to accelerate the pdm-to-pcm conversion.

Let's start by understanding the audio module in the BaseOverlay. Click open <expand the IP>.

Here we see the audio module's internal hierarchy - under the IP, there is a `base_audio_direct.sv` file, which contains an `audio_direct_v1_1.sv` file. The `audio_direct_v1_1.sv` is the actual IP that was developed by the PYNQ / Digilent teams, while the `base_audio_direct.sv` file is auto-generated when you add your IP to your block design and interface it with other components. 

Under the `audio_direct` IP, we see two different hierarchies - one named the `d_axi_pdm_v1_2_S_AXI.vhd`, the other named `audio_direct_path.sv`. By looking at the HDL code and [Python drivers](https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/audio.py), you would discover that `audio_direct_path` allows for an audio bypass, where the input to the PDM microphone is directly streamed to the PWM output. 

But remember that in section 2.1, you were also able to record to an audio buffer and save the audio data from the buffer? How exactly is the buffer built? 

That's where the `d_axi_pdm_v1_2_S_AXI` module comes in. The `vhdl` might seem confusing, but essentially it just instantiates a FIFO that can be controlled through certain register offsets in the drivers. Let's examine this more carefully:

Inside the ... file, we see <show the code that gives the regsiter offsets>

To use these control registers, PYNQ has written [C++ audio driver](https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/_pynq/_audio/audio_direct.cpp#L59) which writes values to these register offsets to control the behaviour of the FIFO (which is basically what you would do in embedded development). You can match the register offsets in the `vhdl` file with the audio controller registers in the [header file of the C++ audio driver](https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/_pynq/_audio/audio_direct.h). 

So how does the Python audio driver use the C++ functions? Notice the use of `cffi` in Python? This stands for "C Foreign Function Interface", an [interface in Python used for calling C code](https://pypi.org/project/cffi/). The low-level operations written in C++ above get compiled into a shared libary file `libaudio.so`. Python then loads this file:

```python
self._libaudio = self._ffi.dlopen(LIB_SEARCH_PATH + "/libaudio.so")
```

which is compiled from the C++ audio drivers using CMake. Usually, embedded developers simply interface with the hardware by directly writing C drivers - PYNQ was created to lower the boundary of FPGA development by pre-writing most drivers and wrapping them in C++.

Now let's do the hardware programming!

### Step 1: Creating the block design


### Step 2: 


