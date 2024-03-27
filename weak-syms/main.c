#include <stdio.h>

void GC_Init(void) __attribute__((weak));
void GC_Init_default(void);

#ifndef GC_TEST_ITERS
#define GC_TEST_ITERS 0
#endif

int
main(int _argc, char **argv)
{
    if (!GC_TEST_ITERS) return 1;
    
    for (int i = 0; i < GC_TEST_ITERS; i++) {
        if (GC_Init) {
            GC_Init();
        } else {
            GC_Init_default();
        }
    }

    return 0;
}
