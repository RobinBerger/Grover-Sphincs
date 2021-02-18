namespace grover {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;

    /// # Summary
    /// Flips the flag qubit if all normal qubits are 0.
    /// # Input
    /// ## normalBits
    /// The control qubits
    /// ## flagBit
    /// The qubit to flip
    operation zeroOracle(normalBits : Qubit[], flagBit : Qubit) : Unit is Adj {
        within {
            ApplyToEachCA(X, normalBits);
        } apply {
            Controlled X(normalBits, flagBit);
        }
    }

    /// # Summary
    /// Converts a marking oracle into a phase-flip oracle.
    /// The final phase-flip oracle can be obtained via
    /// let o = flipOracle(markingOracle, _);
    /// # Input
    /// ## reflectionOracle
    /// The marking oracle, flipping a bit if a condition is met.
    /// ## register
    /// The input to the oracle.
    operation flipOracle(reflectionOracle : ((Qubit[], Qubit) => Unit is Adj), register : Qubit[]) : Unit is Adj {
        using (target = Qubit()) {
            within {
                X(target);
                H(target);
            } apply {
                reflectionOracle(register, target);
            }
        }
    }

    /// # Summary
    /// Returns the amount of Grover iterations required for the largest success probability,
    /// if only a single element is marked from all elements with n bits.
    /// # Input
    /// ## nQBits
    /// The amount of qubits the input to Grover's oracle has.
    function getAmountIterations(nQBits : Int) : Int {
        let nItems = 1 <<< nQBits; // 2^numQubits
        // compute number of iterations:
        let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
        let nIterations = Round(0.25 * PI() / angle - 0.5);
        return nIterations;
    }

    /// # Summary
    /// Performs one iteration of Grover's algorithm
    /// # Input
    /// ## register
    /// The input to Grover's algorithm
    /// ## targetFlipOracle
    /// The grover oracle to use
    operation groverIteration(register : Qubit[], targetFlipOracle : (Qubit[] => Unit is Adj)) : Unit is Adj {
        let zeroFlipOracle = flipOracle(zeroOracle, _);
        targetFlipOracle(register);
        ApplyToEachCA(H, register);
        zeroFlipOracle(register);
        ApplyToEachCA(H, register);
    }

    /// # Summary
    /// Runs Grover's algorithm on the given qubits with the given oracle for the given amount of iterations.
    /// # Input
    /// ## register
    /// The input to Grover's algorithm
    /// ## oracle
    /// The phase-flip oracle implementing the predicate
    /// ## numIterations
    /// The amount of iterations to run Grover's algorithm for.
    operation groverSearch(register : Qubit[], oracle : (Qubit[] => Unit is Adj), numIterations : Int) : Unit is Adj {
        ApplyToEachCA(H, register);

        for (i in 0..numIterations - 1) {
            groverIteration(register, oracle);
        }
    }
}