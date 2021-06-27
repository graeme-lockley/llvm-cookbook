# Closures

Closures have always been a little mystical to me so this section is a little therapy for me to demystify something that is hugely useful and, in actual fact, not that crazy.

The scenarios that I am focusing on is where a function is able to access its surrounding scope as a higher-order function.  The technique explored in [Nested Scoping](./nested-scoping.md) requires that the function is not accessible out of the scope in which it is instantiated.  This allows surrounding values to be accessed out of the runtime stack.  When introducing higher-order functions the solution can not rely on the runtime stack as the stack, in all likelihood, would have been unwound.  The surrounding values therefore need to be persisted in the heap.

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
$$ cat ./snippets/higher-order-function-2.ll
```

This code, when executed, displays the following.

```
$$ cat ./snippets/higher-order-function-2.out
```
