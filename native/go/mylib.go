package main

/*
#include <stdlib.h>
*/
import "C"
import "unsafe"

// --- 1. Basic math ---

//export multiply
func multiply(a, b int32) int32 {
	return a * b
}

// --- 2. Fibonacci (recursive, shows int64 return) ---

//export fibonacci
func fibonacci(n int32) int64 {
	if n <= 1 {
		return int64(n)
	}
	a, b := int64(0), int64(1)
	for i := int32(2); i <= n; i++ {
		a, b = b, a+b
	}
	return b
}

// --- 3. Greet (string in, string out) ---
// Caller must free the returned *C.char using freeString().

//export greet
func greet(name *C.char) *C.char {
	s := C.GoString(name)
	result := "Hello, " + s + "! (from Go)"
	return C.CString(result)
}

//export freeString
func freeString(s *C.char) {
	C.free(unsafe.Pointer(s))
}

// --- 4. Sum of int32 array (pointer + length) ---

//export sumArray
func sumArray(arr *C.int, length C.int) C.longlong {
	slice := (*[1 << 28]C.int)(unsafe.Pointer(arr))[:length:length]
	var total int64
	for _, v := range slice {
		total += int64(v)
	}
	return C.longlong(total)
}

func main() {}
