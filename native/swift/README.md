# native/swift

Swift source that compiles to `libswiftlib.so`, loaded by Dart via FFI.

---

## Requirements

| Tool    | Version |
|---------|---------|
| Swift   | 5.9+    |

Install on Linux from [swift.org/download](https://www.swift.org/download/) or via your package manager:
```bash
# Arch Linux
sudo pacman -S swift

# Ubuntu (via swiftly)
curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash
swiftly install latest
```

On macOS, Swift ships with Xcode.

---

## Structure

```
native/swift/
├── mylib.swift    exported functions
└── README.md
```

---

## Build

From the project root:

```bash
make build-swift
```

Or manually:

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

> **Linux runtime:** The Swift runtime libraries (`libswiftCore.so` etc.) must be on the library path at runtime. If loading fails, set:
> ```bash
> export LD_LIBRARY_PATH=/path/to/swift/lib/swift/linux:$LD_LIBRARY_PATH
> ```

---

## Adding an exported function

**Swift side** — annotate with `@_cdecl`:

```swift
@_cdecl("multiply_swift")
public func multiplySwift(_ a: Int32, _ b: Int32) -> Int32 {
    return a * b
}
```

> `@_cdecl` requires a **free function** (not a method). The name in the annotation becomes the C symbol.

**Dart side** — add typedefs and a field to `SwiftLib` in `lib/src/swift_bindings.dart`:

```dart
typedef _MultiplyNative = Int32 Function(Int32 a, Int32 b);
typedef MultiplyDart = int Function(int a, int b);

// inside SwiftLib constructor:
multiply = _lib.lookupFunction<_MultiplyNative, MultiplyDart>('multiply_swift');
```

Then recompile with `make build-swift`.

---

## String interop

Swift's `@_cdecl` functions must use C-compatible pointer types for strings:

```swift
// Input: UnsafePointer<CChar>?  →  Dart: Pointer<Utf8>
// Output: UnsafeMutablePointer<CChar>?  →  Dart: Pointer<Utf8>
// Use strdup() to allocate — caller must free() the result
```

---

## Dart FFI Type Reference

| Swift type                        | FFI native type | Dart type |
|-----------------------------------|-----------------|-----------|
| `Int32`                           | `Int32`         | `int`     |
| `Int64`                           | `Int64`         | `int`     |
| `Float`                           | `Float`         | `double`  |
| `Double`                          | `Double`        | `double`  |
| `Bool`                            | `Bool`          | `bool`    |
| `UnsafePointer<CChar>?`           | `Pointer<Utf8>` | `String`  |
| `UnsafeMutablePointer<CChar>?`    | `Pointer<Utf8>` | `String`  |
