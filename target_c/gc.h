#ifndef _GC_H
#define _GC_H

#include <stdlib.h>

typedef enum 
{
    PVT_REF,
    PVT_CHAR,
    PVT_INT,
    PVT_DOUBLE
} PrimitiveVarType;

typedef struct 
{
    PrimitiveVarType type;
    union
    {
        void *reference;
        char character;
        int integer;
        double decimal;
    };
} Variable;

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

#endif
