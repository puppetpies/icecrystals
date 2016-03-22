all: icecrystals

icecrystals: 
	crystal build --release bin/icecrystals.cr -o bin/icecrystals
	@du -sh bin/icecrystals

clean:
	rm -f bin/icecrystals

PREFIX ?= /usr/local

install: icecrystals
	install -d $(PREFIX)/bin
	install bin/icecrystals $(PREFIX)/bin
	install examples/keywords.ice ~/.icersplicer
	install examples/keywords-ruby.ice ~/.icersplicer

