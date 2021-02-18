
/// # Summary
/// Implementation of the mixing steps used in the Haraka Hash functions
namespace haraka.mixing {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    /// #  Summary
    /// Given an input and a index permutation, this method applies the inverse permutation to the array and return the result.
    /// # Input
    /// ## input
    /// The input for the inverse permutation
    /// ## permutation
    /// The forward permutation.
    /// # Output
    /// The inverse permutation applied to the input
    function inversePermutation<'T>(input : 'T[], permutation : (Int[] -> Int[])) : 'T[] {
        let len = Length(input);
        let permutationArray = permutation(RangeAsIntArray(0..len - 1));
        mutable result = new 'T[len];
        for (i in 0 .. len - 1) {
            set result w/= permutationArray[i] <- input[i];
        }
        return result;
    }

    /// # Summary
    /// The mixing permutation for the Haraka256 hash function
    function getMixedRegisters256<'T>(input : 'T[]) : 'T[] {
        Fact(Length(input) == 256, "Invalid input length.");
        let parts = Chunks(32, input);
        return parts[0] + parts[4] + parts[1] + parts[5] + parts[2] + parts[6] + parts[3] + parts[7];
    }

    /// # Summary
    /// The inverse mixing permutation for the Haraka256 hash function
    function getUnmixedRegisters256<'T>(input : 'T[]) : 'T[] {
        return inversePermutation(input, getMixedRegisters256<Int>);
    }

    /// # Summary
    /// The mixing permutation for the Haraka512 hash function
    function getMixedRegisters512<'T>(input : 'T[]) : 'T[] {
        Fact(Length(input) == 512, "Invalid input length.");
        let parts = Chunks(32, input);
        return parts[3] + parts[11] + parts[7] + parts[15] + parts[8] + parts[0] + parts[12] + parts[4] + parts[9] + parts[1] + parts[13] + parts[5] + parts[2] + parts[10] + parts[6] + parts[14];
    }

    /// # Summary
    /// The inverse mixing permutation for the Haraka512 hash function
    function getUnmixedRegisters512<'T>(input : 'T[]) : 'T[] {
        Fact(Length(input) == 512, "Invalid input length.");
        return inversePermutation(input, getMixedRegisters512<Int>);
    }
}