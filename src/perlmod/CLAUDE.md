# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a monorepo of independent Perl modules, each with its own build system, tests, and namespace. Modules are developed and tested independently.

**Modules:**
- `posix-at-2/` (and `posix-at/`) — FFI::Platypus bindings to POSIX "at" family syscalls (`openat`, `fstatat`, `unlinkat`, `mkdirat`, `renameat2`, etc.)
- `nobody/` — General-purpose utility collection (`Nobody::Util`, `Nobody::PP`, `Nobody::JSON`)
- `Exception-ThrowUnless/` — Wrappers for system calls that die on failure instead of returning undef
- `Getopt-WonderBra/` — Command-line option parser
- `LWP-Protocol-virtual/` — Virtual URI scheme for LWP (`virtual://`)
- `Symbol-Slots/` — XS extension to inspect Perl typeglob slot initialization
- `Unicode-NoFancyPants/` — Replaces fancy Unicode characters with ASCII equivalents

## Build & Test

Each module is built and tested independently. The pattern is the same everywhere:

```bash
cd <module-dir>
perl Makefile.PL   # generates Makefile
make               # build (compiles XS for Symbol-Slots)
make test          # run all tests
```

To run a single test file:
```bash
cd <module-dir>
prove -lv t/01-basic.t
```

Each module directory has a `GNUmakefile` wrapper that auto-invokes `perl Makefile.PL` when needed:
```bash
cd <module-dir>
make test          # GNUmakefile will regenerate Makefile if Makefile.PL changed
```

The root `Makefile.PL` validates `MANIFEST` and builds the top-level `perlmode` stub only.

## Architecture Notes

### POSIX::At (posix-at-2)
Pure FFI binding via `FFI::Platypus`. `At.pm` is the implementation; `POSIX/At.pm` is a symlink for namespace installation. `posix-at-2` is the active version; `posix-at` is the older version retained for reference.

### Nobody
No top-level `Nobody.pm` — consumers `use Nobody::Util`, `Nobody::PP`, or `Nobody::JSON` directly. Uses `common::sense` throughout (strict + warnings + utf8).

### Exception::ThrowUnless
All exported functions have an `s` prefix (e.g., `sopen`, `smkdir`, `sunlink`). They wrap Perl built-ins and die on failure. Some have intentional soft-failure semantics (e.g., `smkdir` tolerates existing directories, `sunlink` retries).

### Symbol::Slots
Has an XS component (`Slots.xs`). Requires `make` to compile before use. The XS exposes `used_slots(pkg_name, var_name)` which inspects C-level typeglob structures.

## Conventions

- Modules use `common::sense` (implies `use strict`, `use warnings`, `use utf8`)
- Test files follow `NN-name.t` naming under `t/`
- Examples go in `eg/`
- Author contact: Rich Paul / nobody@cpan.org
