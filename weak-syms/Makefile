CC = gcc
CFLAGS = -I.
PIC=-fPIC
DEBUGFLAGS=-g -Wall -Werror
OPTFLAGS=-O3
DYLDFLAGS = -L. -lgc

OBJS=gc.o main.o
SHOBJS=libgc.so
HEADERS=gc.h rubygc.h

.PHONY: default
default: main

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) $(DEBUGFLAGS) $(OPTFLAGS) -c $< -o $@

$(SHOBJS): $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) $(DEBUGFLAGS) -shared rubygc.c -o $@

main: $(OBJS) $(SHOBJS)
	$(CC) $(CFLAGS) $(DEBUGFLAGS) -Wall -Werror -o $@ $(CFLAGS) $(LDFLAGS) $(OBJS)

.PHONY: clean
clean:
	rm -rf *.so *.o main main-all-static
