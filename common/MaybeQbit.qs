namespace common.maybeqbit {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;

    /// # Summary
    /// MaybeQbit allows mixing classical input and quantum input for hash functions
    /// Use the wrapper operations instead of the operations referenced here.
    /// # Input
    /// ## xorOp
    /// This is the XOR operation. It XORs the current MaybeQubit on the given target.
    newtype MaybeQbit = (xorOp : (Qubit => Unit is Adj));

    /// # Summary
    /// XORs a given MaybeQbit onto a given target Qbit
    /// # Input
    /// ## input
    /// The input to XOR onto the other qubit
    /// ## target
    /// The target of the XOR operation
    operation maybeXORSingle(input : MaybeQbit, target : Qubit) : Unit is Adj {
        input::xorOp(target);
    }

    /// # Summary
    /// XORs multiple given MaybeQubits on multiple given target qbits. The first
    /// input is XORed on the first target, the second input is XORed on the second
    /// target and so on.
    /// # Input
    /// ## input
    /// The input to XOR on the target qbits
    /// ## target
    /// The target of the XOR operations
    operation maybeXOR(input : MaybeQbit[], target : Qubit[]) : Unit is Adj {
        Fact(Length(input) == Length(target), "Unmatched length.");
        for (i in 0 .. Length(input) - 1) {
            input[i]::xorOp(target[i]);
        }
    }

    /// # Summry
    /// Creates a MaybeQubit from a real qbit.
    /// # Input
    /// ## input
    /// The qbit to create the MaybeQbit from
    /// # Output
    /// The created MaybeQbit
    function qbitToMaybeQbit(input : Qubit) : MaybeQbit {
        return MaybeQbit(CNOT(input, _));
    }

    /// # Summry
    /// Creates an array of MaybeQubits from an array of real qbits.
    /// # Input
    /// ## input
    /// The qbits to create the MaybeQbits from
    /// # Output
    /// The created MaybeQbits
    function qbitsToMaybeQbit(input : Qubit[]) : MaybeQbit[] {
        return Mapped(qbitToMaybeQbit, input);
    }

    /// # Summry
    /// Creates a MaybeQubit from a bit.
    /// # Input
    /// ## input
    /// The bit to create the MaybeQbit from
    /// # Output
    /// The created MaybeQbit
    function bitToMaybeQbit(input : Bool) : MaybeQbit {
        if (input) {
            return MaybeQbit(X(_));
        } else {
            return MaybeQbit(I(_));
        }
    }

    /// # Summry
    /// Creates an array of MaybeQubits from the bits in the given byte.
    /// This creates 8 MaybeQbits from a byte
    /// # Input
    /// ## input
    /// The byte to create the MaybeQbits from
    /// # Output
    /// The created MaybeQbits
    function byteToMaybeQbit(input : Int) : MaybeQbit[] {
        mutable ret = new MaybeQbit[8];
        for (i in 0 .. 7) {
            set ret w/= i <- bitToMaybeQbit(((input >>> i) &&& 0x1) != 0);
        }
        return ret;
    }

    /// # Summry
    /// Creates an array of MaybeQubits from the bits in the given bytes.
    /// This creates 8 MaybeQubits for each given byte
    /// # Input
    /// ## input
    /// The bytes to create the MaybeQbits from
    /// # Output
    /// The created MaybeQbits
    function bytesToMaybeQbit(input : Int[]) : MaybeQbit[] {
        return FlatMapped(byteToMaybeQbit, input);
    }
}