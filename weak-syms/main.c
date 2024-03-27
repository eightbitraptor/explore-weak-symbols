#include <stdio.h>

void GC_Init(void) __attribute__((weak));
void GC_Init_default(void);

int
main(int _argc, char **argv)
{
    for (int i=0; i<50000; i++) {
        if (GC_Init) {
            GC_Init();
        } else {
            GC_Init_default();
        }
    }

    return 0;
}
