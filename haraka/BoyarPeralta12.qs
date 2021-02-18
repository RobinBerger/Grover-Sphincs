// Based on
// https://github.com/microsoft/grover-blocks/blob/master/aes/BoyarPeralta12.qs
// and
// https://www.nist.gov/publications/depth-16-circuit-aes-s-box

/// # Summary
/// Implementation of the AES S-Box and inverse S-Box
/// For details, see the referenced paper.
namespace BoyarPeralta11 {
    open Microsoft.Quantum.Intrinsic;
    open QUtilities;

    /// # Summary
    /// Computes the AES S-Box of the input into the output
    /// # Input
    /// ## input
    /// The input to the AES S-Box
    /// ## output
    /// The qbits to store the output
    operation SBox(input: Qubit[], output: Qubit[], costing: Bool) : Unit is Adj {
        using ((t, m, l) = (Qubit[27], Qubit[63], Qubit[30])) {
            let u = input[7..(-1)..0];
            let s = output[7..(-1)..0];

            forwardSBox(u, s, t, m, l, true, costing);
            Adjoint forwardSBox(u, s, t, m, l, false, costing);
        }
    }

    /// # Summary
    /// Computes the inverse AES S-Box of the input into the output
    /// # Input
    /// ## input
    /// The input to the inverse AES S-Box
    /// ## output
    /// The qbits to store the output
    operation inverseSBox(input : Qubit[], output : Qubit[], costing : Bool) : Unit is Adj {
        using ((t, m, p) = (Qubit[27], Qubit[63], Qubit[30])) {
            let u = input[7..-1..0];
            let w = output[7..-1..0];

            //Use unused qubits from t to store yzero and the r variables.
            let yzero = t[21-1];
            let r = [t[5-1], t[7-1], t[11-1], t[12-1], t[18-1]];

            backwardsSBox(u, w, t, yzero, r, m, p, true, costing);
            Adjoint backwardsSBox(u, w, t, yzero, r, m, p, false, costing);
        }
    }

    operation forwardSBox(u: Qubit[], s: Qubit[], t: Qubit[], m: Qubit[], l: Qubit[], applyResult : Bool, costing: Bool) : Unit is Adj {
        forwardSBoxBegin(u, t);
        sharedSBox(u[7], t, m, costing);
        forwardSBoxEnd(m, l, s, applyResult);
    }

    operation backwardsSBox(u: Qubit[], w : Qubit[], t: Qubit[], yzero : Qubit, r: Qubit[], m: Qubit[], p : Qubit[], applyResult : Bool, costing: Bool) : Unit is Adj {
        backwardsSBoxBegin(u, t, yzero, r);
        sharedSBox(yzero, t, m, costing);
        backwardsSBoxEnd(p, m, w, applyResult);
    }

