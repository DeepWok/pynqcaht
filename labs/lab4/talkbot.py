import pvporcupine
import pyaudio
import struct
import speech_recognition as sr
import pyttsx3
import numpy as np
import time
import config

def initialize_porcupine():
    return pvporcupine.create(access_key=config.PORCUPINE_ACCESS_KEY, keywords=["hey google"])

def is_silent(audio_data, threshold=500, ambient_level=None):
    amplitude = np.max(np.abs(np.frombuffer(audio_data, dtype=np.int16)))
    if ambient_level is None:
        return amplitude < threshold
    return amplitude < max(threshold, ambient_level * 1.2)

def get_ambient_noise_level(audio_stream, porcupine, duration=1):
    print("Measuring ambient noise level...")
    frames = []
    start_time = time.time()
    while time.time() - start_time < duration:
        pcm = audio_stream.read(porcupine.frame_length)
        frames.append(np.frombuffer(pcm, dtype=np.int16))
    ambient_level = np.max(np.abs(np.concatenate(frames)))
    print(f"Ambient noise level: {ambient_level}")
    return ambient_level

def start_recording(porcupine, audio_stream, ambient_level):
    recognizer = sr.Recognizer()
    frames = []
    silent_frames = 0
    silent_threshold = 3 * (porcupine.sample_rate // porcupine.frame_length)  # 3 seconds
    start_time = time.time()

    print("Recording... Say 'blueberry' or be silent for 3 seconds to stop.")
    while True:
        pcm = audio_stream.read(porcupine.frame_length)
        frames.append(pcm)

        if is_silent(pcm, ambient_level=ambient_level):
            silent_frames += 1
            print(f"Silent frame detected. Count: {silent_frames}/{silent_threshold}")
            
        else:
            silent_frames = 0
            print("Non-silent frame detected. Resetting silent frame count.")

        if silent_frames >= silent_threshold:
            print("Silence threshold reached. Stopping recording...")
            break

        # Failsafe: stop after 30 seconds regardless of silence
        if time.time() - start_time > 30:
            print("Maximum recording time reached. Stopping recording...")
            break

    total_time = time.time() - start_time
    print(f"Total recording time: {total_time:.2f} seconds")

    audio_data = b''.join(frames)
    audio = sr.AudioData(audio_data, porcupine.sample_rate, 2) # replace audio_data with mp3 file collected from PYNQ board
    try:
        text = recognizer.recognize_google(audio)
        print(f"You said: {text}")
        return text
    except sr.UnknownValueError:
        print("Sorry, I could not understand the audio.")
        return None
    except sr.RequestError as e:
        print(f"Could not request results; {e}")
        return None

def speak(text):
    engine = pyttsx3.init()
    engine.say(text)
    engine.runAndWait()

def main():
    porcupine = initialize_porcupine()
    pa = pyaudio.PyAudio()
    audio_stream = pa.open(
        rate=porcupine.sample_rate,
        channels=1,
        format=pyaudio.paInt16,
        input=True,
        frames_per_buffer=porcupine.frame_length
    )

    ambient_level = get_ambient_noise_level(audio_stream, porcupine)

    try:
        print("Listening for wake words...")
        while True:
            pcm = audio_stream.read(porcupine.frame_length) # Read audio data
            pcm = struct.unpack_from("h" * porcupine.frame_length, pcm)
            keyword_index = porcupine.process(pcm)
            if keyword_index == 0:  # "hey google" wake word
                print("Wake word detected!")
                recognized_text = start_recording(porcupine, audio_stream, ambient_level)
                if recognized_text:
                    response = "I heard you say " + recognized_text
                    speak(response)
    except KeyboardInterrupt:
        print("Stopping...")
    finally:
        audio_stream.stop_stream()
        audio_stream.close()
        pa.terminate()
        porcupine.delete()

if __name__ == "__main__":
    main()