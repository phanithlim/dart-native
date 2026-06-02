.PHONY: all build-cpp build-go build-kotlin build-swift run clean

# Default: build the two libraries that ship with the project
all: build-cpp build-go

build-cpp:
	cmake -S native/cpp -B native/cpp/build -DCMAKE_BUILD_TYPE=Release
	cmake --build native/cpp/build

build-go:
	cd native/go && CGO_ENABLED=1 go build -o ../libs/libgolib.so -buildmode=c-shared .

# Requires konanc (Kotlin/Native compiler)
build-kotlin:
	konanc -produce dynamic -target linux_x64 \
	  -o native/libs/libkotlinlib \
	  native/kotlin/mylib.kt

# Requires swiftc (Swift compiler)
build-swift:
	swiftc -emit-library -target x86_64-unknown-linux-gnu \
	  -o native/libs/libswiftlib.so \
	  native/swift/mylib.swift

run: all
	dart run bin/main.dart

clean:
	rm -f native/libs/*.so native/libs/*.h native/libs/*.dylib
	rm -rf native/cpp/build
