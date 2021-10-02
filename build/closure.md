# Closures

Closures have always been a little mystical to me so this section is a little therapy for me to demystify something that is hugely useful and, in actual fact, not that crazy.

The scenarios that I am focusing on is where a function is able to access its surrounding scope as a higher-order function.  The technique explored in [Nested Scoping](./nested-scoping.md) requires that the function is not accessible out of the scope in which it is instantiated.  This allows surrounding values to be accessed out of the runtime stack.  When introducing higher-order functions the solution can not rely on the runtime stack as the stack, in all likelihood, would have been unwound.  The surrounding values therefore need to be persisted in the heap.

Let's start with a classic function - functional composition.

```kotlin
fun compose(f: (i32) -> i32, g: (i32) -> i32): (i32) -> i32 =
    (fun (x: i32): i32 = f(g(x)));

fun inc(x: i32): i32 =
    x + 1;

fun double(x: i32): i32 =
    x + x;

fun square(x: i32): i32 =
    x * x;

const transform1: (i32) -> i32 = compose(compose(square, double), inc);
const transform2: (i32) -> i32 = compose(square, compose(double, inc));

fun main() {
    _print_i32(transform1(0));
    _print_newline();

    _print_i32(transform1(1));
    _print_newline();

    _print_i32(transform1(2));
    _print_newline();

    _print_i32(transform2(0));
    _print_newline();

    _print_i32(transform2(1));
    _print_newline();

    _print_i32(transform2(2));
    _print_newline();
}
```

Superfically the compilation of `inc`, `double` and `square` is straightforward.  

```llvm
define i32 @inc(i32 %0) {
    %2 = add i32 %0, 1
    ret i32 %2
}

define i32 @double(i32 %0) {
    %2 = add i32 %0, %0
    ret i32 %2
}

define i32 @square(i32 %0) {
    %2 = mul i32 %0, %0
    ret i32 %2
}
```

Observe though that the two tranform functions are built using `compose` where the arguments passed into `compose` can be either be a closure or a native function.  This then makes it necessary for a closure to represent both.

A closure is structurally defined as

```llvm
%struct.Closure = type { i8*, %struct.Frame* }
%struct.Frame = type { %struct.Frame*, i8* }
```

The first field in `%struct.Closure` is a pointer to the function's code and the second field is a pointer to a stack frame.  The function that this pointer refers to, when called, will pass, in its first parameter, the stack frame followed by all of the supplied parameters.  The `%struct.Frame` has a reference to a containing stack frame and a pointer to the state - this state can be structured in any way and its representation is dependent on the function in question.

Calling a single argument closure is captured in the following helper function.

```llvm
define i8* @_call_1(%struct.Closure* %0, i8* %1) {
  %3 = getelementptr inbounds %struct.Closure, %struct.Closure* %0, i32 0, i32 0
  %4 = load i8*, i8** %3
  %5 = bitcast i8* %4 to i8* (i8*, i8*)*

  %6 = getelementptr inbounds %struct.Closure, %struct.Closure* %0, i32 0, i32 1
  %7 = load %struct.Frame*, %struct.Frame** %6
  %8 = bitcast %struct.Frame* %7 to i8*

  %9 = call i8* %5(i8* %8, i8* %1)
  ret i8* %9
}
```

Now in order to make the native functions appear as a closure it is necessary to wrap each of the native functions into a closure.  This is done using the helper function `@_mk_native_closure_1`.

```llvm
define %struct.Closure* @_mk_native_closure_1(i8* %0) {
    %2 = call i8* @malloc(i64 16)
    %3 = bitcast i8* %2 to %struct.Frame*
    %4 = getelementptr inbounds %struct.Frame, %struct.Frame* %3, i32 0, i32 0
    store %struct.Frame* null, %struct.Frame** %4
    %5 = getelementptr inbounds %struct.Frame, %struct.Frame* %3, i32 0, i32 1
    store i8* %0, i8** %5

    %6 = call i8* @malloc(i64 16) #3
    %7 = bitcast i8* %6 to %struct.Closure*
    %8 = getelementptr inbounds %struct.Closure, %struct.Closure* %7, i32 0, i32 0
    store i8* bitcast (i8* (%struct.Frame*, i8*)* @_wrap_native_1 to i8*), i8** %8

    %9 = getelementptr inbounds %struct.Closure, %struct.Closure* %7, i32 0, i32 1
    store %struct.Frame* %3, %struct.Frame** %9
    ret %struct.Closure* %7
}
```

which makes reference to `@_wrap_native_1`. This function is invoked at runtime with the purpose of dropping the stack frame off of the invocation to the native function.

```llvm
define i8* @_wrap_native_1(%struct.Frame* %0, i8* %1) {
  %3 = getelementptr inbounds %struct.Frame, %struct.Frame* %0, i32 0, i32 1
  %4 = load i8*, i8** %3
  %5 = bitcast i8* %4 to i8* (i8*)*
  %6 = call i8* %5(i8* %1)
  ret i8* %6
}
```

To assist with understand the wrapping of native functions note that the native function pointer is held in the stack frame's state.

From the above this is all pulled together into the following compilation.

```llvm
```

This code, when executed, displays the following.

```
```

Some notes related to this implementation:

- The allocated memory to store the anonymous function `(fun (x: i32): i32 = f(g(x)))` is never discarded.  For this strategy to be practical either a garbage collector will need to be employed or a more sophisticated means of memory management.

