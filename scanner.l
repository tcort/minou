%{

#include "config.h"

#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "ast.h"
#include "parser.h"

extern int lineno;
void yyerror(char *);

static char *uncolon(char *s) {
	size_t i;
	for (i = 0; i < strlen(s); i++) {
		if (s[i] == ':' && ((i+1) < strlen(s))) {
			switch (s[i+1]) {
				case ')': s[i] = '\n'; break;
				case '>': s[i] = '\t'; break;
				case 'o': s[i] = '\a'; break;
				case '"': s[i] = '"'; break;
				case ':': s[i] = ':'; break;
				default: break;
			}
			memmove(s+i+1, s+i+2, strlen(s+i+1));
		}
	}
	return s;
}


#define YY_INPUT(buf,result,max_size) \
	{ \
		int c = fgetc(yyin); \
		result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
	}


%}

letter [A-Za-z]
digit [0-9]
label {letter}({letter}|{digit})*

numbar {digit}+\.{digit}+

yarn \"(\\.|[^"\\])*\"

newline "\n"
carriagereturn "\r"
tab "\t"
space " "
eol ({newline}|{carriagereturn}{newline})
ws ({tab}|{space})

%option noinput
%option nounput

%x OBTW

%%

KTHXBYE		{ return M_KTHXBYE; }
VISIBLE		{ return M_VISIBLE; }

OBTW		{ BEGIN(OBTW); break; }
<OBTW>TLDR{ws}[^\r\n]*	{ BEGIN(INITIAL); break; }
<OBTW>{eol}	{ lineno++; break; }
<OBTW>.		{ break; }

BTW{ws}[^\r\n]*	{ break; }

HAI		{ return M_HAI; }

"!"		{ return M_EXCLAIM; }
","		{ return M_COMMA; }

{numbar}	{ yylval.numbar = atof(yytext); return M_NUMBAR; }

{yarn}		{
			yylval.yarn = strdup(yytext+1);
			yylval.yarn[strlen(yylval.yarn)-1] = '\0';
			yylval.yarn = uncolon(yylval.yarn);
			return M_YARN;
		}

{eol}		{ lineno++; break; }

{ws}		{ /* skip whitespace */ break; }

.		{
			yyerror ("Invalid Syntax");
		}

%%

int yyparse();
int yywrap() {
	return 1;
}

int lineno = 0;
char *output_filename = "a.out";

/**
 * Print the package name and version number, then exit().
 */
void print_version(void) {

	fprintf(stdout, "%s %s\n", PACKAGE_NAME, PACKAGE_VERSION);
	exit(0);
}

/**
 * Prints the usage information and available command line options, then exit().
 *
 * @param progname the name of the program
 */
void print_help(char *progname) {

	fprintf(stdout, "minou - mini-pascal compiler.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Usage: %s [OPTION] [filename]\n", progname);
	fprintf(stdout, "\n");
	fprintf(stdout, "Options:\n");
	fprintf(stdout, " -o [filename]     --output [filename]     Specify the output filename.\n");
	fprintf(stdout, " -h, -?            --help                  Print a helpful message and exit.\n");
	fprintf(stdout, " -v                --version               Print version information and exit.\n");
	fprintf(stdout, "\n");
	fprintf(stdout, "Report bugs to <%s>.\n", PACKAGE_BUGREPORT);

	exit(0);
}

/**
 * Main driver program.
 *
 * @param argc number of command line arguments.
 * @param argv the command
 * @return exit code
 */
int main(int argc, char *argv[]) {

	int optc;

	const char* const short_options = "o:h?v";
	static const struct option long_options[] = {
		{"help", no_argument, NULL, 'h'},
		{"version", no_argument, NULL, 'v'},
		{"output", required_argument, NULL, 'o'},
		{NULL, 0, NULL, 0}
	};

	while ((optc = getopt_long(argc, argv, short_options, long_options, NULL)) != -1) {
		switch (optc) {
			case 'o':
				output_filename = optarg;
				break;
			case 'v':
				print_version();
				break;
			case 'h':
			case '?':
				print_help(argv[0]);
				break;
		}
	}

	if (optind + 1 != argc) {
		print_help(argv[0]);
	}

	yyin = fopen(argv[optind], "r");
	if (!yyin) {
		perror(argv[optind]);
		exit(1);
	}
	yyparse();
	fclose(yyin);

	return 0;
}

