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
	int number;
	char *string;
};

/* keywords */
%token M_PRINT M_EXIT
%token M_COMMA M_PLUS M_MINUS M_TIMES M_DIVIDE M_OPAREN M_CPAREN M_COLON M_SEMI_COLON


%token <number> M_NUMBER
%token <string> M_STRING

%type <number> expr signterm term factor

%%

program : stmts
	;

stmts	: stmts stmt
	| stmt
	;

stmt	: M_PRINT M_OPAREN expr M_CPAREN M_SEMI_COLON { printf("%d", $3); }
	| M_PRINT M_OPAREN M_STRING M_CPAREN M_SEMI_COLON { printf("%s", $3); }
	| M_EXIT M_OPAREN expr M_CPAREN M_SEMI_COLON { exit($3); }
	;

term	: factor M_TIMES factor { $$ = $1 * $3; }
	| factor M_DIVIDE factor { $$ = $1 / $3; }
	| factor { $$ = $1; }
	;

expr	: signterm M_PLUS term { $$ = $1 + $3; }
	| signterm M_MINUS term { $$ = $1 - $3; }
	| signterm { $$ = $1; }
	;

signterm: M_PLUS term { $$ = 0 + $2; }
	| M_MINUS term { $$ = 0 - $2; }
	| term { $$ = $1; }
	;

factor	: M_NUMBER { $$ = $1; }
	| M_OPAREN expr M_CPAREN { $$ = $2; }
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
