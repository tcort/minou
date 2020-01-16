%{

#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>


/* Globals */
extern int lineno;
extern int yylex();

/* Prototypes */
int yyerror(char* str);

%}
 
%union {
	double numbar;
};

/* keywords */
%token M_HAI M_KTHXBYE


%token <numbar> M_NUMBAR

%%

program : welcome goodbye
	;

welcome	: M_HAI M_NUMBAR
	;

goodbye	: M_KTHXBYE
	;

%%

/**
 * A parse error occurred, print an error message and exit().
 *
 * @param error message.
 * @return should not return, but if it does a -1 will be returned.
 */
int yyerror(char* str) {
	fprintf(stderr,"yyerror: %s (line %d)\n", str, lineno + 1);
	exit(1);
	return -1; /* should not get here */
}
