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
