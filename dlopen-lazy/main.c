#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

#include "gc.h"
#include "rubygc.h"

#ifndef GC_TEST_ITERS
#define GC_TEST_ITERS 0
#endif

typedef struct gc_function_map {
    void (*gc_init)(void);
} gc_function_map_t;

gc_function_map_t *
load_external_gc(void)
{
    gc_function_map_t *map = malloc(sizeof(gc_function_map_t));

    /* Configure defaults */
    map->gc_init = &GC_Init_default;

    /* Load overrides if available */
    char *lib = getenv("RUBY_GC_PATH");
    if (!lib) return map;
    
    void *handle = dlopen(lib, RTLD_LAZY);
    if (!handle) return map;

    void * gc_init_func = dlsym(handle, "GC_Init");
    if (gc_init_func) map->gc_init = gc_init_func;

    return map;
}

int
main(int argc, char **argv)
{
    if (!GC_TEST_ITERS) return 1;
    
    gc_function_map_t * gc_funcs = load_external_gc();

    for(int i = 0; i < GC_TEST_ITERS; i++) {
        gc_funcs->gc_init();
    }
    
    return 0;
}
