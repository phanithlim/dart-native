@_cdecl("square_swift")
public func squareSwift(_ a: Int32) -> Int32 {
    return a * a
}

@_cdecl("add_swift")
public func addSwift(_ a: Int32, _ b: Int32) -> Int32 {
    return a + b
}

@_cdecl("fibonacci_swift")
public func fibonacciSwift(_ n: Int32) -> Int64 {
    if n <= 1 { return Int64(n) }
    var a: Int64 = 0
    var b: Int64 = 1
    for _ in 2...n {
        let temp = a + b
        a = b
        b = temp
    }
    return b
}

// Caller must free() the returned pointer.
@_cdecl("greet_swift")
public func greetSwift(_ namePtr: UnsafePointer<CChar>?) -> UnsafeMutablePointer<CChar>? {
    let name = namePtr.map { String(cString: $0) } ?? "stranger"
    return strdup("Hello, \(name)! (from Swift)")
}
