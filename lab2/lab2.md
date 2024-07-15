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



