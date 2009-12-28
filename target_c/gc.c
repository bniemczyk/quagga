#include <stdlib.h>
#include <setjmp.h>
#include <stdarg.h>
#include <string.h>
#include <assert.h>

#ifdef __MINGW32__
#include <malloc.h>
#include <windows.h>
#define sleep(x) Sleep((x) * 1000)
#else
#include <alloca.h>
#endif

#include "gc.h"

#define HEAP_BLOCK_SIZE 128 // allocate 128 vars at a time
#define STACK_SIZE (512 * 1024)

static inline void * heap_alloc(size_t size)
{
    return malloc(size);
}

static inline void heap_free(void *heapptr)
{
    free(heapptr);
}

typedef struct heap_block_struct
{
    struct heap_block_struct *next;
    Variable vars[HEAP_BLOCK_SIZE];
} heap_block;

static inline Variable *heap_block_get_index(heap_block *block, size_t index)
{
    if(index < HEAP_BLOCK_SIZE)
        return &(block->vars[index]);

    if(block->next == NULL)
        block->next = heap_alloc(sizeof(heap_block));

    return heap_block_get_index(block->next, index - HEAP_BLOCK_SIZE);
}

typedef struct collected_var_struct
{
    struct collected_var_struct *next;
    Variable *var;
} collected_var_list;

struct
{
    Closure *target;
    Closure *continuation;
    jmp_buf gc_jmp;
    void *top_of_stack;
    struct {
        size_t size;
        heap_block first_block;
    } heap;
    collected_var_list *collected;
} statics;

#define SET_JMP 0
#define LARGE_STACK 1

static inline Variable *get_new_heap_var()
{
    if(statics.collected != NULL)
    {
        Variable *v = statics.collected->var;
        statics.collected = statics.collected->next;
        return v;
    }
    else
    {
        statics.heap.size += 1;
        return heap_block_get_index(&(statics.heap.first_block), statics.heap.size - 2);
    }
}

static void gc_initialize(Closure *target, Closure *continuation)
{
    statics.heap.size = 2;
    int how_we_got_here = setjmp(statics.gc_jmp);

    switch(how_we_got_here)
    {
        case SET_JMP: // we set the jmp
            statics.top_of_stack = &how_we_got_here;
            call_closure(target, continuation, 0);
            break;
        default: // GC has been run
            call_closure(statics.target, statics.continuation, 0);
	    break;
    }
}

typedef void (*variable_visitor) (Variable *);
typedef void (*context_visitor) (Context *);
static inline void gc_walk_variable (Variable *, variable_visitor v_visitor, context_visitor c_visitor);
static inline void gc_walk_context (Context *context, context_visitor cvisitor, variable_visitor v_visitor);

static inline void gc_walk_context(Context *context, context_visitor c_visitor, variable_visitor v_visitor)
{
    int i;

    if(context == NULL)
        return;

    if(c_visitor != NULL)
        c_visitor(context);

    if(context->var_count > 0)
    {
        for(i = 0; i < context->var_count; i++)
        {
            gc_walk_variable(context->variables[i], v_visitor, c_visitor);
        }
    }
}

static inline void gc_walk_variable(Variable *var, variable_visitor v_visitor, context_visitor c_visitor)
{
    if(var == NULL)
        return;

    if(v_visitor != NULL)
        v_visitor(var);

    if(var->type == PVT_CLOSURE)
        gc_walk_context(var->closure->context, c_visitor, v_visitor);
}

static inline void collect_stack_vars(Closure *target, Closure *continuation)
{
    static void paint(Variable *v)
    {
        if(v->heapptr != NULL) // it's already on the heap
            return;

        v->heapptr = get_new_heap_var();
    }

    static void move_to_heap(Variable *v)
    {
        size_t i;

        if(v == v->heapptr)
            return; // it's already done

        switch(v->type)
        {
            case PVT_CLOSURE:
                if(v->closure->context != NULL)
                {
                    for(i = 0; i < v->closure->context->var_count; i++)
                    {
                        v->closure->context->variables[i] = v->closure->context->variables[i]->heapptr;
                    }

                    Context *old = v->closure->context;
                    v->closure->context = heap_alloc(sizeof(Context));
                    memcpy(v->closure->context, old, sizeof(Context));
                }
                break;
            case PVT_INT:
                // nothing special needs to be allocated
                break;
            default:
                assert(!"CODE SHOULD NEVER GET HERE");
                break; // nothing should ever get here
        }

        memcpy(v->heapptr, v, sizeof(Variable));
    }

    gc_walk_context(target->context, NULL, paint);
    gc_walk_context(continuation->context, NULL, paint);
    gc_walk_context(target->context, NULL, move_to_heap);
    gc_walk_context(continuation->context, NULL, move_to_heap);
    statics.target = target;
    statics.continuation = continuation;
    longjmp(statics.gc_jmp, LARGE_STACK);
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
        target->context = &context;
    } 

    if(statics.top_of_stack == NULL)
        gc_initialize(target, continuation);

    if(statics.top_of_stack - ((void *)&i) > STACK_SIZE)
    {
        collect_stack_vars(target, continuation);
    }

    target->function(target->context, continuation);

    assert(!"closure returned, this should never happen");
}
