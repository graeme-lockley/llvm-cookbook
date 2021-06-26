/* Library to link into compiled code
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "./lib.h"

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
