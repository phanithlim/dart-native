# dart_native_demo

A Dart CLI application demonstrating FFI integration with native C++ and Go shared libraries.

---

## Structure

```
dart_native_demo/
├── bin/
│   └── main.dart                     entry point
├── lib/
│   ├── dart_native_demo.dart         library entry point
│   └── src/
│       ├── cpp_bindings.dart         C++ FFI bindings (CppLib)
│       └── go_bindings.dart          Go FFI bindings (GoLib)
├── native/
│   ├── cpp/
│   │   ├── mylib.cpp                 C++ source (add)
│   │   ├── CMakeLists.txt            CMake build definition
│   │   ├── vcpkg.json                vcpkg package manifest
│   │   ├── README.md                 C++ build guide
│   │   └── RESOURCES.md              CMake / vcpkg reference links
│   ├── go/
│   │   ├── mylib.go                  Go source (multiply, fibonacci, greet, sumArray)
│   │   ├── go.mod
│   │   └── README.md                 Go/CGo guide
│   ├── kotlin/
│   │   ├── mylib.kt                  Kotlin/Native source (square, add, fibonacci)
│   │   └── README.md                 Kotlin/Native build guide
│   ├── swift/
│   │   ├── mylib.swift               Swift source (square, add, fibonacci, greet)
│   │   └── README.md                 Swift build guide
│   └── libs/                         compiled shared libraries (gitignored)
│       ├── libmylib.so
│       └── libgolib.so
├── test/
│   └── dart_native_demo_test.dart
├── Makefile
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Requirements

| Tool              | Version   | Required for          |
|-------------------|-----------|-----------------------|
| Dart              | ^3.10.8   | always                |
| Go                | 1.18+     | `make build-go`       |
| CMake             | 3.20+     | `make build-cpp`      |
| g++ / clang++     | any       | `make build-cpp`      |
| vcpkg             | any       | C++ third-party packages (optional) |
| Kotlin/Native (`konanc`) | 1.9+ | `make build-kotlin` |
| Swift (`swiftc`)  | 5.9+      | `make build-swift`    |

---

## Getting Started

### 1. Install Dart dependencies

```bash
dart pub get
```

### 2. Build native libraries

```bash
make
```

This compiles both `libmylib.so` (C++) and `libgolib.so` (Go) into `native/libs/`.

Or build individually:

```bash
make build-cpp   # C++ only
make build-go    # Go only
```

### 3. Run

```bash
make run
# or
dart run bin/main.dart
```

### 4. Test

```bash
dart test
```

---

## Makefile targets

| Target              | Description                                        |
|---------------------|----------------------------------------------------|
| `make`              | Build C++ and Go (default)                         |
| `make build-cpp`    | Compile C++ via CMake → `libmylib.so`              |
| `make build-go`     | Compile Go → `libgolib.so`                         |
| `make build-kotlin` | Compile Kotlin/Native → `libkotlinlib.so` (needs `konanc`) |
| `make build-swift`  | Compile Swift → `libswiftlib.so` (needs `swiftc`)  |
| `make run`          | Build (C++ + Go) and run the Dart app              |
| `make clean`        | Remove compiled `.so` files and CMake build dir    |

---

## Native functions

### C++ (`libmylib.so`)

| Function | Signature        | Description  |
|----------|------------------|--------------|
| `add`    | `(int, int) → int` | Integer addition |

### Go (`libgolib.so`)

| Function     | Signature                  | Description              |
|--------------|----------------------------|--------------------------|
| `multiply`   | `(int32, int32) → int32`   | Integer multiplication   |
| `fibonacci`  | `(int32) → int64`          | nth Fibonacci number     |
| `greet`      | `(*char) → *char`          | Returns greeting string  |
| `freeString` | `(*char) → void`           | Frees Go-allocated string |
| `sumArray`   | `(*int32, int32) → int64`  | Sum of int32 array       |

---

## Language compatibility with Dart FFI

Dart FFI calls into shared libraries that expose a **C ABI** (`extern "C"`). Any language that can compile to a `.so`/`.dylib`/`.dll` with C-compatible symbols works.

### Supported

| Language       | Mechanism                                      |
|----------------|------------------------------------------------|
| **C**          | Native — no wrapper needed                     |
| **C++**        | `extern "C" { ... }` block                     |
| **Go**         | CGo `//export` + `-buildmode=c-shared`         |
| **Rust**       | `#[no_mangle] extern "C" fn` + `crate-type = ["cdylib"]` |
| **Zig**        | `export fn` + compile as shared library        |
| **Nim**        | `{.exportc, dynlib.}` pragma                   |
| **D**          | `extern(C)` linkage                            |
| **Kotlin/Native** | `@CName` annotation + compile to shared lib |
| **Swift**      | `@_cdecl("name")` (Linux/macOS)                |
| **Fortran**    | `ISO_C_BINDING` + `bind(C)` attribute          |

### Not supported

