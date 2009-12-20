#include "gc.h"
#include <stdlib.h>
#include <stdio.h>

void counting_printer(Context *ctxt, Closure *cont)
{
    ALLOC_CLOSURE(next, 0);
    build_closure(&next, counting_printer, 0);

    ALLOC_VAR(v, PVT_INT);
    v.integer = ctxt->variables[0]->integer;
    printf("%d\n", v.integer);
    v.integer++;
    call_closure(&next, cont, 1, &v);
}

int main(int argc, char *argv[])
{
    ALLOC_CLOSURE(counting_printer_closure, 0);
    build_closure(&counting_printer_closure, counting_printer, 0);

    ALLOC_CLOSURE(empty_closure, 0);
    build_closure(&empty_closure, counting_printer, 0);

    ALLOC_VAR(v, PVT_INT);
    v.integer = 0;

    // it's safe to pass NULL as the continuation because counting_printer never terminates
    call_closure(&counting_printer_closure, &empty_closure, 1, &v);
}