    operation sharedSBox(d : Qubit, t : Qubit[], m : Qubit[], costing : Bool) : Unit is Adj {
        LPAND(t[13-1], t[6-1], m[1-1], costing);
        LPAND(t[23-1], t[8-1], m[2-1], costing);
        LPXOR(t[14-1], m[1-1], m[3-1]);
        LPAND(t[19-1], d, m[4-1], costing);
        LPXOR(m[4-1], m[1-1], m[5-1]);
        LPAND(t[3-1], t[16-1], m[6-1], costing);
        LPAND(t[22-1], t[9-1], m[7-1], costing);
        LPXOR(t[26-1], m[6-1], m[8-1]);
        LPAND(t[20-1], t[17-1], m[9-1], costing);
        LPXOR(m[9-1], m[6-1], m[10-1]);
        LPAND(t[1-1], t[15-1], m[11-1], costing);
        LPAND(t[4-1], t[27-1], m[12-1], costing);
        LPXOR(m[12-1], m[11-1], m[13-1]);
        LPAND(t[2-1], t[10-1], m[14-1], costing);
        LPXOR(m[14-1], m[11-1], m[15-1]);
        LPXOR(m[3-1], m[2-1], m[16-1]);
        LPXOR(m[5-1], t[24-1], m[17-1]);
        LPXOR(m[8-1], m[7-1], m[18-1]);
        LPXOR(m[10-1], m[15-1], m[19-1]);
        LPXOR(m[16-1], m[13-1], m[20-1]);
        LPXOR(m[17-1], m[15-1], m[21-1]);
        LPXOR(m[18-1], m[13-1], m[22-1]);
        LPXOR(m[19-1], t[25-1], m[23-1]);
        LPXOR(m[22-1], m[23-1], m[24-1]);
        LPAND(m[22-1], m[20-1], m[25-1], costing);
        LPXOR(m[21-1], m[25-1], m[26-1]);
        LPXOR(m[20-1], m[21-1], m[27-1]);
        LPXOR(m[23-1], m[25-1], m[28-1]);
        LPAND(m[28-1], m[27-1], m[29-1], costing);
        LPAND(m[26-1], m[24-1], m[30-1], costing);
        LPAND(m[20-1], m[23-1], m[31-1], costing);
        LPAND(m[27-1], m[31-1], m[32-1], costing);
        LPXOR(m[27-1], m[25-1], m[33-1]);
        LPAND(m[21-1], m[22-1], m[34-1], costing);
        LPAND(m[24-1], m[34-1], m[35-1], costing);
        LPXOR(m[24-1], m[25-1], m[36-1]);
        LPXOR(m[21-1], m[29-1], m[37-1]);
        LPXOR(m[32-1], m[33-1], m[38-1]);
        LPXOR(m[23-1], m[30-1], m[39-1]);
        LPXOR(m[35-1], m[36-1], m[40-1]);
        LPXOR(m[38-1], m[40-1], m[41-1]);
        LPXOR(m[37-1], m[39-1], m[42-1]);
        LPXOR(m[37-1], m[38-1], m[43-1]);
        LPXOR(m[39-1], m[40-1], m[44-1]);
        LPXOR(m[42-1], m[41-1], m[45-1]);
        LPAND(m[44-1], t[6-1], m[46-1], costing);
        LPAND(m[40-1], t[8-1], m[47-1], costing);
        LPAND(m[39-1], d, m[48-1], costing);
        LPAND(m[43-1], t[16-1], m[49-1], costing);
        LPAND(m[38-1], t[9-1], m[50-1], costing);
        LPAND(m[37-1], t[17-1], m[51-1], costing);
        LPAND(m[42-1], t[15-1], m[52-1], costing);
        LPAND(m[45-1], t[27-1], m[53-1], costing);
        LPAND(m[41-1], t[10-1], m[54-1], costing);
        LPAND(m[44-1], t[13-1], m[55-1], costing);
        LPAND(m[40-1], t[23-1], m[56-1], costing);
        LPAND(m[39-1], t[19-1], m[57-1], costing);
        LPAND(m[43-1], t[3-1], m[58-1], costing);
        LPAND(m[38-1], t[22-1], m[59-1], costing);
        LPAND(m[37-1], t[20-1], m[60-1], costing);
        LPAND(m[42-1], t[1-1], m[61-1], costing);
        LPAND(m[45-1], t[4-1], m[62-1], costing);
        LPAND(m[41-1], t[2-1], m[63-1], costing);
    }

