namespace grover.estimator {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.AmplitudeAmplification;
    open Microsoft.Quantum.Oracles;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Diagnostics;
    open common;
    open common.sponge;
    open common.maybeqbit;
    open keccak.shake256;
    open haraka;
    open haraka.sponge;
    open grover.oracles;

    operation failHashFunction(input : MaybeQbit[], output : Qubit[], message : String) : Unit is Adj {
        fail message;
    }

    @EntryPoint()
    operation run(functionType : String, evaluationType : String, prefixLength : Int, inputLength : Int, outputLength : Int) : Unit {
        mutable hashFunction = failHashFunction(_, _, "Not possible for this hash function.");
        mutable spec = SpongeSpec(8, 8, 0, failHashFunction(new MaybeQbit[0], _, "Not possible for this hash function."));
        let prefix = bytesToMaybeQbit(ConstantArray(prefixLength, 0));
        
        if (functionType == "shake") {
            set spec = getShake256Spec();
            set hashFunction = hash(_, _, spec);
        } elif (functionType == "haraka") {
            set spec = getHarakaSpec(getZeroConstants());
            set hashFunction = hash(_, _, spec);
        } elif (functionType == "haraka256") {
            set spec = SpongeSpec(256, 0, 0, haraka256Perm(_, getZeroConstants()));
            set hashFunction = haraka256(_, _, getZeroConstants());
        } elif (functionType == "haraka512") {
            set spec = SpongeSpec(512, 0, 0, haraka512Perm(_, getZeroConstants()));
            set hashFunction = haraka512(_, _, getZeroConstants());
        } elif (functionType == "harakaDefault") {
            set spec = getHarakaSpec(getDefaultConstants());
            set hashFunction = hash(_, _, spec);
        } elif (functionType == "haraka256Default") {
            set spec = SpongeSpec(256, 0, 0, haraka256Perm(_, getDefaultConstants()));
            set hashFunction = haraka256(_, _, getDefaultConstants());
        } elif (functionType == "haraka512Default") {
            set spec = SpongeSpec(512, 0, 0, haraka512Perm(_, getDefaultConstants()));
            set hashFunction = haraka512(_, _, getDefaultConstants());
        } else {
            fail "Unknown hash function.";
        }

        if (evaluationType == "hash") {
            using ((input, output) = (Qubit[inputLength * 8], Qubit[outputLength * 8])) {
                let actualInput = prefix + qbitsToMaybeQbit(input);
                hashFunction(actualInput, output);
            }
        } elif (evaluationType == "permutation") {
            using (state = Qubit[spec::stateSize]) {
                spec::permutation(state);
            }
        } elif (evaluationType == "hashOracle") {
            using (inputBits = Qubit[inputLength * 8]) {
                let actualInput = prefix + qbitsToMaybeQbit(inputBits);
                hashOracle(actualInput, ConstantArray(inputLength, 0), hashFunction);
            }
        } elif (evaluationType == "spongeHash") {
            using (inputBits = Qubit[inputLength * 8]) {
                let actualInput = prefix + qbitsToMaybeQbit(inputBits);
                spongeHashOracle(actualInput, ConstantArray(outputLength, 0), spec);
            }
        } elif (evaluationType == "recursive") {
            // Prefix length here is the recursion depth
            let recursionDepth = prefixLength;
            // Input length here is the block length of the input
            // Output length is the security parameter
            using (input = Qubit[outputLength * 8]) {
                recursiveHashOracle(input, hashFunction, ConstantArray(outputLength, 0), ConstantArray(recursionDepth, ConstantArray(outputLength, 0)), inputLength * 8);
            }
        } elif (evaluationType == "diffusion") {
            using (bits = Qubit[inputLength * 8]) {
                diffusion(bits);
            }
        } else {
            fail "Unknown evaluation target.";
        }
    }
}

