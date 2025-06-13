# TLDR for drivers

No modifications are needed to the `audio_direct.cpp` and the `audio_direct.h` original driver files developed by the PYNQ team, since the FIFO control is basically the same.

The difference is the processing of FIFO data, which in the second driver should be processed as PCM data instead of PDM data. So changes should be made to the Python driver wrapper. Replace the contents of `audio.py` under `pynq/lib` on your PYNQ board with the contents in `new_audio.py` in this directory (maintain the filename on your PYNQ board).

A reference test/debug C++ driver and Makefile is included. It was a product created during development for testing the hardware side of this lab, using static buffer allocation instead of an external buffer passed as parameter. For clarification, the typedef with `PDM` should be `PCM`.