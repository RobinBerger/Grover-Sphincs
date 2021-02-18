
/// # Summary
/// Implementation of the keccak permuatation
/// For concrete instantiations, see Shake256.qs
namespace keccak {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;
    open common.sponge;
    open common;
    open common.maybeqbit;

    // 1 State = 25 QInts
    newtype State = QInt[];
    
    /// # Summary
    /// Converts a QInt array to a State
    /// # Input
    /// ## ints
    /// The QInts to convert
    /// # Output
    /// The state for these QInts
    function getState(ints : QInt[]) : State {
        let length = Length(ints);
        Fact(length == 25, $"Could not divide QInt Array of length {length} into States, because they have the wrong length.");
        return State(ints);
    }

    /// # Summary
    /// Returns an empty state divided into BigInts with 64 bits.
    /// # Output
    /// An empty state
    function getZeroState() : BigInt[] {
        return ConstantArray(25, 0L);
    }

    /// # Summary
    /// Maps an index with 0 <= i < 25 to an x-y position
    /// # Input
    /// ## index
    /// The index to convert
    /// # Output
    /// The x-y position corresponding to the index
    function getStatePosition(index : Int) : (Int, Int) {
        Fact(0 <= index and index < 25, "Invalid index.");
        let x = index % 5;
        let y = index / 5;
        return (x, y);
    }

    /// # Summary
    /// Maps a x-y position to an index.
    /// # Input
    /// ## x, y
    /// The position to convert
    /// # Output
    /// The index corresponding to the x-y position
    function getStateIndex(posX : Int, posY : Int) : Int {
        let x = (posX % 5 + 5) % 5;
        let y = (posY % 5 + 5) % 5;
        return x + y * 5;
    }

    /// # Summary
    /// Returns a QInt from the state at the given x-y position.
    /// This is equivalent to a lane in the Keccak specification.
    /// # Input
    /// ## state
    /// The state to get the QInt from
    /// ## x, y
    /// The position to get the QInt from
    /// # Output
    /// The QInt at that position in the state.
    function getQIntFromState(state : State, posX : Int, posY : Int) : QInt {
        return state![getStateIndex(posX, posY)];
    }

    /// # Summary
    /// Computes the values C and D, from the theta step in the Keccak specification.
    /// The C values are uncomputed again.
    /// # Input
    /// ## input
    /// The input state to compute the values for
    /// ## d
    /// The output qubits to hold the d values
    /// ## c
    /// Ancilla qubits to hold the c values.
    operation calculateDFromInput(input : State, d : QInt[], c : QInt[]) : Unit is Adj {
        within {
            for (i in 0 .. 4) {
                XORInt([
                    getQIntFromState(input, i, 0),
                    getQIntFromState(input, i, 1),
                    getQIntFromState(input, i, 2),
                    getQIntFromState(input, i, 3),
                    getQIntFromState(input, i, 4)
                ], c[i]);
            }
        } apply {
            for (i in 0 .. 4) {
                XORInt([c[((i - 1) % 5 + 5) % 5], getLeftRotated(c[(i + 1) % 5], 1)], d[i]);
            }
        }
    }

    /// # Summary
    /// Computes the values C and D, from the inverse theta step.
    /// The C values are uncomputed again.
    /// Based on https://github.com/KeccakTeam/KeccakTools/blob/master/Sources/Keccak-f.h#L553
    /// # Input
    /// ## input
    /// The input state to compute the values for
    /// ## d
    /// The output qubits to hold the d values
    /// ## c
    /// Ancilla qubits to hold the c values.
    operation calculateDFromOutput(input : State, d : QInt[], c : QInt[]) : Unit is Adj {
        within {
            for (i in 0 .. 4) {
                XORInt([
                    getQIntFromState(input, i, 0),
                    getQIntFromState(input, i, 1),
                    getQIntFromState(input, i, 2),
                    getQIntFromState(input, i, 3),
                    getQIntFromState(input, i, 4)], 
                    c[i]);
            }
        } apply {
            let inversePositions = [
                0xDE26BC4D789AF134L,
                0x09AF135E26BC4D78L,
                0xEBC4D789AF135E26L,
                0x7135E26BC4D789AFL,
                0xCD789AF135E26BC4L
            ];
            for (z in 0 .. 63) {
                for (offset in 0 .. 4) {
                    if (((inversePositions[offset] >>> z) &&& 1L) != 0L) {
                        for (x in 0 .. 4) {
                            XORInt([getLeftRotated(c[(x - offset + 5) % 5], z)], d[x]);
                        }
                    }
                }
            }
        }
    }

