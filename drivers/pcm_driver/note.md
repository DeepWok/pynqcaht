# Note for drivers

No modifications are needed to the `audio_direct.cpp` and the `audio_direct.h` original driver files developed by the PYNQ team, since the FIFO control is basically the same. 

The difference is the processing of FIFO data, which in the second driver should be processed as PCM data instead of PDM data. So changes should be made to the Python driver wrapper.