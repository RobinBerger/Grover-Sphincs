namespace calculatehash {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arrays;
    open keccak.shake256;
    open haraka;
    open haraka.sponge;
    open common;
    open common.sponge;
    open common.maybeqbit;

    function toHexDigit(input : Int) : String {
        let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
        return digits[input];
    }

    function toHexByte(input : Int) : String {
        let firstDigit = toHexDigit((input >>> 4) &&& 0xF);
        let secondDigit = toHexDigit((input &&& 0xF));
        return $"{firstDigit}{secondDigit}";
    }

    function toHexStream(input : Int[]) : String {
        mutable output = "";
        for (current in input) {
            let currentHex = toHexByte(current);
            set output = $"{output}{currentHex}";
        }
        return output;
    }

    @EntryPoint()
    operation calculateHash(input : Int[], inputLength : Int, outputLength : Int, type : String) : Unit {
        mutable actualInput = input[0 .. inputLength - 1];
        mutable actualOutputLength = outputLength;
        mutable name = "Shake256";
        mutable hashFunction = hash(_, _, getShake256Spec());
        if (type == "shake") {
            //Default value
        } elif (type == "haraka") {
            set name = "Haraka-Sponge";
            set hashFunction = hash(_, _, getHarakaSpec(getDefaultConstants()));
        } elif (type == "haraka256"){
            set name = "Haraka256";
            set actualInput = actualInput + ConstantArray(32, 0);
            set actualInput = actualInput[0 .. 31];
            set actualOutputLength = 32;
            set hashFunction = haraka256(_, _, getDefaultConstants());
        } elif (type == "haraka512") {
            set name = "Haraka512";
            set actualInput = actualInput + ConstantArray(64, 0);
            set actualInput = actualInput[0 .. 63];
            set actualOutputLength = 32;
            set hashFunction = haraka512(_, _, getDefaultConstants());
        } else {
            fail $"Unknown hash function: ${type}";
        }
        let inputStr = toHexStream(actualInput);
        Message($"Input:\n{inputStr}");
        let output = toHexStream(doHashCalculation(actualInput, actualOutputLength, hashFunction));
        Message($"{name}:\n{output}");
    }

    operation measureMultiple(bits : Qubit[]) : Int[] {
        return ForEach(measureInt, Chunks(8, bits));
    }

    operation doHashCalculation(input : Int[], outputLength : Int, hashFunction : ((MaybeQbit[], Qubit[]) => Unit is Adj)) : Int[] {
        using ((inputQubits, outputQubits) = (Qubit[Length(input) * 8], Qubit[outputLength * 8])) {
            hashFunction(bytesToMaybeQbit(input), outputQubits);
            let result = measureMultiple(outputQubits);
            ResetAll(inputQubits + outputQubits);
            return result;
        }
    }
}

