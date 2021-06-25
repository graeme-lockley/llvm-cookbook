/* Library to link into compiled code
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./lib.h"

struct f_frame
{
    int a;
    int b;
    int fsum;
};

struct f_g_frame {
    struct f_frame *parent;
    int c;
    int gsum;
};

static int _f_g_h(struct f_g_frame *parent, int d)
{
    int a = parent->parent->a;
    int fsum = parent->parent->fsum;
    int c = parent->c;
    int gsum = parent->gsum;

    return a + fsum + c + gsum + d;
}

static int _f_g(struct f_frame *parent, int c)
{
    struct f_g_frame frame;

    frame.parent = parent;
    frame.c = c;
    int a = parent->a;
    int fsum = parent->fsum;
    frame.gsum = a + fsum;

    return _f_g_h(&frame, frame.gsum);
}

static int _f(int a, int b)
{
    struct f_frame frame;

    frame.a = a;
    frame.b = b;
    frame.fsum = a + b;

    return _f_g(&frame, frame.fsum);
}

void _initialise_lib()
{
    // printf("***** ");
    // _print_i32(_f(1, 2));
    // _print_newline();
}

void _print_i32(I32 value)
{
    printf("%d", value);
}

void _print_newline(void)
{
    printf("\n");
}

