# native/cpp

C++ source that compiles to `libmylib.so`, loaded by Dart via FFI.

---

## Requirements

| Tool    | Version     |
|---------|-------------|
| CMake   | 3.20+       |
| g++ / clang++ | any   |
| vcpkg   | optional — only needed when adding third-party packages |

---

## Structure

```
native/cpp/
├── mylib.cpp          exported functions
├── CMakeLists.txt     build definition
├── vcpkg.json         package manifest (vcpkg)
└── RESOURCES.md       CMake / vcpkg reference links
```

---

## Build

From the project root:

```bash
make build-cpp
```

This runs CMake and writes `libmylib.so` to `native/libs/`.

Or manually:

```bash
cmake -S native/cpp -B native/cpp/build -DCMAKE_BUILD_TYPE=Release
cmake --build native/cpp/build
```

---

## Adding a third-party package with vcpkg

### 1. Install vcpkg (one-time)

```bash
git clone https://github.com/microsoft/vcpkg.git ~/vcpkg
~/vcpkg/bootstrap-vcpkg.sh
```

### 2. Add the package to vcpkg.json

```json
{
  "name": "mylib",
  "version": "0.1.0",
  "dependencies": [
    "nlohmann-json"
  ]
}
```

### 3. Link it in CMakeLists.txt

```cmake
find_package(nlohmann_json CONFIG REQUIRED)
target_link_libraries(mylib PRIVATE nlohmann_json::nlohmann_json)
```

### 4. Build with the vcpkg toolchain

```bash
cmake -S native/cpp -B native/cpp/build \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=~/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build native/cpp/build
```

---

## Adding an exported function

**C++ side** — in `mylib.cpp`, wrap with `extern "C"` to prevent name mangling:

```cpp
extern "C" {
  int32_t square(int32_t a) {
    return a * a;
  }
}
```

**Dart side** — add typedefs and a field to `CppLib` in `lib/src/cpp_bindings.dart`:

```dart
typedef _SquareNative = Int32 Function(Int32 a);
typedef SquareDart = int Function(int a);

// inside CppLib constructor:
square = _lib.lookupFunction<_SquareNative, SquareDart>('square');
```

Then recompile with `make build-cpp`.

---

## Dart FFI Type Reference

| C++ type    | FFI native type | Dart type |
|-------------|-----------------|-----------|
| `int32_t`   | `Int32`         | `int`     |
| `int64_t`   | `Int64`         | `int`     |
| `float`     | `Float`         | `double`  |
| `double`    | `Double`        | `double`  |
| `char*`     | `Pointer<Utf8>` | `String`  |
| `void`      | `Void`          | `void`    |
