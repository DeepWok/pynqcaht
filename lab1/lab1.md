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

### Step 1: Install Vivado

Go to the following [page](https://www.xilinx.com/support/download.html) to download Vivado. For limited storage issues, refer to [debug.md](../debug.md/#limited-storage-space).

### Step 2: Flashing the PYNQ image

Download the [Pynq SD Card Image](https://www.pynq.io/boards.html) onto the Pynq SD Card. You can use [Raspberry Pi Imager](https://www.raspberrypi.com/software/) to write the image.

### Step 3: Setting up the board

Once you have flashed the PYNQ image onto your SD card, insert it into the PYNQ-Z1 board and connect the power supply. The board should be powered by either a micro-USB cable or a 5V power supply. Remember to switch the pin on the board to either use the USB or power supply.

![[../images/power_options_on_pynq_z1.jpg]]

Let us now look into how the board works. The most important component is the Zynq-7000 System-On-Chip (SoC), which contains the Processing System (PS) made up of an ARM-Cortex A9 core, as well as the Programmable Logic (PL) which can be configured with custom hardware designs that we will soon create in Vivado. The block diagram for the Zynq-7000 SoC is shown below: <-- TODO: check permissions? -->

![[../images/Zynq-7000SBlockDiagram.jpg]]
(Source: https://www.mouser.co.uk/new/xilinx/xilinx-zynq-7000-socs/)

On top of this, the PYNQ framework provides a full Ubuntu-based Linux distribution on the SD card, with Linux drivers for the interfaces between the PS and PL, wrapped in Python libraries which makes the design easier. The following excerpt from Xilinx's introduction to PYNQ gives an excellent visual representation of the overall systems you will be working with:

| ![[../images/pynq-workshop-slide-9.png]]  |
| ----------------------------------------- |
| ![[../images/pynq-workshop-slide-10.png]] |
| ![[../images/pynq-workshop-slide-12.png]] |
(Source: https://github.com/Xilinx/PYNQ_Workshop/blob/master/01_PYNQ_Workshop_introduction.pdf)

### Step 4: Connecting to Jupyter Notebook

By default, PYNQ uses a web interface to interact with the FPGA board. We will now connect to the board's Jupyter Notebook server via Ethernet. Connect the Ethernet cable to the board and your computer. If your computer does not have an Ethernet port, you can use an Ethernet adapter.

> Note: if you connect Ethernet directly to your computer, PYNQ will not have access to the internet unless you bridge your computers internet connection. This means you will not be able to update system packages.

#### Assigning a Static IP:

PYNQ by default uses a static IP address of `192.168.2.99`. You should configure your laptop to also have an IP address **on the same subnet as the PYNQ-Z1 board** to be able to access the Jupyter Notebook server. You can refer back to the Network Layer lectures in the Software Systems module a deeper understanding.

__Windows__
Open up the `Network and Sharing Center`, and click on the `Ethernet connection`. Click on `Properties`, and then double-click on `Internet Protocol Version 4 (TCP/IPv4)`. Assign the following IP address: `192.168.2.x` where x is any number between 0 and 255, other than 99. 

__Linux__
Modify `/etc/network/interfaces` Ethernet interface:
```
iface eth0 inet static
   address 192.168.2.1
   netmask 255.255.255.0
```

See the PYNQ documentation: https://pynq.readthedocs.io/en/latest/appendix/assign_a_static_ip.html#assign-a-static-ip-address

#### Open Notebook in browser

Now, open up your web browser and type in the following address: `192.168.2.99:9090`, which is PYNQ's default IP address. The default password is `xilinx`

> Is your PYNQ board refusing to connect? Refer to the troubleshooting section in [debug.md](../debug.md/#refusing-to-connect). Troubleshooting might require the use of PuTTY.

### PuTTY (optional)

You may have encountered PuTTY before in your work or previous modules - it is a terminal emulator that allows you to connect to a remote server. In this case, we will use PuTTY to SSH into the PYNQ board.

Note that this is not strictly necessary, as you should be able to use the Juputer Notebook interface to directly interact with your PYNQ board. However, PuTTY is useful for troubleshooting in cases where your board refuses to establish a connection.

Download PuTTY from the following link: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

## 1.2 FIR filter

Now we are ready to get started. Open up Vivado and create a new project.

> Credits to [this tutorial](https://www.fpgadeveloper.com/2018/03/how-to-accelerate-a-python-function-with-pynq.html/) by Jeff Johnson for this section. If you get lost in this section, feel free to refer to his YouTube tutorial.

### Creating a new project

Open up Vivado and create a new project. 

//! Picture for starting page


//! Picture for project naming


//! Board part

> Board part troubleshooting: If you are unable to find the PYNQ-Z1 board part (xc7z020-1clg400c), refer to the troubleshooting section in [debug.md](../debug.md/#board-parts-not-found).

### Creating the block design

On the column on the left hand side, click `Create Block Design`. You can leave the block design name as `design_1` for now.

//! Picture for block design

//! Picture for adding IP

//! Picture for adding ZYNQ7 Processing System (HP slave port)

//! Picture for adding DMA

//! Picture for adding FIR_filter

//! Picture for running block automation

### Exporting the hardware


### Loading the overlay on Jupyter Notebook






