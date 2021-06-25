# Closure

Setting up and passing a closure around has taxed me.  The strategy I am going to show here is based on creating frames and then passing frames into functions thereby allowing the surrounding scope to be accessible.

There are two scenarios that I am going to look at:

- A nested function accesses its surrounding scope however the nested function is never returned as a higher-order function, and
- A nested function accesses its surrounding scope and the nested function is returned as a higher-order function.

The reason for treating these two scenarios are discrete is that the first scenario allows the frames to be stored on the stack whilst the second scenarios require the frames to be stored in the heap.

## Nested Function without Higher-Order Functions

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

- The functions `f` and `main` will have the expected signature.
- The compilation of `main` into IR is trivial and does not need to consider closures at all.
- The function `g` has the free variables `a`, `b` and `sum` where `a` and `b` are passed as parameters into its enclosing function whilst `sum` is a local variable in its enclosing function.

From the above comments it is clear that `g` needs to be passed a frame into which `a`, `b` and `sum` are accessible.

```llvm
$$ cat ./snippets/closure-static-frame.ll
```

This code, when executed, displays the following.

```
$$ cat ./snippets/closure-static-frame.out
```

Some comments:

- In my minds eye I can see the stack growing faster than it needs to be.  In this example `a` and `b` are placed on the runtime stack and then, when wrapped into `%f_frame` are duplicated.  I am sure there is native support for dealing with this but I have not been able to see how.
- Even though the pseudo-code has marked everything as `const`, this strategy will work if the elements in `%f_frame` where to be updated.
- The compiled code accepts a pointer to a frame - this implies then that the code in `@f_g` does not know whether or not that frame is on the stack or in the heap.

The example above shows nicely how a frame can be used to access values from the immediately enclosing scope.  However, when looking at the following code, we need a general solution.

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
$$ cat ./snippets/closure-static-frame-2.ll
```

This code, when executed, displays the following.

```
$$ cat ./snippets/closure-static-frame-2.out
```


## Nested Function used as a Higher-Order Function

TBD
