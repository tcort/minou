#include "config.h"

#include <stdlib.h>
#include <string.h>

#include "ast.h"

ast_node_t *ast_node_alloc(ast_type_t type) {
	ast_node_t *node;
	node = (ast_node_t *) malloc(sizeof(ast_node_t));
	if (node == NULL) {
		return NULL;
	}
	memset(node, '\0', sizeof(ast_node_t));
	node->type = type;
	return node;
}

void ast_node_free(ast_node_t *node) {
	if (node->next != NULL) {
		ast_node_free(node->next);
		node->next = NULL;
	}

	switch (node->type) {
		case M_PRINT:
			if (node->value.print.yarn != NULL) {
				free(node->value.print.yarn);
				node->value.print.yarn = NULL;
			}
			break;
	}
	free(node);
	node = NULL;
}
