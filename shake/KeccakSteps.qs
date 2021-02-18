
namespace keccak.estimate {

    open keccak;

    @EntryPoint()
    operation runStep(step : String) : Unit {
        // Simulates individual steps of the keccak permutation to allow getting more specific resource estimates.
        if (step == "theta") {
            using ((state, cBits, dBits) = (Qubit[1600], Qubit[320], Qubit[320])) {
                let input = getState(divideIntoQInts(state));
                let c = divideIntoQInts(cBits);
                let d = divideIntoQInts(dBits);
                calculateDFromInput(input, d, c);
                theta(input, d);
                Adjoint calculateDFromOutput(input, d, c);
            }
        } elif (step == "chi") {
            using ((inputBits, outputBits) = (Qubit[1600], Qubit[1600])) {
                let input = getState(divideIntoQInts(inputBits));
                let output = getState(divideIntoQInts(outputBits));
                chi(input, output);
            }
        } elif (step == "inversechi") {
            using ((inputBits, outputBits) = (Qubit[1600], Qubit[1600])) {
                let input = getState(divideIntoQInts(inputBits));
                let output = getState(divideIntoQInts(outputBits));
                inverseChi(input, output);
            }
        } elif (step == "iota") {
            using (stateBits = Qubit[1600]) {
                let state = getState(divideIntoQInts(stateBits));
                for (i in 0 .. getAmountRounds() - 1) {
                    iota(state, i);
                }
            }
        } else {
            fail "Unknown Argument";
        }
    }
}