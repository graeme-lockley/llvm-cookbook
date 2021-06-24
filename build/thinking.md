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
; ModuleID = 'literal-constant.ll'
target triple = "x86_64-pc-linux-gnu"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@MAGIC_NUMBER = constant i32 123, align 8

define i32 @main() {
  call void @_initialise_lib()
  %1 = load i32, i32* @MAGIC_NUMBER, align 8
  call void @_print_i32(i32 %1)
  call void @_print_newline()
  ret i32 0
}
```

Running this gives the expected result

```
123
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
; ModuleID = 'calculated-constant.ll'
target triple = "x86_64-pc-linux-gnu"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@MAGIC_NUMBER = global i32 0, align 8

define i32 @main() {
  call void @_initialise_lib()                 ; Initialise runtime system

  ; Initialise @MAGIC_NUMBER
  %1 = add i32 123, 654
  store i32 %1, i32* @MAGIC_NUMBER, align 8    ; Save the caculated result to @MAGIC_NUMBER

  ; Now let's print @MAGIC_NUMBER
  %2 = load i32, i32* @MAGIC_NUMBER, align 8  
  call void @_print_i32(i32 %2)
  call void @_print_newline()
  ret i32 0
}
```

which, when run, returns the following result.

```
777
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
; ModuleID = 'calculated-constant-2.ll'
target triple = "x86_64-pc-linux-gnu"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@MAGIC_NUMBER = global i32 0, align 8

define i32 @arb_function(i32 %0) {
  %2 = mul i32 %0, %0
  ret i32 %2
}

define i32 @main() {
  call void @_initialise_lib()                 ; Initialise runtime system

  ; Initialise @MAGIC_NUMBER
  %1 = call i32 @arb_function(i32 23)
  %2 = add i32 123, %1
  store i32 %2, i32* @MAGIC_NUMBER, align 8    ; Save the caculated result to @MAGIC_NUMBER

  ; Now let's print @MAGIC_NUMBER
  %3 = load i32, i32* @MAGIC_NUMBER, align 8  
  call void @_print_i32(i32 %3)
  call void @_print_newline()
  ret i32 0
}
```

which, when run, returns the following result.

```
652
```
