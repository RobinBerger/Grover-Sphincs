namespace keccak.test {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open keccak;
    open common;
    open common.test;

    /// # Summary
    /// performs a known input known outptut test of the 64-bit left rotate method given the inputs and expected outputs.
    operation performRotate(before : BigInt, after : BigInt, rotationAmount : Int) : Unit {
        let amountBits = 64;
        using (bits = Qubit[amountBits]) {
            let register = QInt(bits);
            initialize64(bits, [before]);

            assert64((getLeftRotated(register, rotationAmount))!, after, "");
            ResetAll(bits);
        }
    }

    @Test("ToffoliSimulator")
    operation testRotate() : Unit {
        performRotate(5L, 40L, 3);
        performRotate(0x8000000000000001L, 0x3L, 1);
        performRotate(0x8000000000000000L, 0x4000000000000000L, 63);
    }

    /// # Summary
    /// Tests the 64-bit XOR operation on example inputs
    @Test("ToffoliSimulator")
    operation testXOR() : Unit {
        using (bits = Qubit[256]) {
            let registers = divideIntoQInts(bits);
            let one = registers[0];
            let two = registers[1];
            let three = registers[2];
            let four = registers[3];

            initialize64(one!, [1L]);
            initialize64(two!, [2L]);
            initialize64(three!, [3L]);
            initialize64(four!, [0xbadc0de000FFL]);

            XORInt([one, two], three);
            assert64(three!, 0L, "");

            XORInt([four], three);
            assert64(three!, 0xbadc0de000FFL, "");

            ResetAll(bits);
        }
    }
}