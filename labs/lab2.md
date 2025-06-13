# Lab 2: Audio Processing

## 2.1 Introduction

In this section, we will utilise the microphone input and audio output on the PYNQ-Z1 board, and setup audio processing capabilities for future sections. We first explore the Base Overlay design provided by the PYNQ team.

Quoting the PYNQ documentation:
> The purpose of the base overlay design is to allow PYNQ to use peripherals on a board out-of-the-box. The design includes hardware IP to control peripherals on the target board, and connects these IP blocks to the Zynq PS. If a base overlay is available for a board, peripherals can be used from the Python environment immediately after the system boots.

For further information, please read: https://pynq.readthedocs.io/en/latest/pynq_overlays/pynqz1/pynqz1_base_overlay.html

As the BaseOverlay is incredibly large, please use the file `something` in the current directory for the next few sections for faster synthesis and bitstream generation. This file contains a slimmed-down version of the original BaseOverlay, where only support for audio processing remains.

## 2.2 Audio Processing (Software)

In this section, we will learn how to utilise the BaseOverlay and implement some basic audio processing in software.

In order to make a Whisper API call, we need to send the audio in a format that is accepted by Whisper. Unfortunately, the PYNQ-Z1 board's onboard microphone is a MEMS (Micro-Electro-Mechanical Systems) microphone, which records in PDM (pulse density modulation) format.

A brief overview of the format types:
| Format | Use Case | Description |
|--------|----------|-------------|
| **PDM** (Pulse Density Modulation) | Recording | MEMS microphones use PDM because it offers a straightforward, noise-immune digital output that is compact and cost-effective. |
| **PCM** (Pulse Code Modulation) | Storage | PCM is the standard for digital audio because it aligns well with digital processing, maintains audio quality, and serves as the basis for compression formats. |
| **PWM** (Pulse Width Modulation) | Playback | PWM is used for audio playback because it efficiently drives output devices, simplifies DAC implementation, and is power-efficient. |

Please go ahead and explore the characteristics and details of these different formats, where you should find familiar information related to your Signals and Systems / Communications modules.

The BaseOverlay provides you with PDM to PWM conversions to allow for playback from the audio buffer, as demonstrated in section 2.1. But to utilise Whisper, we need to convert the recorded PDM files into PCM, which can then be wrapped as a common audio file format such as `.wav` or `.mp3`, before making an API call.

Let's start by implementing a software PDM-PCM conversion function in Python.

### Task 2A: Software PDM-PCM conversion function

Need something here lol

https://github.com/Xilinx/PYNQ/blob/master/boards/Pynq-Z1/base/notebooks/audio/audio_playback.ipynb

## 2.3 Audio Processing (Hardware)

In this section you will get to understand how exactly the PYNQ acts as a "embedded Python wrapper" which allows you to interact with your block design's components. Here we will take more of a embedded systems approach and modify both the BaseOverlay and also learn how drivers interact with those components. The end goal is to create a hardware-based solution to accelerate the PDM-to-PCM conversion.

Let's start by understanding the audio module in the BaseOverlay. Click open `<expand the IP>`.

[Pic of audio module outer layer]

[Pic of the files under the hood]

Here we see the audio module's internal hierarchy - under the IP, there is a `base_audio_direct.sv` file, which contains an `audio_direct_v1_1.sv` file. The `audio_direct_v1_1.sv` is the actual IP that was developed by the PYNQ / Digilent teams, while the `base_audio_direct.sv` file is auto-generated when you add your IP to your block design and interface it with other components.

Under the `audio_direct` IP, we see two different hierarchies - one named the `d_axi_pdm_v1_2_S_AXI.vhd`, the other named `audio_direct_path.sv`. By looking at the HDL code and Python driver [`audio.py`](https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/audio.py), you would discover that `audio_direct_path` allows for an audio bypass, where the input to the PDM microphone is directly streamed to the PWM output.

But remember that in section 2.1, you were also able to record to an audio buffer and save the audio data from the buffer? How exactly is the buffer built?

That's where the `d_axi_pdm_v1_2_S_AXI` module comes in. The `vhdl` might seem confusing, but essentially it just instantiates a FIFO that can be controlled through certain register offsets in the drivers. This can be done by instantiating an `AXI4 Peripheral`. Let's examine this more carefully:

Inside the ... file, we see [show the code that gives the regsiter offsets]

