
SHELL_TESTS = \
	hello.sh

TESTS = $(SHELL_TESTS)

TESTS_ENVIRONMENT = \
	MINOU=$(top_builddir)/minou	\
	INDIR=$(top_srcdir)/tests	\
	OUTDIR=$(top_builddir)/tests	\
	EXDIR=$(top_srcdir)/tests	\
	RUNNER=$(top_srcdir)/tests/run.sh

CLEANFILES = \
	hello.out

EXTRA_DIST = $(SHELL_TESTS) run.sh \
	hello.lol	hello.ex
