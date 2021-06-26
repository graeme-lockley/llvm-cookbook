; ModuleID = 'literal-constant.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@MAGIC_NUMBER = constant i32 123

define i32 @main() {
  call void @_initialise_lib()
  %1 = load i32, i32* @MAGIC_NUMBER
  call void @_print_i32(i32 %1)
  call void @_print_newline()
  ret i32 0
}
