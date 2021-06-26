; ModuleID = 'higher-order-function-2.ll'
target triple = "x86_64-pc-linux-gnu"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

declare void @_initialise_lib()
declare void @_print_i32(i32)
declare void @_print_newline()
declare i8* @malloc(i64)

; The compose closure's state is made up of the apply function and the functions
; f and g.  You will notice that the apply function takes an instance of %composure_closure
; as argument and then the value x.  This first parameter is synonomous with Java and 
; JavaScript's this.
%composure_closure = type { i32 (%composure_closure*, i32)*, i32 (i32)*, i32 (i32)* }

@doubleplus1 = global %composure_closure* null

define i32 @plus1(i32 %0) {
    %2 = add i32 %0, 1
    ret i32 %2
}

define i32 @double(i32 %0) {
    %2 = add i32 %0, %0
    ret i32 %2
}

define i32 @call_compose(%composure_closure* %this, i32 %x) {
    %1 = getelementptr inbounds %composure_closure, %composure_closure* %this, i32 0, i32 1
    %f = load i32 (i32)*, i32 (i32)** %1
    
    %2 = getelementptr inbounds %composure_closure, %composure_closure* %this, i32 0, i32 2
    %g = load i32 (i32)*, i32 (i32)** %2

    %3 = call i32 %g(i32 %x)
    %4 = call i32 %f(i32 %3)

    ret i32 %4
}

define %composure_closure* @compose(i32 (i32)* %f, i32 (i32)* %g) {
    %1 = call i8* @malloc(i64 24)
    %2 = bitcast i8* %1 to %composure_closure*
    
    %3 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 0
    store i32 (%composure_closure*, i32)* @call_compose, i32 (%composure_closure*, i32)** %3
    
    %4 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 1
    store i32 (i32)* %f, i32 (i32)** %4

    %5 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 2
    store i32 (i32)* %g, i32 (i32)** %5
    
    ret %composure_closure* %2
}

define i32 @main() {
    call void @_initialise_lib()

    ; doubleplus1 = compose(double, plus1)
    %1 = call %composure_closure* @compose(i32 (i32)* @double, i32 (i32)* @plus1)
    store %composure_closure* %1, %composure_closure** @doubleplus1

    ; _print_i32(doubleplus1(10));
    %2 = load %composure_closure*, %composure_closure** @doubleplus1
    %3 = getelementptr inbounds %composure_closure, %composure_closure* %2, i32 0, i32 0
    %4 = load i32 (%composure_closure*, i32)*, i32 (%composure_closure*, i32)** %3
    %5 = call i32 %4(%composure_closure* %2, i32 10)
    call void @_print_i32(i32 %5)

    ; _print_newline();
    call void @_print_newline()

    ret i32 0
}
