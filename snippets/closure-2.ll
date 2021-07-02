; ModuleID = 'higher-order-function-2.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()
declare i8* @malloc(i64)

%struct.Closure = type { i8*, %struct.Frame* }
%struct.Frame = type { %struct.Frame*, i8* }
%struct._compose_frame = type { %struct.Closure*, %struct.Closure* }

; Closure for inc(x: i32): i32
@inc_closure_ptr = global %struct.Closure* null

; Closure for double(x: i32): i32
@double_closure_ptr = global %struct.Closure* null

; Closure for square(x: i32): i32
@square_closure_ptr = global %struct.Closure* null

; Value for const transform1: (i32) -> i32
@transform1 = global %struct.Closure* null

; Value for const transform2: (i32) -> i32
@transform2 = global %struct.Closure* null

; The compiled form of the lambda function
;   (fun (x: i32): i32 = f(g(x)))
; defined inside compose.
define i32 @compose_anonymous(%struct.Frame* %0, i32 %1) {
    %3 = getelementptr inbounds %struct.Frame, %struct.Frame* %0, i32 0, i32 1
    %4 = load i8*, i8** %3
    %5 = bitcast i8* %4 to %struct._compose_frame*

    %6 = getelementptr inbounds %struct._compose_frame, %struct._compose_frame* %5, i32 0, i32 0
    %7 = load %struct.Closure*, %struct.Closure** %6
    %8 = getelementptr inbounds %struct._compose_frame, %struct._compose_frame* %5, i32 0, i32 1
    %9 = load %struct.Closure*, %struct.Closure** %8

    %10 = sext i32 %1 to i64
    %11 = inttoptr i64 %10 to i8*
    %12 = call i8* @_call_1(%struct.Closure* %9, i8* %11)
    %13 = call i8* @_call_1(%struct.Closure* %7, i8* %12)
    %14 = ptrtoint i8* %13 to i32

    ret i32 %14
}

; Helper function called whenever a native function is called as a closure.
define i8* @_call_1(%struct.Closure* %0, i8* %1) {
    %3 = getelementptr inbounds %struct.Closure, %struct.Closure* %0, i32 0, i32 0
    %4 = load i8*, i8** %3
    %5 = bitcast i8* %4 to i8* (i8*, i8*)*

    %6 = getelementptr inbounds %struct.Closure, %struct.Closure* %0, i32 0, i32 1
    %7 = load %struct.Frame*, %struct.Frame** %6
    %8 = bitcast %struct.Frame* %7 to i8*

    %9 = call i8* %5(i8* %8, i8* %1)
    ret i8* %9
}

define %struct.Closure* @compose(%struct.Closure* %0, %struct.Closure* %1) {
    %3 = call i8* @malloc(i64 16)
    %4 = bitcast i8* %3 to %struct.Frame*
    %5 = getelementptr inbounds %struct.Frame, %struct.Frame* %4, i32 0, i32 0
    store %struct.Frame* null, %struct.Frame** %5

    %6 = call i8* @malloc(i64 16)
    %7 = bitcast i8* %6 to %struct._compose_frame*
    %8 = getelementptr inbounds %struct._compose_frame, %struct._compose_frame* %7, i32 0, i32 0
    store %struct.Closure* %0, %struct.Closure** %8
    %9 = getelementptr inbounds %struct._compose_frame, %struct._compose_frame* %7, i32 0, i32 1
    store %struct.Closure* %1, %struct.Closure** %9

    %10 = bitcast %struct._compose_frame* %7 to i8*
    %11 = getelementptr inbounds %struct.Frame, %struct.Frame* %4, i32 0, i32 1
    store i8* %10, i8** %11

    %12 = call i8* @malloc(i64 16) #3
    %13 = bitcast i8* %12 to %struct.Closure*
    %14 = getelementptr inbounds %struct.Closure, %struct.Closure* %13, i32 0, i32 0
    store i8* bitcast (i32 (%struct.Frame*, i32)* @compose_anonymous to i8*), i8** %14

    %15 = getelementptr inbounds %struct.Closure, %struct.Closure* %13, i32 0, i32 1
    store %struct.Frame* %4, %struct.Frame** %15
    ret %struct.Closure* %13
}

define i32 @inc(i32 %0) {
    %2 = add i32 %0, 1
    ret i32 %2
}

define i32 @double(i32 %0) {
    %2 = add i32 %0, %0
    ret i32 %2
}

define i32 @square(i32 %0) {
    %2 = mul i32 %0, %0
    ret i32 %2
}

