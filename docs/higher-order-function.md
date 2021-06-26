# Higher-Order Function

A language that supports higher-order functions is a language that treats functions as values allowing these values to be manipulated.  The scenarios looked at here only consider functions that have no free variables - in other words they accept arguments, return a result and, in their body, only reference global state.

Taking a look at the following program.

```java
fn plus1(i32 n) -> i32 {
    return n + 1;
}

const (i32 -> i32) f = plus1;

fn main() {
    _print_i32(f(10));
    _print_newline();
}
```

The function `plus1` is defined as usual however the global variable `f` is initialised as a reference to `plus1` and then invoked in `main` with the result displayed.  This is then compiled as follows.

```llvm
$$ cat ./snippets/higher-order-function-1.ll
```

This code, when executed, displays the following.

```
$$ cat ./snippets/higher-order-function-1.out
```

The preceding example was useful in illustrating how a reference to a function can be passed around and called.  To show how a function can be manipulated the following code creates the classic functional composition.

```java
fn plus1(i32 n) -> i32 {
    return n + 1;
}

fn double(i32 n) -> i32 {
    return n + n;
}

fn compose((i32 -> i32) f, (i32 -> i32) g) -> (i32 -> i32) {
    return (fn (i32 x) -> f(g(x)));
}

const (i32 -> i32) doubleplus1 = compose(double, plus1);

fn main() {
    _print_i32(doubleplus1(10));
    _print_newline();
}
```

The compilation of `plus1` and `double` is straightforward.  The general strategy of creating a function value is to store it is a structure with the first value in the structure being a reference to a function pointer and the remaining values in the structure containing the values that make up the closure.  For our example the structure is defined as

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
