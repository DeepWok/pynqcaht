# pynq-whisper

## Intro

This repository contains the labs for the 2024-2025 Imperial EIE Information Processing module. These labs focuses on introducing the Vivado toolchain and PYNQ ecosystem. 

The core idea of this module is to:
Understand the placement choices and tradeoffs between information processing nodes in the edge (e.g. local FPGA) and remote cloud environments (e.g. AWS).

Tested version: Vivado 2020.2, PYNQ v2.7

## Schedule

There will be 4 lab weeks (2 hours of lab per week). The labs are designed to be completable within the given lab times, though students are expected to spend more time debugging and exploring the module by completing the challenges.  

### Goal

The goal of these labs is to create a interactive bot which uses the power of Whisper to understand your speech and communicate with you.

Whisper is a...

A general idea of the steps you will take:
1. Setup the PYNQ board and go through a simple FIR filter tutorial to understand the PYNQ-Vivado ecosystem.
2. Learn to utilise the audio modules on the PYNQ board.
3. Create a hardware design in Vivado which converts the PDM formatted audio into PCM format, and compare and contrast the speed with a software implementation.
4. Process the audio file with a chain of API calls to Whisper (ASR), OpenAI, and a cloud/local TTS service, then output the audio through the PYNQ board's audio jack.
5. Connect the talkbot to AWS services by utilising AWS's provided databases, such as DynamoDB.

Note: The lab is designed for Zynq-based boards with onboard MEMS microphones, such as the PYNQ-Z1, which record input in PDM format. For digital processing, the audio has to be converted into PCM before wrapping into a standardised format, such as a .wav file.

### Terminology

- PDM: Pulse-density modulation
- PCM: Pulse-code modulation
- WAV: Waveform Audio File Format
- ASR: Automatic speech recognition
- TTS: Text-to-speech
- CSV: Comma-separated values
- API: Application programming interface


### Lab 1

[Link to lab 1 md file]

In this lab, you will setup the PYNQ board and Xilinx toolchain, and familiarise yourself with the tools by generting a simple Vivado block design for an FIR filter, and implement it as an overlay in the Jupyter Notebook.


### Lab 2

[Link to lab 2 md file]


### Lab 3

[Link to lab 3 md file]


### Coursework


