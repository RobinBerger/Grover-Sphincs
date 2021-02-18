namespace common.sponge {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open common;
    open common.maybeqbit;

    /// # Summary
    /// SpongeSpec contains all parameters required to instantiate s sponge construction
    /// # Input
    /// ## stateSize
    /// The amount of bits in the state of the sponge construction.
    /// ## rate
    /// The rate of the sponge construction in bytes.
    /// ## separator
    /// The separator byte used for the padding.
    /// ## permutation
    /// The permutation used for the sponge construction
    newtype SpongeSpec = (stateSize : Int, rate : Int, separator : Int, permutation : (Qubit[] => Unit is Adj));

    /// # Summary
    /// Absorbs the given input into the given state using the given sponge parameters without adding any padding.
    /// The length of the input needs to be a multiple of the rate.
    /// # Input
    /// ## input
    /// The input to absorb
    /// ## state
    /// The state to absorb the input into
    /// ## spec
    /// The parameters of the sponge construction
    operation absorbWithoutPadding(input : MaybeQbit[], state : Qubit[], spec : SpongeSpec) : Unit is Adj {
        Fact(Length(input) % (spec::rate * 8) == 0, "Can only absorb full blocks without padding.");
        let inputLength = Length(input) / 8;

        let amountIterations = inputLength / spec::rate;

        for (i in 0 .. amountIterations - 1) {
            maybeXOR(input[i * spec::rate * 8 .. (i + 1) * spec::rate * 8 - 1], state[0 .. spec::rate * 8 - 1]);
            spec::permutation(state);
        }
    }

    /// # Summary
    /// Absorbs the given input into the given state using the given sponge parameters while padding padding the message.
    /// # Input
    /// ## input
    /// The input to absorb
    /// ## state
    /// The state to absorb the input into
    /// ## spec
    /// The parameters of the sponge construction
    operation absorb(input : MaybeQbit[], state : Qubit[], spec : SpongeSpec) : Unit is Adj {
        Fact(Length(input) % 8 == 0, "Input is not byte-aligned.");
        Fact(0 < spec::separator and spec::separator < 128, "Invalid separator byte.");
        let inputLength = Length(input) / 8;

        let amountIterations = inputLength / spec::rate;
        let preprocessedAmount = amountIterations * spec::rate;
        let leftoverBytes = inputLength - preprocessedAmount;

        absorbWithoutPadding(input[0 .. (preprocessedAmount * 8) - 1], state, spec);

        //Here we need to
        // 1.) xor the remaining input bytes
        // 2.) xor the separator byte after that
        // 3.) flip the uppermost bit of the last state bit

        maybeXOR(input[preprocessedAmount * 8 .. (preprocessedAmount + leftoverBytes) * 8 - 1], state[0 .. leftoverBytes * 8 - 1]);

        let separatorPosition = (inputLength % spec::rate) * 8;
        //The separator has at most 7 bits.
        initialize8(state[separatorPosition .. separatorPosition + 6], [spec::separator]);

        X(state[spec::rate * 8 - 1]);
    }

    /// # Summary
    /// Squeezes output out of the state using the given sponge parameters.
    /// # Input
    /// ## state
    /// The state to absorb the input into
    /// ## output
    /// The output bits
    /// ## spec
    /// The parameters of the sponge construction
    operation squeeze(state : Qubit[], output : Qubit[], spec : SpongeSpec) : Unit is Adj {
        Fact(Length(output) % 8 == 0, "Invalid output length");
        let outputLength = Length(output) / 8;
        let requiredIterations = outputLength / spec::rate + (outputLength % spec::rate == 0 ? 0 | 1);
        let rateInBits = spec::rate * 8;

        for (i in 0 .. requiredIterations - 1) {
            spec::permutation(state);

            let startSqueezeAmount = rateInBits * i;
            let squeezeAmount = outputLength >= spec::rate * (i + 1) ? spec::rate * 8 | (outputLength % spec::rate) * 8;
            for (j in 0 .. squeezeAmount - 1) {
                CNOT(state[j], output[startSqueezeAmount + j]);
            }
        }
    }

    /// # Summary
    /// Performs the squeeze operation without producing any output only modifying the state.
    /// The output bits are not modified.
    /// # Input
    /// ## state
    /// The state to perform the squeeze operation on
    /// ## output
    /// The output bits
    /// ## spec
    /// The parameters of the sponge construction
    operation squeezeWithoutOutput(state : Qubit[], output : Qubit[], spec : SpongeSpec) : Unit is Adj {
        let outputLength = Length(output) / 8;
        let requiredIterations = outputLength / spec::rate + (outputLength % spec::rate == 0 ? 0 | 1);

        for (i in 0 .. requiredIterations - 1) {
            spec::permutation(state);
        }
    }

    /// # Summary
    /// Computes the hash function on the given input using the given parameters for the sponge construction
    /// The output qbits will then hold the hash value.
    ///
    /// This can also be used with 
    ///     hash(_, _, spec)
    /// to yield a concrete instantiation of the sponge construction.
    /// # Input
    /// ## input
    /// The input for the hash function
    /// ## output
    /// The output for the hash function
    /// ## spec
    /// The parameters for the sponge construction
    operation hash(input : MaybeQbit[], output : Qubit[], spec : SpongeSpec) : Unit is Adj {
        using (state = Qubit[spec::stateSize]) {
            within {
                absorb(input, state, spec);
            } apply {
                squeeze(state, output, spec);
                Adjoint squeezeWithoutOutput(state, output, spec);
            }
        }
    }

}