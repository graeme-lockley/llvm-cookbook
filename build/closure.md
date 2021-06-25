# Closure

Setting up and passing a closure around has taxed me.  The strategy I am going to show here is based on creating frames and then passing frames into functions thereby allowing the surrounding scope to be accessible.

There are two scenarios that I am going to look at:

- A nested function accesses its surrounding scope however the nested function is never returned as a higher-order function, and
- A nested function accesses its surrounding scope and the nested function is returned as a higher-order function.

The reason for treating these two scenarios are discrete is that the first scenario allows the frames to be stored on the stack whilst the second scenarios require the frames to be stored in the heap.

## Nested Function without Higher-Order Functions

To get going let's look at a piece of code to compile.

```java
public i32 f(const i32 a, const i32 b) {
    const i32 sum = a + b;

    i32 g(const i32 x) {
        const i32 sum2 = a + b + sum;
        return sum2 + x;
    }
            
    return g(sum);
}

public void main() {
    _print_i32(f(1, 2));
    _print_newline();
}        
```

In the above pseudo code a couple of comments are worthwhile:

- The functions `f` and `main` will have the expected signature.
- The compilation of `main` into IR is trivial and does not need to consider closures at all.
- The function `g` has the free variables `a`, `b` and `sum` where `a` and `b` are passed as parameters into its enclosing function whilst `sum` is a local variable in its enclosing function.

From the above comments it is clear that `g` needs to be passed a frame into which `a`, `b` and `sum` are accessible.

```llvm
; ModuleID = 'closure-static-frame.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()
declare void @_fiddle(i8*)

; frame containing a, b and sum
%f_g_frame = type {i32, i32, i32}

define i32 @f_g(%f_g_frame* %frame, i32 %x) {
    %frame-a = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 0
    %a = load i32, i32* %frame-a
    %frame-b = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 1
    %b = load i32, i32* %frame-b
    %1 = add i32 %a, %b
    %frame-sum = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 2
    %sum = load i32, i32* %frame-sum
    %sum2 = add i32 %1, %sum
    %2 = add i32 %sum2, %x
    ret i32 %2
}

define i32 @f(i32 %a, i32 %b) {
    %frame = alloca %f_g_frame, align 8
    %frame-a = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 0
    store i32 %a, i32* %frame-a
    %frame-b = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 1
    store i32 %b, i32* %frame-b
    %sum = add i32 %a, %b
    %frame-sum = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 2
    store i32 %sum, i32* %frame-sum
    %1 = call i32 @f_g(%f_g_frame* %frame, i32 %sum)
    ret i32 %1
}

define i32 @main() {
  call void @_initialise_lib()
  %1 = call i32 @f(i32 1, i32 2)
  call void @_print_i32(i32 %1)
  call void @_print_newline()
  ret i32 0
}
```

This code, when executed, displays the following.

```
9
```

## Nested Function used as a Higher-Order Function

TBD
