MAKEFLAGS+=-rR
subs:=
subs+= Exception-ThrowUnless
#subs+= Getopt-WonderBra
subs+= IO-PSelect
subs+= LWP-Protocol-virtual
subs+= Module-Gather
subs+= Symbol-Slots
subs+= Unicode-NoFancyPants
subs+= POSIX-At
#subs+= Nobody-Util
export subs
MAKEFILES:=$(PATSUBST %,%/Makefile,$(subs))
builds:=	$(patsubst %,%_build,$(subs))
PERL5LIB:=$(PWD)/Nobody-Util:$(PERL5LIB)
export PERL5LIB

all: stow
base=$(shell cd ../.. && pwd)

$(MAKEFILES): %/Makefile: %/Makefile.PL
	cd $(dir $@) && perl -Mlocal::lib=$(base) Makefile.PL INSTALLDIRS=perl
	${MAKE} -C Nobody-Util all
${MAKE} -C Nobody::Util; 

config: $(makefiles)

$(builds): %_build: % %/Makefile
	cpanm Nobody::Util
	cd $(patsubst %_build,%,$@) && make
	cd $(patsubst %_build,%,$@) && make test
	cd $(patsubst %_build,%,$@) && make install

build: $(builds)

stow: build
	cd ../.. && rm -fr share/man && mkdir -p share && mv man share && cd .. && pwd && test $$(basename $$PWD) == stow && stow perl-lib
