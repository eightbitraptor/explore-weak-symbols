# Testing Weak symbol lookup.

This project consists of several files.

- `main.c` the main routine. This file defines main and calls our GC
  initialisation function `GC_Init`.
- `rubygc.h` included from main. Declares `GC_Init` as a weak symbol.
- `gc.c` implements `GC_Init`, prints out some text.
- `rubygc.c` also implements `GC_Init` prints out some different text.

## Building

Here is how to get all the artifacts required for these tests

1. Build the object files: `make gc.o && make main.o`
1. Build and link the main binary: `make main`
1. Build the dynamic gc library: `make libgc.so`
1. Build the static gc library and link into a binary: `make main-all-static`
1. Pre-load dynamic library and then run either executable: `LD_PRELOAD=(pwd)/libgc.so ./main`

## Desired behaviour

When a binary `main` is built by linking `gc.o` and `main.o` I expect the symbol
`GC_Init` to be resolved to the version compiled in `gc.o` and linked statically
into `main`. When the binary is run, the text printed to the screen will be the
text defined inside `gc.c`.

When `rubygc.c` is build as a shared library (`librubygc.so`), and injected into
the running binary using `LD_PRELOAD`, I want the definition of `GC_Init` to
override the version defined in `gc.c` and running the binary should result in
the text from `rubygc.c` being printed to the terminal

## Actual behaviour

### Default case

- `gc.o` linked statically
- `librubygc` not linked

```
~/git/test_weak_symbols
❯ ./main
=== Default GC Loaded
```

Text from `gc.o` is printed

### Default case with dynamic override

- `gc.o` linked statically
- `librubygc` included using `LD_PRELOAD`

```
~/git/test_weak_symbols
❯ LD_PRELOAD=(pwd)/libgc.so ldd ./main
	linux-vdso.so.1 (0x00007ffe988c8000)
	/home/mattvh/git/test_weak_symbols/libgc.so (0x00007f1ba6214000)
	libc.so.6 => /lib64/libc.so.6 (0x00007f1ba601d000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f1ba621b000)

~/git/test_weak_symbols
❯ LD_PRELOAD=(pwd)/libgc.so ./main
=== Default GC Loaded
```

Text from `gc.o` is printed

### Both libraries linked statically

- `gc.o` linked statically
- `librubygc` compiled as a `.o` and linked statically

```
❯ ./main-all-static
=== Override GC Loaded⏎ 
```

Text from `librubygc` printed.

### Questions

- What happens if I remove the weak symbol attributes?

```
~/git/test_weak_symbols
❯ make main-all-static
gcc -I.   -c -o rubygc.o rubygc.c
gcc -o main-all-static -I.  gc.o main.o rubygc.o
/usr/bin/ld: rubygc.o: in function `GC_Init':
rubygc.c:(.text+0x0): multiple definition of `GC_Init'; gc.o:gc.c:(.text+0x0): first defined here
collect2: error: ld returned 1 exit status
make: *** [Makefile:20: main-all-static] Error 1
```
