%{

#include "config.h"

#include <getopt.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "parser.h"

extern int lineno;
void yyerror(char *);

#define YY_INPUT(buf,result,max_size) \
	{ \
		int c = fgetc(yyin); \
		result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
	}


%}

letter [A-Za-z]
digit [0-9]

var {letter}
number {digit}+
string \"(\\.|[^"\\])*\"


newline "\n"
carriagereturn "\r"
tab "\t"
space " "
eol ({newline}|{carriagereturn}{newline})
empty ({tab}|{space}|{carriagereturn}|{eol})

%option noinput
%option nounput
%option caseless

%%

"RETURN"	{ return M_RETURN; }
"GOSUB"		{ return M_GOSUB; }
"INPUT"		{ return M_INPUT; }
"PRINT"		{ return M_PRINT; }
"GOTO"		{ return M_GOTO; }
"THEN"		{ return M_THEN; }
"END"		{ return M_END; }
"LET"		{ return M_LET; }
"IF"		{ return M_IF; }

">="		{ return M_GTEQ; }
">"		{ return M_GT; }
"<="		{ return M_LTEQ; }
"<"		{ return M_LT; }
"=="		{ return M_EQEQ; }
"!="		{ return M_NEQ; }

","		{ return M_COMMA; }
"+"		{ return M_PLUS; }
"-"		{ return M_MINUS; }
"*"		{ return M_TIMES; }
"/"		{ return M_DIVIDE; }
"("		{ return M_OPAREN; }
")"		{ return M_CPAREN; }
"="		{ return M_EQUALS; }

{string}	{
			yylval.string = strdup(yytext);
			return M_STRING;
		}

{number}	{
			yylval.number = atoi(yytext);
			return M_NUMBER;
		}

{var}		{
			yylval.var = yytext[0];
			return M_VAR;
		}

{eol}		{
			lineno++;
			break;
		}

{empty}		{
			/* skip whitespace */
			break;
		}

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