| Language            | Reason                                                      |
|---------------------|-------------------------------------------------------------|
| **Python**          | No C ABI export; would require embedding the CPython runtime |
| **Java**            | JVM bytecode only; JNI goes the other direction             |
| **Kotlin (JVM)**    | Same as Java — JVM, no C ABI                                |
| **Scala**           | JVM, no C ABI                                               |
| **C# / .NET**       | CLR managed runtime; no native C ABI export                 |
| **JavaScript / TypeScript** | No C ABI; runs in a JS engine                       |
| **Ruby**            | Interpreter-based; no C ABI export                          |
| **PHP**             | Interpreter-based; no C ABI export                          |

> The key rule: if the language can produce a shared library (`.so`) with plain C-named symbols, Dart FFI can call it.

---

## Examples: Kotlin/Native and Swift

### Kotlin/Native

**Requirements:** [Kotlin/Native compiler (`konanc`)](https://kotlinlang.org/docs/native-overview.html) or Gradle with the `kotlin-multiplatform` plugin.

**1. Native code** — `native/kotlin/mylib.kt`

```kotlin
import kotlinx.cinterop.CPointer
import kotlinx.cinterop.utf8
import kotlinx.cinterop.toKString

// Simple integer function
@CName("square")
fun square(a: Int): Int = a * a

// String function — returns a Kotlin string as a C string
@CName("greetKotlin")
fun greetKotlin(name: CPointer<ByteVar>?): CPointer<ByteVar>? {
    val s = name?.toKString() ?: "stranger"
    return "Hello, $s! (from Kotlin/Native)".utf8.getPointer(nativeHeap)
}
```

**2. Build**

```bash
konanc -produce dynamic -target linux_x64 \
  -o native/libs/libkotlinlib \
  native/kotlin/mylib.kt
# produces libkotlinlib.so + libkotlinlib_api.h
```

**3. Dart FFI binding** — `lib/src/kotlin_bindings.dart`

```dart
import 'dart:ffi';
import 'package:path/path.dart' as p;

typedef _SquareNative = Int32 Function(Int32 a);
typedef SquareDart = int Function(int a);

class KotlinLib {
  final DynamicLibrary _lib;
  late final SquareDart square;

  KotlinLib(String libsDir)
      : _lib = DynamicLibrary.open(p.join(libsDir, 'libkotlinlib.so')) {
    square = _lib.lookupFunction<_SquareNative, SquareDart>('square');
  }
}
```

**4. Usage** — `bin/main.dart`

```dart
final kotlin = KotlinLib(libsDir);
print(kotlin.square(7)); // → 49
```

---

### Swift

**Requirements:** Swift toolchain (`swiftc`) — available on Linux via [swift.org/download](https://www.swift.org/download/) and on macOS via Xcode.

**1. Native code** — `native/swift/mylib.swift`

```swift
import Foundation

// @_cdecl exports the function with a plain C symbol name
@_cdecl("square_swift")
public func squareSwift(_ a: Int32) -> Int32 {
    return a * a
}

@_cdecl("greet_swift")
public func greetSwift(_ namePtr: UnsafePointer<CChar>?) -> UnsafeMutablePointer<CChar>? {
    let name = namePtr.map { String(cString: $0) } ?? "stranger"
    let result = "Hello, \(name)! (from Swift)"
    // strdup allocates on the C heap — caller must free()
    return strdup(result)
}
```

**2. Build**

```bash
# Linux
swiftc -emit-library -target x86_64-unknown-linux-gnu \
  -o native/libs/libswiftlib.so \
  native/swift/mylib.swift

# macOS
swiftc -emit-library \
  -o native/libs/libswiftlib.dylib \
  native/swift/mylib.swift
```

**3. Dart FFI binding** — `lib/src/swift_bindings.dart`

```dart
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;

typedef _SquareNative = Int32 Function(Int32 a);
typedef SquareDart = int Function(int a);

typedef _GreetNative = Pointer<Utf8> Function(Pointer<Utf8> name);
typedef GreetDart = Pointer<Utf8> Function(Pointer<Utf8> name);

class SwiftLib {
  final DynamicLibrary _lib;
  late final SquareDart square;
  late final GreetDart greet;

  SwiftLib(String libsDir)
      : _lib = DynamicLibrary.open(p.join(libsDir, 'libswiftlib.so')) {
    square = _lib.lookupFunction<_SquareNative, SquareDart>('square_swift');
    greet = _lib.lookupFunction<_GreetNative, GreetDart>('greet_swift');
  }
}
```

**4. Usage** — `bin/main.dart`

```dart
final swift = SwiftLib(libsDir);
print(swift.square(7)); // → 49

final namePtr = 'Dart'.toNativeUtf8();
final resultPtr = swift.greet(namePtr);
print(resultPtr.toDartString());
malloc.free(namePtr);
malloc.free(resultPtr); // free the strdup allocation
```

> **Note:** Swift on Linux requires the Swift runtime libraries (`libswiftCore.so` etc.) to be present at runtime. Set `LD_LIBRARY_PATH` to the Swift toolchain's `lib/swift/linux/` directory if the app fails to load the library.

---

## Adding a new native function

See [`native/go/README.md`](native/go/README.md) for a step-by-step guide on adding Go-exported functions and wiring them to Dart FFI.

For C++, add the function to `native/cpp/mylib.cpp`, rebuild with `make build-cpp`, then add the corresponding typedefs and lookup in `lib/src/cpp_bindings.dart`.
# dart-native