    /// # Summary
    /// Applies the theta step of the Keccak specification using the already computed values d.
    /// To apply the entire theta step including the d computation and uncomputation, the following steps have to be taken:
    ///     calculateDFromInput(state, d, c)
    ///     theta(state, d)
    ///     Adjoint calculateDFromOutput(state, d, c)
    /// # Input
    /// ## input
    /// The state to apply the theta step on
    /// ## d
    /// The s values from the specification.
    operation theta(state : State, d : QInt[]) : Unit is Adj {
        for (x in 0 .. 4) {
            for (y in 0 .. 4) {
                let index = getStateIndex(x, y);
                XORInt([d[x]], state![index]);
            }
        }
    }

    /// # Summary
    /// Returns a new state, which is the old state with the rho step from the Keccak specification applied.
    /// The original state remains unchanged.
    /// # Input
    /// ## state
    /// The input state for the rho step.
    /// # Output
    /// The output state for the rho step.
    function rho(state : State) : State {
        let rotationAmount = [
              0,   1, 190,  28,  91,
             36, 300,   6,  55, 276,
              3,  10, 171, 153, 231,
            105,  45,  15,  21, 136,
            210,  66, 253, 120,  78
        ];
        mutable ret = new QInt[25];
        for (i in 0 .. 24) {
            set ret w/= i <- getLeftRotated(state![i], rotationAmount[i]);
        }
        return State(ret);
    }

    /// # Summary
    /// Returns a new state, which is the old state with the pi step from the Keccak specification applied.
    /// The original state remains unchanged.
    /// # Input
    /// ## state
    /// The input state for the pi step.
    /// # Output
    /// The output state for the pi step.
    function pi(state : State) : State {
        mutable ret = new QInt[25];
        for (x in 0 .. 4) {
            for (y in 0 .. 4) {
                let fromIndex = getStateIndex(x + 3 * y, x);
                let toIndex = getStateIndex(x, y);
                set ret w/= toIndex <- (state![fromIndex]);
            }
        }
        return State(ret);
    }

    /// # Summary
    /// Computes the chi step of the Keccak specification into the output state.
    /// The original state remains unchanged.
    /// # Input
    /// ## input
    /// The input state for the chi step.
    /// ## output
    /// The state to compute the output state into.
    operation chi(input : State, output : State) : Unit is Adj {
        for (x in 0 .. 4) {
            for (y in 0 .. 4) {
                let index = getStateIndex(x, y);
                stateRoundHelper(
                    input![index],
                    input![getStateIndex(x + 1, y)],
                    input![getStateIndex(x + 2, y)],
                    output![index]);
            }
        }
    }

    /// # Summary
    /// Computes the inverse chi step into the output state.
    /// The original state remains unchanged.
    /// Based on https://github.com/KeccakTeam/KeccakTools/blob/master/Sources/Keccak-f.h#L519
    /// # Input
    /// ## input
    /// The input state for the inverse chi step.
    /// ## output
    /// The state to compute the output state into.
    operation inverseChi(input : State, output : State) : Unit is Adj {
        for (y in 0 .. 4) {
            stateRoundHelper(
                input![getStateIndex(0, y)],
                input![getStateIndex(1, y)],
                input![getStateIndex(2, y)],
                output![getStateIndex(0, y)]);
            stateRoundHelper(
                input![getStateIndex(3, y)],
                input![getStateIndex(4, y)],
                output![getStateIndex(0, y)],
                output![getStateIndex(3, y)]);
            stateRoundHelper(
                input![getStateIndex(1, y)],
                input![getStateIndex(2, y)],
                output![getStateIndex(3, y)],
                output![getStateIndex(1, y)]);
            stateRoundHelper(
                input![getStateIndex(4, y)],
                input![getStateIndex(0, y)],
                output![getStateIndex(1, y)],
                output![getStateIndex(4, y)]);
            stateRoundHelper(
                input![getStateIndex(2, y)],
                input![getStateIndex(3, y)],
                output![getStateIndex(4, y)],
                output![getStateIndex(2, y)]);
            // Adjoint stateRoundHelper(
            //     input![getStateIndex(0, y)],
            //     input![getStateIndex(1, y)],
            //     input![getStateIndex(2, y)],
            //     output![getStateIndex(0, y)]);
            // stateRoundHelper(
            //     input![getStateIndex(0, y)],
            //     input![getStateIndex(1, y)],
            //     output![getStateIndex(2, y)],
            //     output![getStateIndex(0, y)]);

            // For output 0, we don't need the full stateRoundHelper, instead we only xor the necessary values.
            for (i in 0 .. 63) {
                within {
                    CNOT((output![getStateIndex(2, y)])![i], (input![getStateIndex(2, y)])![i]);
                } apply {
                    CNOT((input![getStateIndex(2, y)])![i], (output![getStateIndex(0, y)])![i]);
                    CCNOT((input![getStateIndex(1, y)])![i], (input![getStateIndex(2, y)])![i], (output![getStateIndex(0, y)])![i]);
                }
            }
        }
    }
    
