BUILT_SOURCES = parser.h
AM_YFLAGS = -d

bin_PROGRAMS = minou
minou_SOURCES = scanner.l parser.y ast.c ast.h interpret.c interpret.h
minou_LDADD = @LEXLIB@

EXTRA_DIST = README.md