    operation forwardSBoxBegin(u : Qubit[], t : Qubit[]) : Unit is Adj {
        LPXOR(u[0], u[3], t[1-1]);
        LPXOR(u[0], u[5], t[2-1]);
        LPXOR(u[0], u[6], t[3-1]);
        LPXOR(u[3], u[5], t[4-1]);
        LPXOR(u[4], u[6], t[5-1]);
        LPXOR(t[1-1], t[5-1], t[6-1]);
        LPXOR(u[1], u[2], t[7-1]);
        LPXOR(u[7], t[6-1], t[8-1]);
        LPXOR(u[7], t[7-1], t[9-1]);
        LPXOR(t[6-1], t[7-1], t[10-1]);
        LPXOR(u[1], u[5], t[11-1]);
        LPXOR(u[2], u[5], t[12-1]);
        LPXOR(t[3-1], t[4-1], t[13-1]);
        LPXOR(t[6-1], t[11-1], t[14-1]);
        LPXOR(t[5-1], t[11-1], t[15-1]);
        LPXOR(t[5-1], t[12-1], t[16-1]);
        LPXOR(t[9-1], t[16-1], t[17-1]);
        LPXOR(u[3], u[7], t[18-1]);
        LPXOR(t[7-1], t[18-1], t[19-1]);
        LPXOR(t[1-1], t[19-1], t[20-1]);
        LPXOR(u[6], u[7], t[21-1]);
        LPXOR(t[7-1], t[21-1], t[22-1]);
        LPXOR(t[2-1], t[22-1], t[23-1]);
        LPXOR(t[2-1], t[10-1], t[24-1]);
        LPXOR(t[20-1], t[17-1], t[25-1]);
        LPXOR(t[3-1], t[16-1], t[26-1]);
        LPXOR(t[1-1], t[12-1], t[27-1]);
    }

    operation forwardSBoxEnd(m  : Qubit[], l : Qubit[], s : Qubit[], applyResult : Bool) : Unit is Adj {
        LPXOR(m[61-1], m[62-1], l[0]);
        LPXOR(m[50-1], m[56-1], l[1]);
        LPXOR(m[46-1], m[48-1], l[2]);
        LPXOR(m[47-1], m[55-1], l[3]);
        LPXOR(m[54-1], m[58-1], l[4]);
        LPXOR(m[49-1], m[61-1], l[5]);
        LPXOR(m[62-1], l[5], l[6]);
        LPXOR(m[46-1], l[3], l[7]);
        LPXOR(m[51-1], m[59-1], l[8]);
        LPXOR(m[52-1], m[53-1], l[9]);
        LPXOR(m[53-1], l[4], l[10]);
        LPXOR(m[60-1], l[2], l[11]);
        LPXOR(m[48-1], m[51-1], l[12]);
        LPXOR(m[50-1], l[0], l[13]);
        LPXOR(m[52-1], m[61-1], l[14]);
        LPXOR(m[55-1], l[1], l[15]);
        LPXOR(m[56-1], l[0], l[16]);
        LPXOR(m[57-1], l[1], l[17]);
        LPXOR(m[58-1], l[8], l[18]);
        LPXOR(m[63-1], l[4], l[19]);
        LPXOR(l[0], l[1], l[20]);
        LPXOR(l[1], l[7], l[21]);
        LPXOR(l[3], l[12], l[22]);
        LPXOR(l[18], l[2], l[23]);
        LPXOR(l[15], l[9], l[24]);
        LPXOR(l[6], l[10], l[25]);
        LPXOR(l[7], l[9], l[26]);
        LPXOR(l[8], l[10], l[27]);
        LPXOR(l[11], l[14], l[28]);
        LPXOR(l[11], l[17], l[29]);

        if (applyResult) {
            LPXOR(l[6], l[24], s[0]);
            LPXNOR(l[16], l[26], s[1]);
            LPXNOR(l[19], l[28], s[2]);
            LPXOR(l[6], l[21], s[3]);
            LPXOR(l[20], l[22], s[4]);
            LPXOR(l[25], l[29], s[5]);
            LPXNOR(l[13], l[27], s[6]);
            LPXNOR(l[6], l[23], s[7]);
        }
    }

