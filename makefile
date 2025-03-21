PREFIX ?= /usr/local
all_files != git ls-files
src_files != find src -type f
installables = bin/cheet
version != grep "version:" shard.yml | cut -d " " -f2
revision != git rev-parse HEAD 2> /dev/null
distbase = cheet-$(version)
distfile = $(distbase).tar.gz

all: $(installables)

bin/cheet: $(src_files)
	env CHEET_GIT_COMMIT=$(revision) \
		shards build --release

.PHONY: check
check: $(src_files)
	crystal spec

.PHONY: install
install: $(installables)
	@echo "Installing $(DESTDIR)$(PREFIX)/bin/cheet"
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 755 bin/cheet $(DESTDIR)$(PREFIX)/bin/
	install -d $(DESTDIR)$(PREFIX)/share/man/man1/
	install -m 644 doc/cheet.1 $(DESTDIR)$(PREFIX)/share/man/man1/

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/cheet
	rm -f $(DESTDIR)$(PREFIX)/share/man/man1/cheet.1

dist: $(distfile)
$(distfile): $(all_files)
	git archive --prefix $(distbase)/ -o $@ HEAD

.PHONY: clean
clean:
	rm -f $(installables)
