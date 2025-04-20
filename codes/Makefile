SDKROOT := $(shell /usr/bin/xcrun --show-sdk-path -sdk macosx)
LDFLAGS = -lSystem -L $(SDKROOT)/usr/lib

2-special-numbers: 2-special-numbers.c
	$(CC) 2-special-numbers.c -o 2-special-numbers


all: \
	2-special-numbers

clean:
	rm *.o *.a *.dylib \
		2-special-numbers