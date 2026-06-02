import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

typedef _MultiplyNative = Int32 Function(Int32 a, Int32 b);
typedef MultiplyDart = int Function(int a, int b);

typedef _FibonacciNative = Int64 Function(Int32 n);
typedef FibonacciDart = int Function(int n);

typedef _GreetNative = Pointer<Utf8> Function(Pointer<Utf8> name);
typedef GreetDart = Pointer<Utf8> Function(Pointer<Utf8> name);

typedef _FreeStringNative = Void Function(Pointer<Utf8> s);
typedef FreeStringDart = void Function(Pointer<Utf8> s);

typedef _SumArrayNative = Int64 Function(Pointer<Int32> arr, Int32 length);
typedef SumArrayDart = int Function(Pointer<Int32> arr, int length);

class GoLib {
  final DynamicLibrary _lib;
  late final MultiplyDart multiply;
  late final FibonacciDart fibonacci;
  late final GreetDart greet;
  late final FreeStringDart freeString;
  late final SumArrayDart sumArray;

  GoLib(String libsDir)
      : _lib = DynamicLibrary.open(p.join(libsDir, 'libgolib.so')) {
    multiply = _lib.lookupFunction<_MultiplyNative, MultiplyDart>('multiply');
    fibonacci = _lib.lookupFunction<_FibonacciNative, FibonacciDart>('fibonacci');
    greet = _lib.lookupFunction<_GreetNative, GreetDart>('greet');
    freeString = _lib.lookupFunction<_FreeStringNative, FreeStringDart>('freeString');
    sumArray = _lib.lookupFunction<_SumArrayNative, SumArrayDart>('sumArray');
  }
}
