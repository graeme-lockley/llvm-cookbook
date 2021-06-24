# Constant Global Variable

A constant global variable comes in multiple flavours:

- A literal constant which can be assigned when declaring the variable, and
- A calculated constant which can only be assigned through executing some code.

## Literal Constant

So the following code:

```java
const i32 MAGIC_NUMBER = 123;

public void main() {
    _print_i32(MAGIC_NUMBER);
    _println();
}
```

can be translated into

```llvm
$$ cat ./snippets/literal-constant.ll
```

Running this gives the expected result

```
$$ cat ./snippets/literal-constant.out
```

## Calculated Constant

The following code is an example of a calculated constant.

```java
const i32 MAGIC_NUMBER = 123 + 654;

public void main() {
    _print_i32(MAGIC_NUMBER);
    _println();
}
```

I realise that `MAGIC_NUMBER` can be replaced with the literal constant `777` however, for the sake of illustration, let's not do that but rather treat it is an arbitrary expression.

```llvm
$$ cat ./snippets/calculated-constant.ll
```

which, when run, returns the following result.

```
$$ cat ./snippets/calculated-constant.out
```

Returning to the calculated constant, the calculation can contain an arbitrary expression calling IR functions.  For example, using the technique above

```java
const i32 SOME_NUMBER = 123 + arb_function(23);

public i32 arb_function(i32 a) {
    return a * a;
}

public void main() {
    _print_i32(SOME_NUMBER);
    _println();
}
```

is expressed as

```llvm
$$ cat ./snippets/calculated-constant-2.ll
```

which, when run, returns the following result.

```
$$ cat ./snippets/calculated-constant-2.out
```
