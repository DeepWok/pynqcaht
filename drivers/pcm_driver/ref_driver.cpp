#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_types.h"
#include "xil_io.h"
#include "xtime_l.h"

#define AXI_BASE_ADDR 0x40000000
#define PDM_RESET_REG               (AXI_BASE_ADDR + 0x00)
#define PDM_TRANSFER_CONTROL_REG    (AXI_BASE_ADDR + 0x04)
#define PDM_FIFO_CONTROL_REG        (AXI_BASE_ADDR + 0x08)
#define PDM_DATA_IN_REG             (AXI_BASE_ADDR + 0x0C)
#define PDM_DATA_OUT_REG            (AXI_BASE_ADDR + 0x10)
#define PDM_STATUS_REG              (AXI_BASE_ADDR + 0x14)

#define TX_FIFO_EMPTY               0
#define TX_FIFO_FULL                1
#define RX_FIFO_EMPTY               16
#define RX_FIFO_FULL                17

#define SAMPLE_RATE 48000
#define RECORD_SECONDS 10
#define PARAMS (SAMPLE_RATE * RECORD_SECONDS)
#define BUFFER_SIZE 480000 // sample rate * record seconds

// Static buffer allocation
static unsigned int buffer[BUFFER_SIZE];

inline static uint32_t Read32(intptr_t addr) {
    return *(volatile uint32_t*)addr;
}

inline static void Write32(intptr_t addr, uint32_t value) {
    *(volatile uint32_t*)addr = value;
}

void reset_fifo() {
    xil_printf("Resetting FIFOs...\n\r");
    Write32(PDM_FIFO_CONTROL_REG, 0xC0000000);
    Write32(PDM_FIFO_CONTROL_REG, 0x00000000);
}

void record(unsigned int BaseAddr, unsigned int *BufAddr, unsigned int nsamples) {
    unsigned long u32Temp, i = 0;
    XTime tStart, tEnd;

    xil_printf("Resetting PDM...\n\r");

    Write32(PDM_RESET_REG, 0x01);
    Write32(PDM_RESET_REG, 0x00);

    reset_fifo();

    xil_printf("Configuring PDM for Receive...\n\r");
    Write32(PDM_TRANSFER_CONTROL_REG, 0x00);
    Write32(PDM_TRANSFER_CONTROL_REG, 0x05);

    xil_printf("Start Sampling...\n\r");
    XTime_GetTime(&tStart);

    while (i < nsamples) {
        u32Temp = ((Read32(PDM_STATUS_REG)) >> RX_FIFO_EMPTY) & 0x01;
        if (u32Temp == 0) {  // FIFO has data
            if (i % 1000 == 0) {
                xil_printf("Reading sample %d...\n\r", i);
            }
            Write32(PDM_FIFO_CONTROL_REG, 0x00000002);
            Write32(PDM_FIFO_CONTROL_REG, 0x00000000);
            BufAddr[i] = Read32(PDM_DATA_OUT_REG);
            i++;
        } else {
            if (i % 10000 == 0) {
                xil_printf("FIFO Empty, waiting... (i=%d)\n\r", i);
            }
        }
    }

    XTime_GetTime(&tEnd);
    xil_printf("Stopping PDM...\n\r");
    Write32(PDM_TRANSFER_CONTROL_REG, 0x02);

    double elapsed = (double)(tEnd - tStart) / (double)COUNTS_PER_SECOND;
    xil_printf("Recording completed. Elapsed time: %f seconds\n\r", elapsed);
}

void print_data(unsigned int *buffer, unsigned int nsamples) {
    xil_printf("BEGIN_PDM_DATA\n\r");
    for (unsigned int i = 0; i < nsamples; i++) {
        xil_printf("%u\n\r", buffer[i]);
    }
    xil_printf("END_PDM_DATA\n\r");
}

int main() {
    init_platform();

    xil_printf("Initializing...\n\r");
    xil_printf("PARAMS: %d\n\r", PARAMS);
    xil_printf("BUFFER_SIZE: %d\n\r", BUFFER_SIZE);

    unsigned int nsamples = BUFFER_SIZE;
    XTime tStart, tEnd;

    xil_printf("Starting recording...\n\r");
    XTime_GetTime(&tStart);
    record(AXI_BASE_ADDR, buffer, nsamples);
    XTime_GetTime(&tEnd);

    xil_printf("Recording finished. Printing data...\n\r");
    print_data(buffer, nsamples);

    printf("Elapsed: %lf seconds\r\n", ((double)(tEnd - tStart) / (double)COUNTS_PER_SECOND));

    cleanup_platform();
    return 0;
}
