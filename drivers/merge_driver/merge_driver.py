import math
import os
import struct
import time
import wave

import cffi
import numpy

from pynq import GPIO
from pynq import DefaultIP
from pynq import PL
from pynq.uio import get_uio_index

LIB_SEARCH_PATH = os.path.dirname(os.path.realpath(__file__))

class MergeIP(DefaultIP):
    def __init__(self, description):
        super().__init__(description=description)

        self._ffi = cffi.FFI()

        ## Load the shared library
        self._libmerge = self._ffi.dlopen(os.path.join(LIB_SEARCH_PATH, "libmerge.so"))

        self._ffi.cdef(
            """
            unsigned int Xil_In32(unsigned int Addr);
            ;"""
        )
        self._ffi.cdef(
            """
            unsigned int Xil_Out32(unsigned int Addr, unsigned int Value);
            ;"""
        )
        self._ffi.cdef(
            """
            void merge(unsigned int BaseAddr, unsigned int *BufAddr, unsigned int *a, unsigned int a_size, unsigned int *b, unsigned int b_size);
            ;"""
        )

        ## Get the base address of the IP
        base_addr = self._ffi.from_buffer(self.mmio.array) # Init pointer to buffer
        self._base_addr = self._ffi.cast("unsigned int", base_addr) # Cast to unsigned int

        self.buffer = numpy.zeros(0).astype(numpy.uint32)

    bindto = ['xilinx.com:user:merge_v1_0:1.0']

    def merge(self, a, b):
        
        if self.buffer.dtype.type != numpy.uint32:
            raise ValueError("Internal buffer must be of type uint32")
        
        a = numpy.array(a, dtype=numpy.uint32)
        b = numpy.array(b, dtype=numpy.uint32)

        a_size = len(a)
        b_size = len(b)

        c_size = a_size + b_size

        # Resize the internal buffer if necessary
        if len(self.buffer) < c_size:
            self.buffer = numpy.zeros(c_size, dtype=numpy.uint32)

        # Create C-compatible pointers to the input arrays
        a_ptr = self._ffi.cast("unsigned int *", a.ctypes.data)
        b_ptr = self._ffi.cast("unsigned int *", b.ctypes.data)
        c_buf = self._ffi.cast("unsigned int *", self.buffer.ctypes.data)

        self._libmerge.merge(
            self._base_addr,        # BaseAddr
            c_buf,                  # BufAddr
            a_ptr,                  # a
            a_size,                 # a_size
            b_ptr,                  # b
            b_size                  # b_size
        )

        # Return the output buffer
        return self.buffer[:c_size].copy()