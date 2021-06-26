; ModuleID = 'calculated-constant-2.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@SOME_NUMBER = global i32 0

define i32 @arb_function(i32 %0) {
  %2 = mul i32 %0, %0
  ret i32 %2
}

define i32 @main() {
  call void @_initialise_lib()                 ; Initialise runtime system

  ; Initialise @SOME_NUMBER
  %1 = call i32 @arb_function(i32 23)
  %2 = add i32 123, %1
  store i32 %2, i32* @SOME_NUMBER             ; Save the caculated result to @SOME_NUMBER

  ; Now let's print @SOME_NUMBER
  %3 = load i32, i32* @SOME_NUMBER
  call void @_print_i32(i32 %3)
  call void @_print_newline()
  ret i32 0
}
