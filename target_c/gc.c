#include <stdlib.h>
#include <setjmp.h>
#include <stdarg.h>
#include <alloca.h>
#include <string.h>

#include "gc.h"

static struct
{
    Closure *target;
    Closure *continuation;
    jmp_buf gc_jmp;
    void *top_of_stack;
} statics;

#define SET_JMP 0
#define LARGE_STACK 1
#define LARGE_HEAP 2

void gc_initialize(Closure *target, Closure *continuation)
{
gc_init:
    int how_we_got_here = setjmp(statics.gc_jmp);

    switch(how_we_got_here)
    {
        case 0: // we set the jmp
            top_of_stack = &how_we_got_here;
            call_closure(target, continuation, 0);
            break;
        default:
    }
}

/*
 * Before calling this, allocate memory for your target closure with ALLOC_CLOSURE
 */
Closure *build_closure(Closure *target, closure_func f, size_t arg_count, ...)
{
    va_list ap;
    int i;

    target->function = f;

    if(arg_count == 0)
    {
        target->context = NULL;
    }
    else
    {
        va_start(ap, arg_count);
        target->context->var_count = arg_count;
        for(i = 0; i < arg_count; i++)
        {
            target->context->variables[i] = va_arg(ap, Variable *);
        }
        va_end(ap);
    }

    return target;
}

/*
 * this function will never return
 */
void call_closure(Closure *target, Closure *continuation, size_t arg_count, ...)
{
    va_list ap;
    int i;
    Context context;

    if(arg_count > 0) 
    {
        va_start(ap, arg_count);
        context.var_count = target->context != NULL ? target->context->var_count + arg_count : arg_count;
        context.variables = alloca(context.var_count * sizeof(Variable *));

        for(i = 0; i < arg_count; i++)
        {
            context.variables[i] = va_arg(ap, Variable *);
        }

        if(target->context != NULL)
        {
            memcpy(&(context.variables[arg_count]), target->context->variables, target->context->var_count * sizeof(Variable *));
        }

        va_end(ap);

        target->function(&context, continuation);
    } 
    else 
    {
        target->function(target->context, continuation);
    }
}