To use these control registers, PYNQ has written [C++ audio driver](https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/_pynq/_audio/audio_direct.cpp#L59) which writes values to these register offsets to control the behaviour of the FIFO (which is basically what you would do in embedded development). You can match the register offsets in the `vhdl` file with the audio controller registers in the [header file of the C++ audio driver](https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/_pynq/_audio/audio_direct.h).

So how does the Python audio driver use the C++ functions? Notice the use of `cffi` in Python? This stands for "C Foreign Function Interface", an [interface in Python used for calling C code](https://pypi.org/project/cffi/). The low-level operations written in C++ above get compiled into a shared libary file `libaudio.so`. Python then loads this file:

```python
self._libaudio = self._ffi.dlopen(LIB_SEARCH_PATH + "/libaudio.so")
```

which is compiled from the C++ audio drivers using CMake. Usually, embedded developers simply interface with the hardware by directly writing C drivers - PYNQ was created to lower the boundary of FPGA embedded development by pre-writing most drivers and wrapping them in C++.

Now let's do the hardware programming!

### Task 2B: Creating an audio frontend (PDM-to-PCM converter)

First, we need something in hardware which mirrors the PDM-to-PCM functions written in Python. Here we will use Xilinx's CIC Compiler IP, specifically its decimation filter.

Decimation reduces the sampling rate by keeping only every Nth sample while applying anti-aliasing filtering. CIC filters are ideal for this PDM-to-PCM conversion as they efficiently decimate the high-frequency PDM bitstream (often several MHz) down to standard audio sampling rates (e.g., 44.1 kHz) without requiring multipliers.

Useful references:
- [Moving Average and CIC Filters](https://tomverbeure.github.io/2020/09/30/Moving-Average-and-CIC-Filters.html)
- [CIC Filters Explained (YouTube)](https://www.youtube.com/watch?v=8RbUSaZ9RGY)
- [CIC Compiler Documentation - AMD](https://docs.amd.com/v/u/en-US/pg140-cic-compiler)

[Add a diagram showing we will add an audio frontend in front of the audio ip]

... instructions here on how to add the CIC compiler and create this audio frontend IP ...


### Task 2C: Connect audio frontend to BaseOverlay audio modules




### Task 2D: Modifying the drivers

Next, we modify the Python drivers, as the drivers should now expect PCM data instead of PDM data. The theory is quite similar to the array merging drivers in Lab 1.

> Please first read the `driver_instructions.md` in the `pcm_driver` folder.

Before you follow the instructions and copy the new `audio.py`, let's understand what is happening in all of the files. As mentioned in the driver instructions files, a test/debug C++ driver was created for PCM. This did not exist in the original PYNQ codebase. The following link takes you to the original PYNQ C++ driver:

https://github.com/Xilinx/PYNQ/blob/master/pynq/lib/_pynq/_audio/audio_direct.cpp

Let's take a look at how the test/debug C++ driver works. Firstly, the register offsets relative to the base address of the AXI4 peripheral is defined as constants, as well as the transmit and receive FIFO flags. Secondly, we define two inline functions `Read32` and `Write32`, which allows us to read and write to these registers to control the AXI4 peripheral. Thirdly, we have the driver functions such as `record`, which controls the AXI4 peripheral to record and save the receiving FIFO data into our statically-allocated buffer.

The C++ drivers which you interact with in the PYNQ codebase (under `pynq/lib/_pynq/_audio`) does basically the same thing, except rather than creating a static buffer in C++, it relies on a buffer created in the `audio.py` Python driver.

Now let's take a look at the `new_audio.py`. For an easier diff, the functions are marked either `not changed` or `changed`, in comparison to PYNQ's original Python driver. As you should know from the `merge array` example in Lab 1, the Makefile first compiles the C++ drivers into a `libaudio.so` shared library file, which is then loaded by Python using the CFFI (C Foreign Function Interface). Main changes were made to the `record` and `save` functions, where the expected buffer data sampling rate and audio saving file type has been changed.

> Fun fact: I had some troubles debugging the specific sampling rate number to be used in the Python `record` function. Read `sample-rate.txt` for a fuller explanation.

> To make it clear, do not use the C++ or Makefile in the `pcm_driver` folder - read the insturctions in the markdown file and only use the contents from the `new_audio.py`.

### Task 2E: Interacting with the drivers in Jupyter Notebook

After following the driver instructions, now let's interact with them in Jupyter Notebook.

