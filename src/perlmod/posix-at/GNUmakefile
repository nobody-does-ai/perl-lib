# If Makefile exists, include it to inherit all Perl/XS build rules
ifeq ("$(wildcard Makefile)","")
# Ensure 'all' is the default if someone just types 'make' 
# before the Makefile is even generated.
.DEFAULT_GOAL := all

all:

# If Makefile is missing, provide the bootstrap rule
Makefile: Makefile.PL
	perl Makefile.PL
endif
include Makefile
