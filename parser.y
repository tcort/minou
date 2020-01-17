%{

#include "config.h"

#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "ast.h"
#include "interpret.h"

/* Globals */
extern int lineno;
extern int yylex();

/* Prototypes */
int yyerror(char* str);

%}
 
%union {
	char *id;
	ast_node_t *ast;
	double numbar;
	char *yarn;
};

/* keywords */
%token M_HAI M_KTHXBYE M_I_HAS_A

/* functions */
%token M_VISIBLE

/* special chars */
%token M_EXCLAIM M_COMMA

%token <id> M_ID
%token <numbar> M_NUMBAR
%token <yarn> M_YARN

%type <numbar> welcome
%type <ast> program print decl stmt block

%%

program : welcome block goodbye {
					$$ = ast_node_alloc(M_PROGRAM);
					$$->value.program.language_version = $1;
					$$->next = $2;
					interpret($$);
					ast_node_free($$);
				}
	;

block	: block stmt	{
				ast_node_t *cur;
				for (cur = $1; cur->next != NULL; cur = cur->next) {}
				cur->next = $2;
				$$ = $1;
			}
	| stmt { $$ = $1; }
	;

stmt	: print { $$ = $1; }
	| decl { $$ = $1; }
	;

decl	: M_I_HAS_A M_ID 	{
						$$ = ast_node_alloc(M_DECL);
						$$->value.decl.name  = $2;
				}
	;

print	: M_VISIBLE M_YARN M_EXCLAIM 	{
						$$ = ast_node_alloc(M_PRINT);
						$$->value.print.yarn = $2;
						$$->value.print.newline = 0;
					}
	| M_VISIBLE M_YARN		{
						$$ = ast_node_alloc(M_PRINT);
						$$->value.print.yarn = $2;
						$$->value.print.newline = 1;
					}
	;
welcome	: M_HAI M_NUMBAR { $$ = $2; }
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
