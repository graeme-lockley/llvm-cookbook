/* Library to link into compiled code
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./lib.h"

struct Frame
{
    struct Frame *parent;
    void *vals;
};

struct Closure
{
    void *function;
    struct Frame *frame;
};

// void *_call_1(struct Closure *c, void *v1)
// {
//     void *(*f)(void *, void *) = c->function;
//     return f(c->frame, v1);
// }

struct _compose_frame {
    struct Closure *f;
    struct Closure *g;
};

// int _compose_anonymous(struct Frame *parent1, int x)
// {
//     struct _compose_frame *frame = (struct _compose_frame *) parent1->vals;
//
//     struct Closure *f = frame->f;
//     struct Closure *g = frame->g;
//
//     return (int)_call_1(f, _call_1(g, (void *)x));
// }

// struct Closure *_compose(struct Closure *f, struct Closure *g)
// {
//     struct Frame *frame = (struct Frame *)malloc(sizeof(struct Frame));
//     frame->parent = NULL;
//     struct _compose_frame *vals = (struct _compose_frame *)malloc(sizeof(struct _compose_frame));
//     vals->f = f;
//     vals->g = g;
//     frame->vals = vals;
//
//     struct Closure *result = (struct Closure *)malloc(sizeof(struct Closure));
//     result->function = _compose_anonymous;
//     result->frame = frame;
//
//     return result;
// }

// void *_wrap_native_1(struct Frame *parent1, void *v1)
// {
//     void *(*f)(void *) = parent1->vals;
//     return f(v1);
// }

// struct Closure *_mk_native_closure_1(void *f)
// {
//     struct Frame *frame = (struct Frame *)malloc(sizeof(struct Frame));
//     frame->parent = NULL;
//     frame->vals = f;

//     struct Closure *closure = (struct Closure *)malloc(sizeof(struct Closure));
//     closure->function = &_wrap_native_1;
//     closure->frame = frame;

//     return closure;
// }

void _initialise_lib()
{
}

void _print_i32(I32 value)
{
    printf("%d", value);
}

void _print_newline(void)
{
    printf("\n");
}
