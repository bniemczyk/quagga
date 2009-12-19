#include "gc.h"
#include <stdlib.h>
#include <stdio.h>

void counting_printer(Context *ctxt, Closure *cont)
{
    ALLOC_CLOSURE(next, 0);
    Variable v;

    int i = ctxt->variables[0]->integer;
    printf("%d\n", i);
    v.integer = i + 1;
    call_closure(build_closure(&next, counting_printer, 0), cont, 1, &v);
}

int main(int argc, char *argv[])
{
    ALLOC_CLOSURE(counting_printer_closure, 0);
    Variable v;
    v.integer = 0;

    // it's safe to pass NULL as the continuation because counting_printer never terminates
    call_closure(build_closure(&counting_printer_closure, counting_printer, 0), NULL, 1, &v);
}
