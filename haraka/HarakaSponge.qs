
/// # Summary
/// Implementation of the HAraka Sponge hash function.
namespace haraka.sponge {

    open haraka;
    open common.sponge;
    open common.maybeqbit;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    
    /// # Summary
    /// Returns the rate of the Haraka Sponge function
    function getHarakaRate() : Int {
        return 32;
    }

    /// # Summary
    /// Returns the separator byte of the Haraka Sponge function
    function getHarakaSeparator() : Int {
        return 0x1F;
    }

    /// # Summary
    /// Returns the state size of the Haraka Sponge function
    function getHarakaStateSize() : Int {
        return 512;
    }

    /// # Summary
    /// Returns the Haraka parameters to instantiate the sponge construction.
    function getHarakaSpec(rc : Int[][]) : SpongeSpec {
        return SpongeSpec(
            getHarakaStateSize(),
            getHarakaRate(),
            getHarakaSeparator(),
            haraka512Perm(_, rc)
        );
    }

    /// # Summary
    /// Sponge instantiation of Haraka Sponge for the absorb part
    operation harakaAbsorb(input : MaybeQbit[], state : Qubit[], rc : Int[][]) : Unit is Adj {
        absorb(input, state, getHarakaSpec(rc));
    }

    /// # Summary
    /// Sponge instantiation of Haraka Sponge for the squeeze part
    operation harakaSqueeze(state : Qubit[], output : Qubit[], rc : Int[][]) : Unit is Adj {
        squeeze(state, output, getHarakaSpec(rc));
    }

    /// # Summary
    /// Computes the Haraka Sponge hash value for the given input
    /// # Input
    /// ## input
    /// The input to compute the hash value for
    /// ## output
    /// The qbits for storing the hash value
    /// ## rc
    /// The round constants to use.
    operation harakaHash(input : MaybeQbit[], output : Qubit[], rc : Int[][]) : Unit is Adj {
        hash(input, output, getHarakaSpec(rc));
    }

}