# PYNQ-Whisper Chatbot

## Intro

This repository contains the labs for the 2024-2025 Imperial EIE Information Processing module. These labs focuses on introducing the Vivado toolchain and PYNQ ecosystem. 

The core idea of this module is to:
Understand the placement choices and tradeoffs between information processing nodes on the edge (e.g. local FPGA) and remote cloud environments (e.g. AWS).

Tested version: Vivado 2020.2, PYNQ v2.7, Windows 10

## Schedule

There will be 4 lab weeks (2 hours of lab per week). The labs are designed to be completable within the given lab times, though students are expected to spend more time debugging and exploring the module by completing the challenges.

| Week | Lab | Description |
| --- | --- | --- |
| 1 | Lab 1 | Introduction to PYNQ and Vivado |
| 2 | Lab 2 | Audio Processing |
| 3 | Lab 3 | AWS |
| 4 | Lab 4 | Building the chatbot |

### Goal

The goal of these labs is to create an interactive bot which uses the power of Whisper to understand your speech and communicate with you.

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

[Lab 1 - Introduction to PYNQ and Vivado](lab1/lab1.md)

In this lab, you will setup the PYNQ board and Xilinx toolchain, and familiarise yourself with the tools by generting a simple Vivado block design for an FIR filter, and implement it as an overlay in the Jupyter Notebook to witness the power of hardware acceleration.

### Lab 2

[Lab 2 - Audio Processing](lab2/lab2.md)

In this lab, you will explore the audio processing capabilities of the PYNQ board, and implement a software PDM-PCM conversion in Python. You will also design a hardware PDM-PCM conversion in Vivado, and compare the speed of the hardware and software implementations.

### Lab 3

[Lab 3 - AWS](lab3/lab3.md)

<!-- In this lab, you will learn how to connect the PYNQ board to AWS services, and use AWS's provided databases, such as DynamoDB. You will also learn how to make API calls to AWS services, and store the data in the cloud. -->

### Lab 4

[Lab 4 - Building the chatbot](lab4/lab4.md)

In this lab, you will combine the processing powers of PYNQ, Whisper and AWS, to create a chatbot that can understand your speech and communicate with you. You will also connect the chatbot to AWS services by utilising AWS's provided databases, such as DynamoDB. Lastly, you will design and 3D print your chatbot by CAD scripting.

### Coursework

Coursework will be...