define i8* @_wrap_native_1(%struct.Frame* %0, i8* %1) {
    %3 = getelementptr inbounds %struct.Frame, %struct.Frame* %0, i32 0, i32 1
    %4 = load i8*, i8** %3
    %5 = bitcast i8* %4 to i8* (i8*)*
    %6 = call i8* %5(i8* %1)
    ret i8* %6
}

define %struct.Closure* @_mk_native_closure_1(i8* %0) {
    %2 = call i8* @malloc(i64 16)
    %3 = bitcast i8* %2 to %struct.Frame*
    %4 = getelementptr inbounds %struct.Frame, %struct.Frame* %3, i32 0, i32 0
    store %struct.Frame* null, %struct.Frame** %4
    %5 = getelementptr inbounds %struct.Frame, %struct.Frame* %3, i32 0, i32 1
    store i8* %0, i8** %5

    %6 = call i8* @malloc(i64 16) #3
    %7 = bitcast i8* %6 to %struct.Closure*
    %8 = getelementptr inbounds %struct.Closure, %struct.Closure* %7, i32 0, i32 0
    store i8* bitcast (i8* (%struct.Frame*, i8*)* @_wrap_native_1 to i8*), i8** %8

    %9 = getelementptr inbounds %struct.Closure, %struct.Closure* %7, i32 0, i32 1
    store %struct.Frame* %3, %struct.Frame** %9
    ret %struct.Closure* %7
}

define i32 @main() {
    call void @_initialise_lib()

    ; Create closure wrapping 
    %inc_closure_ptr = call %struct.Closure* @_mk_native_closure_1(i8* bitcast (i32 (i32)* @inc to i8*))
    store %struct.Closure* %inc_closure_ptr, %struct.Closure** @inc_closure_ptr
    %double_closure_ptr = call %struct.Closure* @_mk_native_closure_1(i8* bitcast (i32 (i32)* @double to i8*))
    store %struct.Closure* %inc_closure_ptr, %struct.Closure** @double_closure_ptr
    %square_closure_ptr = call %struct.Closure* @_mk_native_closure_1(i8* bitcast (i32 (i32)* @square to i8*))
    store %struct.Closure* %inc_closure_ptr, %struct.Closure** @square_closure_ptr

    %1 = call %struct.Closure* @compose(%struct.Closure* %square_closure_ptr, %struct.Closure* %double_closure_ptr)
    %2 = call %struct.Closure* @compose(%struct.Closure* %1, %struct.Closure* %inc_closure_ptr)
    store %struct.Closure* %2, %struct.Closure** @transform1

    %3 = call %struct.Closure* @compose(%struct.Closure* %double_closure_ptr, %struct.Closure* %inc_closure_ptr)
    %4 = call %struct.Closure* @compose(%struct.Closure* %square_closure_ptr, %struct.Closure* %3)
    store %struct.Closure* %4, %struct.Closure** @transform2

    ; _print_i32(transform1(0));
    %5 = call i8* @_call_1(%struct.Closure* %2, i8* inttoptr (i64 0 to i8*))
    %6 = ptrtoint i8* %5 to i32
    call void @_print_i32(i32 %6)

    ; _print_newline();
    call void @_print_newline()

    ; _print_i32(transform1(1));
    %7 = call i8* @_call_1(%struct.Closure* %2, i8* inttoptr (i64 1 to i8*))
    %8 = ptrtoint i8* %7 to i32
    call void @_print_i32(i32 %8)

    ; _print_newline();
    call void @_print_newline()

    ; _print_i32(transform1(2));
    %9 = call i8* @_call_1(%struct.Closure* %2, i8* inttoptr (i64 2 to i8*))
    %10 = ptrtoint i8* %9 to i32
    call void @_print_i32(i32 %10)

    ; _print_newline();
    call void @_print_newline()

    ; _print_i32(transform2(0));
    %11 = call i8* @_call_1(%struct.Closure* %4, i8* inttoptr (i64 0 to i8*))
    %12 = ptrtoint i8* %11 to i32
    call void @_print_i32(i32 %12)

    ; _print_newline();
    call void @_print_newline()

    ; _print_i32(transform2(1));
    %13 = call i8* @_call_1(%struct.Closure* %4, i8* inttoptr (i64 1 to i8*))
    %14 = ptrtoint i8* %13 to i32
    call void @_print_i32(i32 %14)

    ; _print_newline();
    call void @_print_newline()

    ; _print_i32(transform2(2));
    %15 = call i8* @_call_1(%struct.Closure* %4, i8* inttoptr (i64 2 to i8*))
    %16 = ptrtoint i8* %15 to i32
    call void @_print_i32(i32 %16)

    ; _print_newline();
    call void @_print_newline()

    ret i32 0
}
