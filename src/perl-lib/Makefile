MAKEFLAGS+=-rR
subs:=
subs+= Exception-ThrowUnless
subs+= Getopt-WonderBra
subs+= IO-PSelect
subs+= LWP-Protocol-virtual
subs+= Module-Gather
subs+= Symbol-Slots
subs+= Unicode-NoFancyPants
subs+= nobody
subs+= posix-at
export subs
makefiles:=$(patsubst %,%/Makefile,$(subs))
builds:=	$(patsubst %,%_build,$(subs))
#$(foreach b,$(builds),$(warning $b))
all: stow

$(makefiles): %/Makefile: %/Makefile.PL
	cd $(dir $@) && perl -Mlocal::lib=/opt/stow Makefile.PL INSTALLDIRS=perl

config: $(makefiles)

$(builds): %_build: % %/Makefile
	cd $(patsubst %_build,%,$@) && make
	cd $(patsubst %_build,%,$@) && make test
	cd $(patsubst %_build,%,$@) && make install

build: $(builds)

stow: build
	cd ../../.. && stow perl-lib
