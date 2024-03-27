#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

#include "rubygc.h"

#ifndef GC_TEST_ITERS
#define GC_TEST_ITERS 0
#endif

int
main(int argc, char **argv)
{
    if (!GC_TEST_ITERS) return 1;
    
    for (int i = 0; i < GC_TEST_ITERS; i++) {
        GC_Init();
    }
    
    return 0;
}
