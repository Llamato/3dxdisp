PREFIX ?= /usr/local
bindir ?= $(PREFIX)/bin

src = $(wildcard src/*.c)
obj = $(src:.c=.o)
bin = spacepilotdisplay

CFLAGS = -pedantic -Wall -g -I../src
LDFLAGS = ../lib3dxdisp.a -ludev

$(bin): $(obj) ../lib3dxdisp.a
	$(CC) -o $@ $(obj) $(LDFLAGS)

.PHONY: install
install: $(bin)
	install -d $(DESTDIR)$(bindir)
	install -m 0755 $(bin) $(DESTDIR)$(bindir)/$(bin)

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(bindir)/$(bin)

.PHONY: clean
clean:
	rm -f $(obj) $(bin)