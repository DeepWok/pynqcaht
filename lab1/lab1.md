# Lab 1: Introduction to PYNQ and Vivado

## 1.1 Environment setup

### Toolchain versions

To get started with the labs, we will first setup the required toolchain - this might be a bit troublesome, so please take advantage of the debugging notes `debug.md`.

In this lab, we will use the PYNQ-Z1 board, with PYNQ image v2.7, and Vivado version 2020.2. I understand that some of you might have used different versions of Vivado before, but please download this version of Vivado as it is verified to work for a more stable version of the PYNQ image, which is v2.7.

If you encounter any issues, please first refer to the debugging notes `debug.md`, before approaching the TAs or the module leader.

Operating system requirements: Windows 10 or 11, Ubuntu Linux

- This lab was created, tested and verified on a Windows 10 laptop running the above versions of the toolchains.
- If you are using a MacOS device, options include:
  - Virtual machine (VM)
  - Using lab computers

### Vivado

Go to the following 

For limited storage issues, refer to [debug.md](../debug.md).

### PuTTY (optional)

You may have encountered PuTTY before in your work or previous modules - it is a terminal emulator that allows you to connect to a remote server. In this case, we will use PuTTY to SSH into the PYNQ board.

Note that this is not strictly necessary, as you should be able to use the Juputer Notebook interface to directly interact with your PYNQ board. However, PuTTY is useful for troubleshooting in cases where your board refuses to establish a connection.

Download PuTTY from the following link: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

### PYNQ image

Now time for the PYNQ image - 


### Setting up the board

Once you have flashed the PYNQ image onto your SD card, insert it into the PYNQ-Z1 board and connect the power supply. The board should be powered by either a micro-USB cable or a 5V power supply. Remember to switch the pin on the board to either use the USB or power supply.

<-- Insert picture of the pin -->

Let's take a look at how the board manages to run a Jupyter Notebook server. There are two chips you can see on the board, one is the Processing System (PS), one is the Programmable Logic (PL). The PS is responsible for running the Jupyter Notebook server, while the PL is responsible for running the custom hardware designs you will create in Vivado.

<-- Insert picture of the chips -->

### Connecting to Jupyter Notebook

We will now connect to the board's Jupyter Notebook server via Ethernet. Connect the Ethernet cable to the board and your computer. .........

Note that your board does not have internet connection currently......

Now we have to assign a static IP address to the laptop's ethernet port. Open up the `Network and Sharing Center`, and click on the `Ethernet connection`. Click on `Properties`, and then double-click on `Internet Protocol Version 4 (TCP/IPv4)`. Assign the following IP address: `.....

Now, open up your web browser and type in the following address: `192.168.2.99:9090`, which is PYNQ's default IP address. 

> Is your PYNQ board refusing to connect? Refer to the troubleshooting section in [debug.md](../debug.md). Troubleshooting might require the use of PuTTY.

## 1.2 FIR filter

Now we are ready to get started. Open up Vivado and create a new project.

> Credits to [this tutorial](https://www.fpgadeveloper.com/2018/03/how-to-accelerate-a-python-function-with-pynq.html/) by Jeff Johnson for this section. If you get lost in this section, feel free to refer to his YouTube tutorial.

### Creating a new project


### Adding a block design


### Configuring the FIR filter IP


### Block connections


### 


## 1.3 Extension: Creating an overlay with a Verilog module 

This is an optional section which demonstrates how you can package your IPs written in Verilog and use them in your PYNQ overlay. It is recommended that you complete this section if you are not familiar with the Vivado toolchain in general.

https://discuss.pynq.io/t/tutorial-creating-a-new-verilog-module-overlay/1530

### Creating a Verilog module


### Packaging the IP


### Creating the block design


### Exporting the hardware


### MMIO interface in Jupyter Notebook




