# Debugging Notes

### Lab 1
- If DMA transfer doesn't work properly or hangs forever, just redo the tutorial step-by-step carefully. Don't complain because it is a relatively simple process that gets you familiar with the toolchain anyways.

### Lab 2
- Useful commands
```python
# Check if PYNQ's package contents recognises / includes your driver 
import pynq.lib
help(pynq.lib)

# Check IP types in your overlay
overlay.ip_dict

# Verify correct driver associated with your IP
print(type(overlay.<your_ip>))

```