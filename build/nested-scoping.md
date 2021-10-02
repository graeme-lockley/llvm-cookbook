# Nested Scoping

Setting up and passing a closure around has taxed me.  The strategy I am going to show here is based on creating frames and then passing frames into functions thereby allowing the surrounding scope to be accessible.

The specific scenario is one of static nested functions - a static nested function accesses its surrounding scope however the nested function is never returned as a higher-order function.  This scenario allows the surrounding scope to be accessed from the runtime stack because, when the nested function is executed, the calling stack is in place.

To get going let's look at a piece of code to compile.

```java
fn f(const i32 a, const i32 b) -> i32 {
    const i32 sum = a + b;

    fn g(const i32 x) -> i32 {
        const i32 sum2 = a + b + sum;
        return sum2 + x;
    }
            
    return g(sum);
}

fn main() {
    _print_i32(f(1, 2));
    _print_newline();
}        
```

In the above pseudo code a couple of comments are worthwhile:

- The compiled functions for `f` and `main` will have the expected signature.
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

; frame containing a, b and sum
%f_frame = type {i32, i32, i32}

define i32 @f_g(%f_frame* %frame, i32 %x) {
    %1 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 0
    %a = load i32, i32* %1

    %2 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 1
    %b = load i32, i32* %2

    %3 = add i32 %a, %b

    %4 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 2
    %sum = load i32, i32* %4

    %sum2 = add i32 %3, %sum

    %5 = add i32 %sum2, %x

    ret i32 %5
}

define i32 @f(i32 %a, i32 %b) {
    %frame = alloca %f_frame

    %1 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 0
    store i32 %a, i32* %1

    %2 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 1
    store i32 %b, i32* %2

    %sum = add i32 %a, %b

    %3 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 2
    store i32 %sum, i32* %3

    %4 = call i32 @f_g(%f_frame* %frame, i32 %sum)

    ret i32 %4
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
```

Some comments:

- In my minds eye I can see the stack growing faster than it needs to be.  In this example `a` and `b` are placed on the runtime stack and then, when wrapped into `%f_frame` are duplicated.  I am sure there is native support for dealing with this but I have not been able to see how.
- Even though the pseudo-code has marked everything as `const`, this strategy will work if the elements in `%f_frame` where to be updated.
- The compiled code accepts a pointer to a frame - this implies then that the code in `@f_g` does not know whether or not that frame is on the stack or in the heap.

The preceding example shows nicely how a frame can be used to access values from the immediately enclosing scope.  However, when looking at the following code, we need a general solution.

```java
fn f(const i32 a, const i32 b) -> i32 {
    const i32 fsum = a + b;

    fn g(const i32 c) -> i32 {
        const i32 gsum = a + fsum;

        fn h(const i32 d) -> i32 {
            return a + fsum + c + gsum + d;
        }

        return h(gsum);
    }

    return g(fsum);
}

fn main() {
    _print_i32(f(1, 2));
    _print_newline();
}        
```

There are two frames at play when compiling this program - a frame associated with `f` (`%f_frame`) which is passed into `g` and a frame associated with `g` (`%f_g_frame`) which is passed into `h`.  To get this done we will have the `%f_g_frame` have a reference back to the `%f_frame` rather than embed the contents of the `%f_frame` into the `%f_g_frame`.

Using this two frame approach we have the following result.

```llvm
; ModuleID = 'closure-static-frame-2.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

; f_frame containing a, b and fsum
%f_frame = type {i32, i32, i32}

; f_g_frame containing parent, c and gsum
%f_g_frame = type {%f_frame*, i32, i32}

define i32 @f_g_h(%f_g_frame* %parent_frame, i32 %d) {
    %1 = getelementptr inbounds %f_g_frame, %f_g_frame* %parent_frame, i32 0, i32 0
    %parent = load %f_frame*, %f_frame** %1

    %2 = getelementptr inbounds %f_frame, %f_frame* %parent, i32 0, i32 0
    %a = load i32, i32* %2

    %3 = getelementptr inbounds %f_frame, %f_frame* %parent, i32 0, i32 2
    %fsum = load i32, i32* %3

    %4 = add i32 %a, %fsum

    %5 = getelementptr inbounds %f_g_frame, %f_g_frame* %parent_frame, i32 0, i32 1
    %c = load i32, i32* %5
    %6 = add i32 %4, %c

    %7 = getelementptr inbounds %f_g_frame, %f_g_frame* %parent_frame, i32 0, i32 2
    %gsum = load i32, i32* %7

    %8 = add i32 %6, %gsum
    %9 = add i32 %8, %d

    ret i32 %9
}

define i32 @f_g(%f_frame* %parent_frame, i32 %c) {
    %frame = alloca %f_g_frame

    %1 = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 0
    store %f_frame* %parent_frame, %f_frame** %1

    %2 = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 1
    store i32 %c, i32* %2

    %3 = getelementptr inbounds %f_frame, %f_frame* %parent_frame, i32 0, i32 0
    %a = load i32, i32* %3

    %4 = getelementptr inbounds %f_frame, %f_frame* %parent_frame, i32 0, i32 2
    %fsum = load i32, i32* %4

    %gsum = add i32 %a, %fsum

    %5 = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 2
    store i32 %gsum, i32* %5

    %6 = call i32 @f_g_h(%f_g_frame* %frame, i32 %gsum)
    
    ret i32 %6
}

define i32 @f(i32 %a, i32 %b) {
    %frame = alloca %f_frame

    %1 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 0
    store i32 %a, i32* %1

    %2 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 1
    store i32 %b, i32* %2

    %fsum = add i32 %a, %b

    %3 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 2
    store i32 %fsum, i32* %3

    %4 = call i32 @f_g(%f_frame* %frame, i32 %fsum)

    ret i32 %4
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
```