    operation backwardsSBoxBegin(u : Qubit[], t : Qubit[], yzero : Qubit, r : Qubit[]) : Unit is Adj {
        //We only need 5 qubits here and not 20
        let rfive = r[0];
        let rthirteen = r[1];
        let rseventeen = r[2];
        let reighteen = r[3];
        let rnineteen = r[4];
        LPXOR(u[0], u[3], t[23-1]);
        LPXNOR(u[1], u[3], t[22-1]);
        LPXNOR(u[0], u[1], t[2-1]);
        LPXOR(u[3], u[4], t[1-1]);
        LPXNOR(u[4], u[7], t[24-1]);
        LPXOR(u[6], u[7], rfive);
        LPXNOR(u[1], t[23 - 1], t[8-1]);
        LPXOR(t[22-1], rfive, t[19-1]);
        LPXNOR(u[7], t[1-1], t[9-1]);
        LPXOR(t[2-1], t[24-1], t[10-1]);
        LPXOR(t[2-1], rfive, t[13-1]);
        LPXOR(t[1-1], rfive, t[3-1]);
        LPXNOR(u[2], t[1-1], t[25-1]);
        LPXOR(u[1], u[6], rthirteen);
        LPXNOR(u[2], t[19-1], t[17-1]);
        LPXOR(t[24-1], rthirteen, t[20-1]);
        LPXOR(u[4], t[8-1], t[4-1]);
        LPXNOR(u[2], u[5], rseventeen);
        LPXNOR(u[5], u[6], reighteen);
        LPXNOR(u[2], u[4], rnineteen);
        LPXOR(u[0], rseventeen, yzero);
        LPXOR(t[22 - 1], rseventeen, t[6-1]);
        LPXOR(rthirteen, rnineteen, t[16-1]);
        LPXOR(t[1-1], reighteen, t[27-1]);
        LPXOR(t[10-1], t[27-1], t[15-1]);
        LPXOR(t[10-1], reighteen, t[14-1]);
        LPXOR(t[3-1], t[16-1], t[26-1]);
    }

    operation backwardsSBoxEnd(p : Qubit[], m : Qubit[], w : Qubit[], applyResult : Bool) : Unit is Adj {
        LPXOR(m[52-1], m[61-1], p[0]);
        LPXOR(m[58-1], m[59-1], p[1]);
        LPXOR(m[54-1], m[62-1], p[2]);
        LPXOR(m[47-1], m[50-1], p[3]);
        LPXOR(m[48-1], m[56-1], p[4]);
        LPXOR(m[46-1], m[51-1], p[5]);
        LPXOR(m[49-1], m[60-1], p[6]);
        LPXOR(p[0], p[1], p[7]);
        LPXOR(m[50-1], m[53-1], p[8]);
        LPXOR(m[55-1], m[63-1], p[9]);
        LPXOR(m[57-1], p[4], p[10]);
        LPXOR(p[0], p[3], p[11]);
        LPXOR(m[46-1], m[48-1], p[12]);
        LPXOR(m[49-1], m[51-1], p[13]);
        LPXOR(m[49-1], m[62-1], p[14]);
        LPXOR(m[54-1], m[59-1], p[15]);
        LPXOR(m[57-1], m[61-1], p[16]);
        LPXOR(m[58-1], p[2], p[17]);
        LPXOR(m[63-1], p[5], p[18]);
        LPXOR(p[2], p[3], p[19]);
        LPXOR(p[4], p[6], p[20]);
        LPXOR(p[2], p[7], p[22]);
        LPXOR(p[7], p[8], p[23]);
        LPXOR(p[5], p[7], p[24]);
        LPXOR(p[6], p[10], p[25]);
        LPXOR(p[9], p[11], p[26]);
        LPXOR(p[10], p[18], p[27]);
        LPXOR(p[11], p[25], p[28]);
        LPXOR(p[15], p[20], p[29]);

        if (applyResult) {
            LPXOR(p[13], p[22], w[0]);
            LPXOR(p[26], p[29], w[1]);
            LPXOR(p[17], p[28], w[2]);
            LPXOR(p[12], p[22], w[3]);
            LPXOR(p[23], p[27], w[4]);
            LPXOR(p[19], p[24], w[5]);
            LPXOR(p[14], p[23], w[6]);
            LPXOR(p[9], p[16], w[7]);
        }
    }
}