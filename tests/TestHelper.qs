namespace common.test {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open common;

    operation assert64(bits : Qubit[], value : BigInt, message : String) : Unit {
        let measured = measureBigInt(bits);
        for (i in 0 .. Length(bits) - 1) {
            AssertMeasurement([PauliZ], [(bits)[i]], ((value >>> i) &&& 1L) == 0L ? Zero | One, $"Measured value differs from real value at position {i}. Received {measured}, but expected {value}. {message}");
        }
    }

    operation assert64Multiple(bits : Qubit[], values : BigInt[], message : String) : Unit {
        let dividedBits = Chunks(64, bits);
        for (i in 0 .. Length(values) - 1) {
            assert64(dividedBits[i], values[i], $"Position {i}. {message}");
        }
    }

    operation assert8(bits : Qubit[], value : Int, message : String) : Unit {
        let measured = measureInt(bits);
        for (i in 0 .. Length(bits) - 1) {
            AssertMeasurement([PauliZ], [(bits)[i]], ((value >>> i) &&& 1) == 0 ? Zero | One, $"Measured value differs from real value at position {i}. Received {measured}, but expected {value}. {message}");
        }
    }

    operation assert8Multiple(bits : Qubit[], values : Int[], message : String) : Unit {
        let dividedBits = Chunks(8, bits);
        for (i in 0 .. Length(values) - 1) {
            assert8(dividedBits[i], values[i], $"Position {i}. {message}");
        }
    }
}