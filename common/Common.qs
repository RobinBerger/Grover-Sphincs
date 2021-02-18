namespace common {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;

    /// # Summary
    /// Initializes an array of qbits in blocks of 8 with the given bytes.
    /// The lower 8 bits of each given Int will be used.
    /// # Input
    /// ## bits
    /// The qbits to initialize
    /// ## values
    /// The value to initialize the qubits with
    operation initialize8(bits : Qubit[], values : Int[]) : Unit is Adj {
        for (i in 0 .. Length(bits) - 1) {
            if (((values[i / 8] >>> (i % 8)) &&& 1) != 0) {
                X(bits[i]);
            }
        }
    }

    /// # Summary
    /// Initializes an array of qbits in blocks of 8 with the bitwise negation of the given bytes.
    /// The lower 8 bits of each given Int will be used.
    /// # Input
    /// ## bits
    /// The qbits to initialize
    /// ## values
    /// The bitwise inverse of the value to initialize the qbits with
    operation initialize8inverse(bits : Qubit[], values : Int[]) : Unit is Adj {
        for (i in 0 .. Length(bits) - 1) {
            if (((values[i / 8] >>> (i % 8)) &&& 0) != 0) {
                X(bits[i]);
            }
        }
    }

    /// # Summary
    /// Initializes an array of qbits in blocks of 64 with the given BigInts.
    /// The lower 64 bits of each BigInt will be used.
    /// # Input
    /// ## bits
    /// The qbits to initialize
    /// ## values
    /// The value to initialize the qubits with
    operation initialize64(bits : Qubit[], values : BigInt[]) : Unit is Adj + Ctl {
        for (i in 0 .. Length(values) - 1) {
            for (j in 0 .. 63) {
                if (((values[i] >>> j) &&& 0x1L) != 0L) {
                    X(bits[i * 64 + j]);
                }
            }
        }
    }

    /// # Summary
    /// Measures the qubits and returns the result as Int
    /// # Input
    /// ## bits
    /// The bits to measure
    /// # Output
    /// The Int representing the measurement
    operation measureInt(bits : Qubit[]) : Int {
        let result = ForEach(FunctionAsOperation(IsResultOne), ForEach(M, bits));
        // The additional false element is required to make sure we deal with unsigned numbers when converting.
        return BoolArrayAsInt(result + [false]);
    }

    /// # Summary
    /// Measures the qubits and returns the result as BigInt
    /// # Input
    /// ## bits
    /// The bits to measure
    /// # Output
    /// The Int representing the measurement
    operation measureBigInt(register : Qubit[]) : BigInt {
        let result = ForEach(FunctionAsOperation(IsResultOne), ForEach(M, register));
        // The additional false element is required to make sure we deal with unsigned numbers when converting.
        return BoolArrayAsBigInt(result + [false]);
    }

}