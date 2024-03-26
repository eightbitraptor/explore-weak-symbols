#include <stdio.h>
#include "gc.h"
#include "rubygc.h"

int
main(int argc, char **argv)
{
    if (GC_Init != NULL) {
        GC_Init();
    } else {
        GC_Init_default();
    }
}
