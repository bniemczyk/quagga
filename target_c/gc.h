#ifndef _GC_H
#define _GC_H

#include <stdlib.h>

typedef enum 
{
    PVT_INT,
    PVT_CLOSURE
} PrimitiveVarType;

struct Closure_struct;

typedef struct 
{
    PrimitiveVarType type : 4;
    unsigned int painted : 1;

    union
    {
        int integer;
        struct Closure_struct *closure;
    };

    void *heapptr;
} Variable;

#define ALLOC_VAR(name, var_type) \
    Variable name; \
    do { \
        name.type = var_type; \
        name.heapptr = NULL; \
    } while(0)

typedef struct 
{
    size_t var_count;
    Variable **variables;
} Context;

typedef struct Closure_struct
{
    Context *context;
    void (*function) (Context *ctxt, struct Closure_struct *cont);
} Closure;

typedef void (*closure_func) (Context *ctxt, Closure *cont);

extern void call_closure(Closure *target, Closure *continuation, size_t arg_count, ...);

#define ALLOC_CLOSURE(name, varcount) \
    Closure name; \
    do { \
        if(varcount > 0) \
        { \
            (name).context = alloca(sizeof(Context)); \
            (name).context->variables = alloca(sizeof(Variable *) * varcount); \
        } \
        else \
        { \
            (name).context = NULL; \
        } \
    } while(0)

extern Closure *build_closure(Closure *target, closure_func f, size_t arg_count, ...);

#define MAX_STACK_SIZE (128 * 1024)

#endif
