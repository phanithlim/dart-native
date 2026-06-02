# native/kotlin

Kotlin/Native source that compiles to `libkotlinlib.so`, loaded by Dart via FFI.

---

## Requirements

| Tool          | Version |
|---------------|---------|
| Kotlin/Native (`konanc`) | 1.9+ |

Install via [SDKMAN](https://sdkman.io/):
```bash
sdk install kotlin
```
Or download from [kotlinlang.org/docs/native-overview.html](https://kotlinlang.org/docs/native-overview.html).

---

## Structure

```
native/kotlin/
├── mylib.kt      exported functions
└── README.md
```

---

## Build

From the project root:

```bash
make build-kotlin
```

Or manually:

```bash
konanc -produce dynamic -target linux_x64 \
  -o native/libs/libkotlinlib \
  native/kotlin/mylib.kt
```

This produces two files in `native/libs/`:
- `libkotlinlib.so` — the shared library Dart loads
- `libkotlinlib_api.h` — the generated C header (for reference)

---

## Adding an exported function

**Kotlin side** — annotate the top-level function with `@CName`:

```kotlin
import kotlin.native.CName

@CName("multiply_kotlin")
fun multiplyKotlin(a: Int, b: Int): Int = a * b
```

> `@CName` must be on a **top-level** function, not a class method.

**Dart side** — add typedefs and a field to `KotlinLib` in `lib/src/kotlin_bindings.dart`:

```dart
typedef _MultiplyNative = Int32 Function(Int32 a, Int32 b);
typedef MultiplyDart = int Function(int a, int b);

// inside KotlinLib constructor:
multiply = _lib.lookupFunction<_MultiplyNative, MultiplyDart>('multiply_kotlin');
```

Then recompile with `make build-kotlin`.

---

## Dart FFI Type Reference

| Kotlin type | FFI native type | Dart type |
|-------------|-----------------|-----------|
| `Int`       | `Int32`         | `int`     |
| `Long`      | `Int64`         | `int`     |
| `Float`     | `Float`         | `double`  |
| `Double`    | `Double`        | `double`  |
| `Boolean`   | `Bool`          | `bool`    |

> For string interop, use `kotlinx.cinterop.CPointer<ByteVar>` on the Kotlin side and `Pointer<Utf8>` on the Dart side.
