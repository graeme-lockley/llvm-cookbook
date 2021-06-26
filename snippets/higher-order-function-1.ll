; ModuleID = 'higher-order-function-1.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@f = global i32 (i32)* null

define i32 @plus1(i32 %0) {
    %2 = add i32 %0, 1
    ret i32 %2
}

define i32 @main() {
    call void @_initialise_lib()

    ; @f = plus1
    store i32 (i32)* @plus1, i32 (i32)** @f, align 8

    ; _print_i32(f(10));
    %1 = load i32 (i32)*, i32 (i32)** @f, align 8
    %2 = call i32 %1(i32 10)

    call void @_print_i32(i32 %2)

    ; _print_newline();
    call void @_print_newline()

    ret i32 0
}
