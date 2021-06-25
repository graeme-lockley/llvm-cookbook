; ModuleID = 'closure-static-frame.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()
declare void @_fiddle(i8*)

; frame containing a, b and sum
%f_g_frame = type {i32, i32, i32}

define i32 @f_g(%f_g_frame* %frame, i32 %x) {
    %frame-a = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 0
    %a = load i32, i32* %frame-a
    %frame-b = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 1
    %b = load i32, i32* %frame-b
    %1 = add i32 %a, %b
    %frame-sum = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 2
    %sum = load i32, i32* %frame-sum
    %sum2 = add i32 %1, %sum
    %2 = add i32 %sum2, %x
    ret i32 %2
}

define i32 @f(i32 %a, i32 %b) {
    %frame = alloca %f_g_frame, align 8
    %frame-a = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 0
    store i32 %a, i32* %frame-a
    %frame-b = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 1
    store i32 %b, i32* %frame-b
    %sum = add i32 %a, %b
    %frame-sum = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 2
    store i32 %sum, i32* %frame-sum
    %1 = call i32 @f_g(%f_g_frame* %frame, i32 %sum)
    ret i32 %1
}

define i32 @main() {
  call void @_initialise_lib()
  %1 = call i32 @f(i32 1, i32 2)
  call void @_print_i32(i32 %1)
  call void @_print_newline()
  ret i32 0
}
