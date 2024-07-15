# Lab Extensions (Optional)

Congratulations if you have reached this part! The labs are pretty long and can be quite challenging for beginners with no experience in FPGA programming. 

If you have completed the labs and are looking for more challenges, here are some optional extensions you can try out:

1. Write your own decimation filter: In these labs, we took advantage of the CIC compiler IP created by Xilinx. Why not write one yourself? Start by understanding decimation and the CIC structure - you can refer to the sources in sections 2.2 and 2.3.

2. Improving decimation: More of a Signals and Systems person? A Finite Impulse Response (FIR) filter can be used as a complementary filter to a decimation filter. It can be used to remove high-frequency components and minimise aliasing, leading to better audio quality after decimation. Try integrating an FIR filter into the audio processing pipeline.

3. Utilising the video module: The board is not limited to audio processing - with the power of PYNQ, you could process videos as well! Now you know how to interface with the BaseOverlay, you can mess around with the video modules and hook up your PYNQ board to a monitor using HDMI.

Note that extensions are open-ended and are not restricted to the suggestions provided above, but should be of (at least) similar complexity. 