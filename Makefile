all: icecrystals

icecrystals: 
	crystal build --release bin/icecrystals.cr
	@du -sh icecrystals

clean:
	rm -rf .crystal icecrystals .deps .shards libs

PREFIX ?= /usr/local

install: icecrystals
	install -d $(PREFIX)/bin
	install icecrystals $(PREFIX)/bin
