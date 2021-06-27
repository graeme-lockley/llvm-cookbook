# Closures

Closures have always been a little mystical to me so this section is a little therapy for me to demystify something that is hugely useful and, in actual fact, not that crazy.

The scenarios that I am focusing on is where a function is abel to access its surrounding scope as a higher-order function.  The technique explored in [Nested Scoping](./nested-scoping.md) requires that the function is not accessible out of the scope in which it is instantiated.  This allows surrounding values to be accessed out of the runtime stack.  When introducing higher-order functions the solution can not rely on the runtime stack as the stack, in all likelihood, would have been unwound.  The surrounding values therefore need to be persisted in the heap.

Let's start with a classic function - functional composition.

```java
fn plus1(const i32 n) -> i32 {
    return n + 1;
}

fn double(const i32 n) -> i32 {
    return n + n;
}

fn compose(const (i32 -> i32) f, const (i32 -> i32) g) -> (i32 -> i32) {
    return (fn (i32 x) -> f(g(x)));
}

const (i32 -> i32) doubleplus1 = compose(double, plus1);

fn main() {
    _print_i32(doubleplus1(10));
    _print_newline();
}
```

The compilation of `plus1` and `double` is straightforward.  The general strategy of creating a function value is to store it in a structure with the structure's first value being a reference to a function pointer and the remaining values in the structure containing the values that make up the closure.  For our example the structure is defined as

```llvm
%composure_closure = type { i32 (%composure_closure*, i32)*, i32 (i32)*, i32 (i32)* }
```

Values 1 and 2 correspond to the values `f` and `g`.  Further we compile the anonymous function `(fn (i32 x) -> f(g(x)))` into `call_compose` which extracts the `f` and `g` from the closure and performs the function composition.


```llvm
; ModuleID = 'higher-order-function-2.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()
declare i8* @malloc(i64)

; The compose closure's state is made up of the apply function and the functions
; f and g.  You will notice that the apply function takes an instance of %composure_closure
; as argument and then the value x.  This first parameter is synonomous with Java and 
; JavaScript's this.
%composure_closure = type { i32 (%composure_closure*, i32)*, i32 (i32)*, i32 (i32)* }

@doubleplus1 = global %composure_closure* null

define i32 @plus1(i32 %0) {
    %2 = add i32 %0, 1
    ret i32 %2
}

define i32 @double(i32 %0) {
    %2 = add i32 %0, %0
    ret i32 %2
}

define i32 @call_compose(%composure_closure* %this, i32 %x) {
    %1 = getelementptr inbounds %composure_closure, %composure_closure* %this, i32 0, i32 1
    %f = load i32 (i32)*, i32 (i32)** %1
    
    %2 = getelementptr inbounds %composure_closure, %composure_closure* %this, i32 0, i32 2
    %g = load i32 (i32)*, i32 (i32)** %2

    %3 = call i32 %g(i32 %x)
    %4 = call i32 %f(i32 %3)

    ret i32 %4
}

define %composure_closure* @compose(i32 (i32)* %f, i32 (i32)* %g) {
    %1 = call i8* @malloc(i64 24)
    %2 = bitcast i8* %1 to %composure_closure*
    
    %3 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 0
    store i32 (%composure_closure*, i32)* @call_compose, i32 (%composure_closure*, i32)** %3
    
    %4 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 1
    store i32 (i32)* %f, i32 (i32)** %4

    %5 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 2
    store i32 (i32)* %g, i32 (i32)** %5
    
    ret %composure_closure* %2
}

define i32 @main() {
    call void @_initialise_lib()

    ; doubleplus1 = compose(double, plus1)
    %1 = call %composure_closure* @compose(i32 (i32)* @double, i32 (i32)* @plus1)
    store %composure_closure* %1, %composure_closure** @doubleplus1

    ; _print_i32(doubleplus1(10));
    %2 = load %composure_closure*, %composure_closure** @doubleplus1
    %3 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 0
    %4 = load i32 (%composure_closure*, i32)*, i32 (%composure_closure*, i32)** %3
    %5 = call i32 %4(%composure_closure* %2, i32 10)
    call void @_print_i32(i32 %5)

    ; _print_newline();
    call void @_print_newline()

    ret i32 0
}
```

This code, when executed, displays the following.

```
22
```
