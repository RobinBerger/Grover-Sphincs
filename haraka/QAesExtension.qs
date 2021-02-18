
/// # Summary
/// Implementation of AES functions expanding QAES.
/// This allows using AES for the HAraka hash functions.
namespace haraka.aes {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open QAES.InPlace;
    open BoyarPeralta11;
    open common;
    open haraka.mixing;

    /// # Summary
    /// Implementation of the AddKey step of the AES specification.
    /// # Input
    /// ## state
    /// The AES register to add the key to
    /// ## roundKey
    /// The round key to add
    operation addFixedRoundKey(state: Qubit[], roundKey: Int[]) : Unit is Adj {
        initialize8(state, roundKey);
    }

    /// # Summary
    /// Implementation of one AES round consisting of SubBytes, ShiftRows, MixColumns and AddKey
    /// The input register is reset back into zero state.
    /// # Input
    /// ## inRegister
    /// The input for the AES round
    /// ## outRegister
    /// Qbits to store the output of the AES round
    /// ## roundKey
    /// The round key to use
    operation aesEnc(inRegister : Qubit[], outRegister : Qubit[], roundKey : Int[]) : Unit is Adj {
        let inState = divideRegisterIntoInts(inRegister);
        let outState = divideRegisterIntoInts(outRegister);
        let permutedOutState = divideRegisterIntoInts(inversePermutation(outRegister, ShiftRows<Int>(_)));
        let costing = false;
        SubBytes(inState, permutedOutState, costing);
        MixColumn(outState, costing);
        addFixedRoundKey(outRegister, roundKey);
    }

    /// # Summary
    /// SubBytes Step of the AES specification consisting of multiple calls to the AES S-Box
    /// The input state is reset back to zero state.
    /// # Input
    /// ## inputState
    /// The input of the SubBytes step
    /// ## outputState
    /// Qbits to store the output of the SubBytes step.
    operation SubBytes(inputState: Qubit[][], outputState: Qubit[][], costing: Bool) : Unit is Adj {
        for (i in 0..3) {
            for (j in 0..3) {
                let input = inputState[j][(i*8)..((i+1)*8-1)];
                let output = outputState[j][(i*8)..((i+1)*8-1)];

                SBox(input, output, costing);
                Adjoint inverseSBox(output, input, costing);
            }
        }
    }

    /// # Summary
    /// Divides an array of qbits into blocks of 128 Bits
    /// # Input
    /// ## bits
    /// The qbit array to divide
    /// # Output
    /// An array of 128-qbit arrays
    function divideIntoRegisters(bits : Qubit[]) : Qubit[][] {
        Fact(Length(bits) % 128 == 0, "Invalid amount of QBits");
        return Chunks(128, bits);
    }

    /// # Summary
    /// Divides a 128 block of qbits into blocks of 32 qbits.
    /// This is required for interaction with the QAES functions.
    /// # Input
    /// ## register
    /// The qbit array to divide
    /// # Output
    /// An array of 32-qbit arrays
    function divideRegisterIntoInts(register : Qubit[]) : Qubit[][] {
        return Chunks(32, register);
    }

    /// # Summary
    /// Implementation of the ShiftRows step of the AES specification.
    /// # Input
    /// ## input
    /// The input to the ShiftRows step
    /// # Output
    /// The output of th ShiftRows step
    function ShiftRows<'T>(input : 'T[]) : 'T[] {
        return
            input[0 * 32 + 0 * 8 .. 0 * 32 + 1 * 8 - 1] + input[1 * 32 + 1 * 8 .. 1 * 32 + 2 * 8 - 1] + input[2 * 32 + 2 * 8 .. 2 * 32 + 3 * 8 - 1] + input[3 * 32 + 3 * 8 .. 3 * 32 + 4 * 8 - 1] + 
            input[1 * 32 + 0 * 8 .. 1 * 32 + 1 * 8 - 1] + input[2 * 32 + 1 * 8 .. 2 * 32 + 2 * 8 - 1] + input[3 * 32 + 2 * 8 .. 3 * 32 + 3 * 8 - 1] + input[0 * 32 + 3 * 8 .. 0 * 32 + 4 * 8 - 1] + 
            input[2 * 32 + 0 * 8 .. 2 * 32 + 1 * 8 - 1] + input[3 * 32 + 1 * 8 .. 3 * 32 + 2 * 8 - 1] + input[0 * 32 + 2 * 8 .. 0 * 32 + 3 * 8 - 1] + input[1 * 32 + 3 * 8 .. 1 * 32 + 4 * 8 - 1] + 
            input[3 * 32 + 0 * 8 .. 3 * 32 + 1 * 8 - 1] + input[0 * 32 + 1 * 8 .. 0 * 32 + 2 * 8 - 1] + input[1 * 32 + 2 * 8 .. 1 * 32 + 3 * 8 - 1] + input[2 * 32 + 3 * 8 .. 2 * 32 + 4 * 8 - 1];
    }

}