# native/go

Go module that compiles to a C-shared library (`libgolib.so`) loaded by Dart via FFI.

---

## Requirements

| Tool | Version |
|------|---------|
| Go   | 1.18+   |
| GCC  | any     |

---

## Structure

```
native/go/
├── go.mod        module definition
└── mylib.go      exported functions
```

---

## Build

Run from the project root:

```bash
make build-go
```

Or manually from this directory:

```bash
CGO_ENABLED=1 go build -o ../libs/libgolib.so -buildmode=c-shared .
```

Output is written to `native/libs/libgolib.so`, which Dart loads at runtime.

---

## Development

### Add a third-party package

```bash
go get github.com/some/package
go mod tidy
```

Then recompile.

### Add an exported function

**Go side** — in `mylib.go`, place `//export` directly above the function (no blank line):

```go
//export square
func square(a int32) int32 {
    return a * a
}
```

**Dart side** — add typedefs and a field to `GoLib` in `lib/src/go_bindings.dart`:

```dart
typedef _SquareNative = Int32 Function(Int32 a);
typedef SquareDart = int Function(int a);

// inside GoLib constructor:
square = _lib.lookupFunction<_SquareNative, SquareDart>('square');
```

Then recompile.

---

## CGo Rules

- Package must be `package main`
- File must contain an empty `func main() {}`
- Must have `import "C"` at the top of the file
- `//export FuncName` must be on the line **directly above** the function — no blank line
- Only use C-compatible types: `int32`, `float64`, `unsafe.Pointer`, etc.

---

## Dart FFI Type Reference

| Go type   | FFI native type | Dart type |
|-----------|-----------------|-----------|
| `int32`   | `Int32`         | `int`     |
| `int64`   | `Int64`         | `int`     |
| `float32` | `Float`         | `double`  |
| `float64` | `Double`        | `double`  |
| `*C.char` | `Pointer<Utf8>` | `String`  |
