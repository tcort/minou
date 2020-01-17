#include "config.h"

#include <stddef.h>
#include <stdio.h>

#include "ast.h"
#include "interpret.h"

void interpret(ast_node_t *node) {
	ast_node_t *cur;

	for (cur = node->next; cur != NULL; cur = cur->next) {
		switch (cur->type) {
			case M_PRINT:
				printf(
					cur->value.print.newline ? "%s\n" : "%s",
					cur->value.print.yarn
				);
				break;
		}
	}
}
