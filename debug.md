# Debugging Notes

## 1. Purpose
It is expected that there will be a lot of issues when first using the Xilinx and PYNQ toolchains. This markdown file aims to assist you with debugging your PYNQ board and give pointers to useful documentation / forum posts.

Feel free to provide further support to your coursemates by adding information of other commonly seen bugs (please make a branch and pull request).

Any questions? Contact Kevin through email (khl22@ic.ac.uk).

## 2. Bugs

### Vivado Y2K22
**Issue**: Vivado has a bug where the `ip_version` value, which is accessed as a signed integer (32-bit), causes an overflow and generates an error. This is for Vivado versions 2014.x through 2021.2.

Apply the following patch to fix the issue:
https://support.xilinx.com/s/article/76960?language=en_US

### 

## 3. Troubleshooting

For any issues with PYNQ, you can consult the following resources:
- [PYNQ Documentation](https://pynq.readthedocs.io/en/latest/)
- [PYNQ forum](https://discuss.pynq.io/)

### Refusing to connect
If your PYNQ board refuses to connect, try the following:
1. Check whether your ethernet cable to securely connected to the board - there should be lights on the board which indicate ethernet connection. Some of the PYNQ kits have old ethernet cables with loose ends. Try using a different cable.
2. Check your network settings. If you assigned a static IP address, ensure that the IP address is correct.
3. SSH into the board using PuTTY. Run `ifconfig` to check that its `eth0:1` IP address is what you expected (usually `192.168.2.99`). If it is not, try running your the indicated IP address with port 9090.
4. If you are still unable to connect, try restarting your PYNQ board, which usually does the trick. SSH into PuTTY and run `sudo reboot`.

### Limited storage space
Vivado and Vitis are huge programs, and they require a lot of space to install. You can usually see the expected space required in the installation setup tool. Note that the space required for extraction and download is larger than the final installation size.

If you don't have enough space, the best method is to reduce the amount of board support selections. Since you are only expected to use the PYNQ-Z1 board, which is a Zynq-7000 series board, you can deselect support for all other boards types to reduce the installation size.



## 4. References

### PYNQ resources
For any issues with PYNQ, you can consult the following resources:
- [PYNQ Documentation](https://pynq.readthedocs.io/en/latest/)
- [PYNQ forum](https://discuss.pynq.io/)