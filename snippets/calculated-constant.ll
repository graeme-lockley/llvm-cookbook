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
