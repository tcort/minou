#ifndef AST_H
#define AST_H

enum ast_type { M_PROGRAM, M_PRINT, M_DECL };
typedef enum ast_type ast_type_t; 




struct print_value {
	char *yarn;
	int newline;
};
typedef struct print_value print_value_t;


struct program_value {
	double language_version;
};
typedef struct program_value program_value_t;


struct decl_value {
	char *name;
};
typedef struct decl_value decl_value_t;

union ast_value {
	program_value_t program;
	print_value_t print;
	decl_value_t decl;
};
typedef union ast_value ast_value_t;



struct ast_node {
	ast_type_t type;
	ast_value_t value;
	struct ast_node *next;
};
typedef struct ast_node ast_node_t;



ast_node_t *ast_node_alloc(ast_type_t type);
void ast_node_free(ast_node_t *type);

#endif 
