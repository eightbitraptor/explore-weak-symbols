CC = gcc
CFLAGS = -I.
DYLDFLAGS = -L. -lgc

OBJS=gc.o main.o
SHOBJS=libgc.so
HEADERS=gc.h

%.o: %.c $(HEADERS)
	echo "BUILDING"
	$(CC) -Wall -c -o $@ $(CFLAGS)

libgc.so: 
	$(CC) -shared -fPIC rubygc.c -o $@

main: $(OBJS)
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(OBJS)

main-all-static: $(OBJS) rubygc.o
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(OBJS) rubygc.o

.PHONY: clean
clean:
	rm -rf *.so *.o main main-all-static
