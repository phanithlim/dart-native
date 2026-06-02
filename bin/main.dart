import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import 'package:dart_native_demo/dart_native_demo.dart';

void main() {
  final projectRoot = p.dirname(p.dirname(Platform.script.toFilePath()));
  final libsDir = p.join(projectRoot, 'native', 'libs');

  final cpp = CppLib(libsDir);
  final go = GoLib(libsDir);

  // C++
  print('=== C++ ===');
  print('add(3, 4)       = ${cpp.add(3, 4)}');

  // Go: multiply
  print('\n=== Go: multiply ===');
  print('multiply(3, 4)  = ${go.multiply(3, 4)}');

  // Go: fibonacci
  print('\n=== Go: fibonacci ===');
  for (final n in [0, 1, 5, 10, 20]) {
    print('fibonacci($n)${' ' * (4 - n.toString().length)}= ${go.fibonacci(n)}');
  }

  // Go: greet
  print('\n=== Go: greet ===');
  final namePtr = 'Dart'.toNativeUtf8();
  final resultPtr = go.greet(namePtr);
  print(resultPtr.toDartString());
  malloc.free(namePtr);
  go.freeString(resultPtr);

  // Go: sumArray
  print('\n=== Go: sumArray ===');
  final numbers = [10, 20, 30, 40, 50];
  final arr = malloc<Int32>(numbers.length);
  for (var i = 0; i < numbers.length; i++) {
    arr[i] = numbers[i];
  }
  print('sum($numbers) = ${go.sumArray(arr, numbers.length)}');
  malloc.free(arr);
}
