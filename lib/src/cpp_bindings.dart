import 'dart:ffi';
import 'package:path/path.dart' as p;

typedef _AddNative = Int32 Function(Int32 a, Int32 b);
typedef AddDart = int Function(int a, int b);

class CppLib {
  final DynamicLibrary _lib;
  late final AddDart add;

  CppLib(String libsDir)
      : _lib = DynamicLibrary.open(p.join(libsDir, 'libmylib.so')) {
    add = _lib.lookupFunction<_AddNative, AddDart>('add');
  }
}
