; ModuleID = 'literal-constant.ll'
target triple = "x86_64-pc-linux-gnu"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

@MAGIC_NUMBER = global i32 123, align 8

define i32 @main() {
  call void @_initialise_lib()
  %1 = load i32, i32* @MAGIC_NUMBER, align 8
  call void @_print_i32(i32 %1)
  call void @_print_newline()
  ret i32 0
}
