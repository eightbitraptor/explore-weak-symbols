CC = gcc
override CFLAGS := $(CFLAGS) -I.
PIC=-fPIC
DEBUGFLAGS=-g -Wall -Werror
OPTFLAGS=-O3
DYLDFLAGS = -L. -lgc

OBJS=main.o
SHOBJS=libgc.so
HEADERS=rubygc.h

.PHONY: default
default: main

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) $(DEBUGFLAGS) $(OPTFLAGS) -c $< -o $@

$(SHOBJS): $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) $(DEBUGFLAGS) -shared rubygc.c -o $@

override/libgc.so: $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) $(DEBUGFLAGS) -shared rubygc2.c -o $@

main: $(OBJS) $(SHOBJS) override/libgc.so
	$(CC) $(CFLAGS) $(DEBUGFLAGS) -L. -lgc -Wall -Werror -o $@ $(CFLAGS) $(LDFLAGS) $(OBJS) -Wl,-rpath=$(shell pwd)

.PHONY: clean
clean:
	rm -rf *.so override/*.so *.o main main-all-static
