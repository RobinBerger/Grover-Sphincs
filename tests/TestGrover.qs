namespace grover.test {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open grover;

    operation alternatingOracle(register : Qubit[], flag : Qubit) : Unit is Adj + Ctl {
        let length = Length(register);

        within {
            ApplyToEachCA(X, register[0..2..length - 1]);
        } apply {
            Controlled X(register, flag);
        }
    }
    
    operation zeroOracle(register : Qubit[], flag : Qubit) : Unit is Adj + Ctl {
        within {
            ApplyToEachCA(X, register);
        } apply {
            Controlled X(register, flag);
        }
    }

    operation oneOracle(register : Qubit[], flag : Qubit) : Unit is Adj + Ctl {
        Controlled X(register, flag);
    }

    operation performGroverSearch(nQBits : Int, oracle : ((Qubit[], Qubit) => Unit is Adj + Ctl)) : Result[] {
        using (bits = Qubit[nQBits]) {
            groverSearch(bits, flipOracle(oracle, _), getAmountIterations(nQBits));
            using (testBit = Qubit()) {
                oracle(bits, testBit);
                AssertMeasurementProbability([PauliZ], [testBit], One, 1., "Calculated bitstring does not satisfy oracle.", 1e-3);
                Reset(testBit);
            }
            return ForEach(MResetZ, bits);
        }
    }

    operation performGroverSearchExpecting(nQbits : Int, oracle : ((Qubit[], Qubit) => Unit is Adj + Ctl), expected : Result[]) : Unit {
        let measured = performGroverSearch(nQbits, oracle);
        for (i in 0 .. nQbits - 1) {
            if (expected[i] != measured[i]) {
                fail $"Unexpected measurement: received {measured[i]}, but expected {expected[i]}.";
            }
        }
    }

    @Test("QuantumSimulator")
    operation testSimple() : Unit {
        performGroverSearchExpecting(2, zeroOracle, [Zero, Zero]);
    }

    @Test("QuantumSimulator")
    operation testAdvanced() : Unit {
        performGroverSearchExpecting(10, oneOracle, [One, One, One, One, One, One, One, One, One, One]);
    }

    @Test("QuantumSimulator")
    operation testAlternating() : Unit {
        performGroverSearchExpecting(15, alternatingOracle, [Zero, One, Zero, One, Zero, One, Zero, One, Zero, One, Zero, One, Zero, One, Zero]);
    }
}