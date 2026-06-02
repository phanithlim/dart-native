import kotlin.native.CName

@CName("square_kotlin")
fun squareKotlin(a: Int): Int = a * a

@CName("add_kotlin")
fun addKotlin(a: Int, b: Int): Int = a + b

@CName("fibonacci_kotlin")
fun fibonacciKotlin(n: Int): Long {
    if (n <= 1) return n.toLong()
    var a = 0L
    var b = 1L
    for (i in 2..n) {
        val temp = a + b
        a = b
        b = temp
    }
    return b
}
