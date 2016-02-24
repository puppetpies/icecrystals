all: icecrystals

icecrystals: 
	crystal build --release bin/icecrystals.cr -o bin/icecrystals
	@du -sh bin/icecrystals

clean:
	rm -rf .crystal icecrystals .deps .shards libs

PREFIX ?= /usr/local

install: icecrystals
	install -d $(PREFIX)/bin
	install bin/icecrystals $(PREFIX)/bin
