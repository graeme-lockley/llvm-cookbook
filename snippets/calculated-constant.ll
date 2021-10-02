; ModuleID = 'calculated-constant.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@MAGIC_NUMBER = global i32 0

define i32 @main() {
  call void @_initialise_lib()                 ; Initialise runtime system

  ; Initialise @MAGIC_NUMBER
  %1 = add i32 123, 654
  store i32 %1, i32* @MAGIC_NUMBER             ; Save the calculated result to @MAGIC_NUMBER

  ; Now let's print @MAGIC_NUMBER
  %2 = load i32, i32* @MAGIC_NUMBER
  call void @_print_i32(i32 %2)
  call void @_print_newline()
  ret i32 0
}