    /// # Summary
    /// Returns the keccak round constants used for the iota step for a given round.
    /// # Input
    /// ## round
    /// The round to get the round constant for.
    /// # Output
    /// The round constant for that round.
    function getRoundConstants(round : Int) : BigInt {
        let ROUND_CONSTANTS = [
            0x0000000000000001L, 0x0000000000008082L,
            0x800000000000808aL, 0x8000000080008000L,
            0x000000000000808bL, 0x0000000080000001L,
            0x8000000080008081L, 0x8000000000008009L,
            0x000000000000008aL, 0x0000000000000088L,
            0x0000000080008009L, 0x000000008000000aL,
            0x000000008000808bL, 0x800000000000008bL,
            0x8000000000008089L, 0x8000000000008003L,
            0x8000000000008002L, 0x8000000000000080L,
            0x000000000000800aL, 0x800000008000000aL,
            0x8000000080008081L, 0x8000000000008080L,
            0x0000000080000001L, 0x8000000080008008L
        ];
        return ROUND_CONSTANTS[round];
    }

    function getAmountRounds() : Int {
        return 24;
    }

    /// # Summary
    /// Applies the iota step of the keccak specification to the given state.
    /// # Input
    /// ## state
    /// The state to apply the iota step to
    /// ## round
    /// The round number.
    operation iota(state : State, round : Int) : Unit is Adj {
        initialize64((state![getStateIndex(0, 0)])!, [getRoundConstants(round)]);
    }

    /// # Summary
    /// computes first ^ ((~second) & third) and xors it on target
    /// This is used in the chi and inverse chi step.
    operation stateRoundHelper(first : QInt, second : QInt, third : QInt, target : QInt) : Unit is Adj {
        for (i in 0 .. 63) {
            CNOT(first![i], target![i]);
            CNOT(third![i], target![i]);
            CCNOT(second![i], third![i], target![i]);
        }
    }

    /// # Summary
    /// Computes one round of the keccak permutation
    /// # Input
    /// ## input
    /// The input state for the round
    /// ## output
    /// The output state for the round
    /// ## roundNumber
    /// The round number of the round
    operation keccakStatePermuteRound(input : State, output : State, roundNumber : Int) : Unit is Adj {
        //instead of using new qubits for the c and d variables, we can also use the outputState qubits, since they are zero
        // using (dBits = Qubit[5 * 64]) {
        //     let d = divideIntoQInts(dBits, false);
        //     using (cBits = Qubit[5 * 64]) {
        //         let c = divideIntoQInts(cBits, false);
        //         calculateDFromInput(inputState, d, c);
        //     }
        //     theta(inputState, d);
        //     using (cBits = Qubit[5 * 64]) {
        //         let c = divideIntoQInts(cBits, false);
        //     Adjoint calculateDFromOutput(inputState, d, c);
        //     }
        // }

        let d = output![0..4];
        let c = output![5..9];
        calculateDFromInput(input, d, c);
        theta(input, d);
        Adjoint calculateDFromOutput(input, d, c);


        let afterRho = rho(input);
        let afterPi = pi(afterRho);
        chi(afterPi, output);
        Adjoint inverseChi(output, afterPi);
        iota(output, roundNumber);
    }

    /// # Summary
    /// Applies the keccak permutation on the given qbit state
    /// # Input
    /// ## stateBits
    /// The state to apply the permutation to
    operation keccakPermutation(stateBits : Qubit[]) : Unit is Adj {
        let state = getState(divideIntoQInts(stateBits));
        using (immediateBits = Qubit[25 * 64]) {
            let immediateState = getState(divideIntoQInts(immediateBits));
            for (i in 0 .. 2 .. getAmountRounds() - 1) {
                keccakStatePermuteRound(state, immediateState, i);
                keccakStatePermuteRound(immediateState, state, i + 1);
            }
        }
    }

    /// # Summary
    /// Sponge instantiation with the keccak permutation for the squeeze part
    operation keccakSqueeze(output : Qubit[], nBytes : Int, state : Qubit[], rate : Int) : Unit is Adj {
        squeeze(state, output, SpongeSpec(1600, rate, -1, keccakPermutation));
    }

    /// # Summary
    /// Sponge instantiation with the keccak permutation for the absorb part
    operation keccakAbsorb(state : Qubit[], input : MaybeQbit[], rate : Int, separator : Int) : Unit is Adj {
        absorb(input, state, SpongeSpec(1600, rate, separator, keccakPermutation));
    }
}