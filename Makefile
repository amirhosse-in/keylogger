CC = clang
CFLAGS = -fobjc-arc -Wall
FRAMEWORKS = -framework Foundation -framework ApplicationServices

keylogger: key-tap.m
	$(CC) $(CFLAGS) -o $@ $< $(FRAMEWORKS)

clean:
	rm -f keylogger

