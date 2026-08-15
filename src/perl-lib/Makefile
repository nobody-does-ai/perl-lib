MAKEFLAGS+=-rR
subs:=
#subs+= Exception-ThrowUnless
subs+= Getopt-WonderBra
#subs+= IO-PSelect
#subs+= LWP-Protocol-virtual
subs+= Module-Gather
subs+= Symbol-Slots
subs+= Unicode-NoFancyPants
subs+= POSIX-At
subs+= Nobody-Util
export subs

MAKEFILES:=$(patsubst %,%/Makefile,$(subs))
MANIFESTS:=$(patsubst %,%/MANIFEST,$(subs))

builds:=	$(patsubst %,%_build,$(subs))
export PERL5LIB

all: stow
base=$(shell cd ../.. && pwd)

config: $(MAKEFILES) $(MANIFESTS)

$(builds): %_build: % %/Makefile %/MANIFEST config
	cd $(patsubst %_build,%,$@) && make
	cd $(patsubst %_build,%,$@) && make test
	cd $(patsubst %_build,%,$@) && make install

$(MAKEFILES): %/Makefile: %/Makefile.PL
	cd $(dir $@) && perl -Mlocal::lib=/opt Makefile.pl


$(MANIFESTS): %/MANIFEST: %/Makefile
	cd $(dir $@) && make manifest

build: $(builds)

stow: build
	cd ../.. && rm -fr share/man && mkdir -p share && mv man share && cd .. && pwd && test $$(basename $$PWD) == stow && stow perl-lib
