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
	char var;
	int number;
	char *string;
};

/* keywords */
%token M_PRINT M_INPUT M_END M_GOTO M_GOSUB M_RETURN M_IF M_THEN M_LET
%token M_COMMA M_PLUS M_MINUS M_TIMES M_DIVIDE M_OPAREN M_CPAREN M_EQUALS
%token M_GTEQ M_GT M_LTEQ M_LT M_EQEQ M_NEQ

%token <var> M_VAR
%token <number> M_NUMBER
%token <string> M_STRING

%%

program : stmts
	;

stmts	: stmts stmt
	| stmt
	;

stmt	: M_PRINT exprs
	| M_IF expr relop expr M_THEN stmt
	| M_LET M_VAR M_EQUALS expr
	| M_INPUT vars
	| M_GOTO expr
	| M_GOSUB expr
	| M_RETURN
	| M_END
	;

vars	: vars M_COMMA M_VAR
	| M_VAR
	;

exprs	: exprs M_COMMA prelem
	| prelem
	;

prelem	: M_STRING
	| expr
	;

term	: factor mulop factor
	| factor
	;

mulop	: M_TIMES
	| M_DIVIDE
	;

addop	: M_PLUS
	| M_MINUS
	;

relop	: M_GTEQ
	| M_GT
	| M_LTEQ
	| M_LT
	| M_EQEQ
	| M_NEQ
	;

expr	: signterm addop term
	| signterm
	;

signterm: M_PLUS term
	| M_MINUS term
	| term
	;

factor	: M_VAR
	| M_NUMBER
	| M_OPAREN expr M_CPAREN
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
