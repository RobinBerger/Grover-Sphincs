namespace grover.oracles {
    open common;
    open common.sponge;
    open common.maybeqbit;
    open haraka;
    open haraka.sponge;
    open keccak.shake256;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// Flips the phase of all qubits if all input qubits are 1
    /// # Input
    /// ## input
    /// The input, that all have to be 1 for the global phase to be flipped.
    operation flipIfOne(input : Qubit[]) : Unit is Adj {
        using (target = Qubit()) {
            within {
                X(target);
                H(target);
            } apply {
                //target was prepared so flipping it results in a global phase change
                Controlled X(input, target);
            }
        }
    }

    /// # Summary
    /// Implements the Grover oracle for finding a preimage of the given hash function on the given input.
    /// # Input
    /// ## input
    /// The input to the hash function
    /// ## expected
    /// The hash function output searched for by Grover's algorithm.
    /// ## hashFunction
    /// The hash function, the preimage attack is performed on.
    operation hashOracle(input : MaybeQbit[], expected : Int[], hashFunction : ((MaybeQbit[], Qubit[]) => Unit is Adj)) : Unit is Adj {
        using (outputBits = Qubit[Length(expected) * 8]) {
            within {
                hashFunction(input, outputBits);

                initialize8inverse(outputBits, expected);
            } apply {
                flipIfOne(outputBits);
            }
        }
    }

    /// # Summary
    /// Implements the Grover oracle for finding a preimage of the given sponge hash function on the given input.
    /// For sponge hash function, this is more efficient than the hashOracle implementation.
    operation spongeHashOracle(input : MaybeQbit[], expected : Int[], spec : SpongeSpec) : Unit is Adj {
        spongeHashWithInitialStateOracle(input, expected, spec, ConstantArray(spec::stateSize / 8, 0));
    }

    /// # Summary
    /// Implements the Grover oracle for finding a preimage of the given sponge hash function on the given input with a given initial state.
    /// # Input
    /// ## input
    /// The input to the hash function
    /// ## expected
    /// The hash function output searched for by Grover's algorithm.
    /// ## hashFunction
    /// The hash function, the preimage attack is performed on.
    /// ## initialState
    /// The initial state of the sponge hash function, allowing partially precomputing absorb iterations.
    operation spongeHashWithInitialStateOracle(input : MaybeQbit[], expected : Int[], spec : SpongeSpec, initialState : Int[]) : Unit is Adj {
        using (state = Qubit[spec::stateSize]) {
            within {
                initialize8(state, initialState);
                absorb(input, state, spec);
            } apply {
                using (output = Qubit[Length(expected) * 8]) {
                    within {
                        squeeze(state, output, spec);
                        initialize8inverse(output, expected);
                    } apply {
                        flipIfOne(output);
                    }

                }
            } 
        }
    }

    /// # Summary
    /// Implements the Grover oracle for finding a preimage of a recursive applocation of a hash function on the given input.
    /// # Input
    /// ## input
    /// The input to the hash function
    /// ## hashFunction
    /// The hash function, the preimage attack is performed on.
    /// ## expected
    /// The hash function output searched for by Grover's algorithm.
    /// ## prefixes
    /// The prefix to the actual input to the hash function in the different recursion depths.
    /// ## inputSize
    /// The input size of the hash function. This adds padding or truncates the input for fixed-input-length hahs functions.
    operation recursiveHashOracle(input: Qubit[], hashFunction : ((MaybeQbit[], Qubit[]) => Unit is Adj), expected : Int[], prefixes : Int[][], inputSize : Int) : Unit is Adj {
        if (Length(prefixes) == 0) {
            within {
                initialize8inverse(input, expected);
            } apply {
                flipIfOne(input);
            }
        } else {
            let currentPrefix = prefixes[0];
            let followingPrefixes = prefixes[1 .. Length(prefixes) - 1];
            let prefix = bytesToMaybeQbit(currentPrefix);
            let len = Length(prefix);
            Fact(len == Length(input), "Unmatched input length.");
            let paddingBits = inputSize - 2 * len;
            let currentInput = prefix + qbitsToMaybeQbit(input) + ConstantArray(paddingBits, bitToMaybeQbit(false));

            using (intermediateOutputBits = Qubit[len]) {
                within {
                    hashFunction(currentInput, intermediateOutputBits);
                } apply {
                    recursiveHashOracle(intermediateOutputBits, hashFunction, expected, followingPrefixes, inputSize);
                }
            }
        }
    }

    /// # Summary
    /// This is the diffusion operator used in the Grover iterations.
    ///
    operation diffusion(target : Qubit[]) : Unit {
        grover.groverIteration(target, Microsoft.Quantum.Canon.ApplyToEachA(I, _));
    }
}