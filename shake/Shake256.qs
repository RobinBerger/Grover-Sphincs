
/// # Summary
/// Implementation of the shake256 hash function.
namespace keccak.shake256 {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open keccak;
    open common.sponge;
    open common.maybeqbit;

    /// # Summary
    /// Returns the rate for the Shake256 hash function.
    function getShake256Rate() : Int {
        return 136;
    }

    /// # Summary
    /// Returns the separator byte for the Shake256 hash function.
    function getShake256Separator() : Int {
        return 0x1F;
    }

    /// # Summary
    /// Returns the state size for the Shake256 hash function.
    function getShake256StateSize() : Int {
        return 25 * 64;
    }

    /// # Summary
    /// Returns the Shake256 parameters to instantiate the sponge construction.
    function getShake256Spec() : SpongeSpec {
        return SpongeSpec(
            getShake256StateSize(),
            getShake256Rate(),
            getShake256Separator(),
            keccakPermutation
            );
    }

    /// # Summary
    /// Sponge instantiation of Shake256 for the absorb part
    operation shake256Absorb(input : MaybeQbit[], state : Qubit[], rate : Int, separator : Int) : Unit is Adj {
        absorb(input, state, getShake256Spec());
    }

    /// # Summary
    /// Sponge instantiation of Shake256 for the squeeze part
    operation shake256Squeeze(state : Qubit[], output : Qubit[], rate : Int) : Unit is Adj {
        squeeze(state, output, getShake256Spec());
    }

    /// # Summary
    /// Computes the Shake256 hash value for the given input
    /// # Input
    /// ## input
    /// The input to compute the hash value for
    /// ## output
    /// The qbits for storing the hash value
    operation shake256Hash(input : MaybeQbit[], output : Qubit[]) : Unit is Adj {
        hash(input, output, getShake256Spec());
    }
}