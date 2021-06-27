; ModuleID = 'closure-static-frame-2.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()

; f_frame containing a, b and fsum
%f_frame = type {i32, i32, i32}

; f_g_frame containing parent, c and gsum
%f_g_frame = type {%f_frame*, i32, i32}

define i32 @f_g_h(%f_g_frame* %parent_frame, i32 %d) {
    %1 = getelementptr inbounds %f_g_frame, %f_g_frame* %parent_frame, i32 0, i32 0
    %parent = load %f_frame*, %f_frame** %1

    %2 = getelementptr inbounds %f_frame, %f_frame* %parent, i32 0, i32 0
    %a = load i32, i32* %2

    %3 = getelementptr inbounds %f_frame, %f_frame* %parent, i32 0, i32 2
    %fsum = load i32, i32* %3

    %4 = add i32 %a, %fsum

    %5 = getelementptr inbounds %f_g_frame, %f_g_frame* %parent_frame, i32 0, i32 1
    %c = load i32, i32* %5
    %6 = add i32 %4, %c

    %7 = getelementptr inbounds %f_g_frame, %f_g_frame* %parent_frame, i32 0, i32 2
    %gsum = load i32, i32* %7

    %8 = add i32 %6, %gsum
    %9 = add i32 %8, %d

    ret i32 %9
}

define i32 @f_g(%f_frame* %parent_frame, i32 %c) {
    %frame = alloca %f_g_frame

    %1 = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 0
    store %f_frame* %parent_frame, %f_frame** %1

    %2 = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 1
    store i32 %c, i32* %2

    %3 = getelementptr inbounds %f_frame, %f_frame* %parent_frame, i32 0, i32 0
    %a = load i32, i32* %3

    %4 = getelementptr inbounds %f_frame, %f_frame* %parent_frame, i32 0, i32 2
    %fsum = load i32, i32* %4

    %gsum = add i32 %a, %fsum

    %5 = getelementptr inbounds %f_g_frame, %f_g_frame* %frame, i32 0, i32 2
    store i32 %gsum, i32* %5

    %6 = call i32 @f_g_h(%f_g_frame* %frame, i32 %gsum)
    
    ret i32 %6
}

define i32 @f(i32 %a, i32 %b) {
    %frame = alloca %f_frame

    %1 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 0
    store i32 %a, i32* %1

    %2 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 1
    store i32 %b, i32* %2

    %fsum = add i32 %a, %b

    %3 = getelementptr inbounds %f_frame, %f_frame* %frame, i32 0, i32 2
    store i32 %fsum, i32* %3

    %4 = call i32 @f_g(%f_frame* %frame, i32 %fsum)

    ret i32 %4
}

define i32 @main() {
    call void @_initialise_lib()
    %1 = call i32 @f(i32 1, i32 2)
    call void @_print_i32(i32 %1)
    call void @_print_newline()
    ret i32 0
}
