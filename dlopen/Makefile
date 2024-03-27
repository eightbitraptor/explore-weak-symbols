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
default: main libgc.so

%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) -c $< -o $@ $(CFLAGS)

$(SHOBJS): $(HEADERS)
	$(CC) $(CFLAGS) $(PIC) -shared rubygc.c -o $@

main: $(OBJS) $(SHOBJS)
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(OBJS)

.PHONY: clean
clean:
	rm -rf *.so *.o main
