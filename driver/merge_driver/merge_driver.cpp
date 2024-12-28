#include <stdint.h>
#include "merge_driver.h"

inline static uint32_t merge_read(intptr_t addr) {
    return *(volatile uint32_t *)addr;
}

inline static void merge_write(intptr_t addr, uint32_t data) {
    *(volatile uint32_t *)addr = data;
}

extern "C" void merge(unsigned int BaseAddr, unsigned int *BufAddr, unsigned int *a, unsigned int a_size, unsigned int *b, unsigned int b_size) {

    unsigned int c_size = a_size + b_size;
    uint32_t* c = new uint32_t[c_size];
    uint32_t status;

    for(unsigned int i = 0; i < a_size; ++i) {
        merge_write(BaseAddr + MERGE_1_REG, a[i]);
    }

    for(unsigned int i = 0; i < b_size; ++i) {
        merge_write(BaseAddr + MERGE_2_REG, b[i]);
    }

    merge_write(BaseAddr + MERGE_CTRL_REG, 0x1);

    status = merge_read(BaseAddr + MERGE_STATUS_REG);
    
    while(status) {
        status = merge_read(BaseAddr + MERGE_STATUS_REG);
    }

    for(unsigned int i = 0; i < c_size; ++i) {
        c[i] = merge_read(BaseAddr + MERGE_RESULT_REG);
        BufAddr[i] = c[i];
    }

    delete[] c;

}
