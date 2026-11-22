PREFIX ?= /usr/local
bindir ?= $(PREFIX)/bin
assetdir ?= $(PREFIX)/share

INSTALL_ASSETS ?= 0

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
ifneq ($(INSTALL_ASSETS),0)
	install -d $(DESTDIR)$(assetdir)
	install -m 0644 assets/jamlytics.packed $(DESTDIR)$(assetdir)/jamlytics.packed
endif

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(bindir)/$(bin)
ifneq ($(INSTALL_ASSETS),0)
	rm -f $(DESTDIR)$(assetdir)/jamlytics.packed
endif

.PHONY: clean
clean:
	rm -f $(obj) $(bin)