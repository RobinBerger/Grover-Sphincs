namespace keccak.test {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open keccak;
    open keccak.shake256;
    open common;
    open common.test;
    open common.maybeqbit;

    /// # Summary
    /// performs a known input known outptut test of the keccak permutation given the inputs and expected outputs.
    operation performStatePermute(input : BigInt[], output : BigInt[]) : Unit {
        using (state = Qubit[25 * 64]) {
            initialize64(state, input);

            keccakPermutation(state);

            assert64Multiple(state, output, "");
            ResetAll(state);
        }
    }

    @Test("ToffoliSimulator")
    operation testStatePermuteSimple() : Unit {
        let input = [
                0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L
            ];
        let output = [
                0xf1258f7940e1dde7L, 0x84d5ccf933c0478aL, 0xd598261ea65aa9eeL, 0xbd1547306f80494dL, 0x8b284e056253d057L, 0xff97a42d7f8e6fd4L, 0x90fee5a0a44647c4L, 0x8c5bda0cd6192e76L, 0xad30a6f71b19059cL, 0x30935ab7d08ffc64L, 0xeb5aa93f2317d635L, 0xa9a6e6260d712103L, 0x81a57c16dbcf555fL, 0x43b831cd0347c826L, 0x01f22f1a11a5569fL, 0x05e5635a21d9ae61L, 0x64befef28cc970f2L, 0x613670957bc46611L, 0xb87c5a554fd00ecbL, 0x8c3ee88a1ccf32c8L, 0x940c7922ae3a2614L, 0x1841f924a2c509e4L, 0x16f53526e70465c2L, 0x75f644e97f30a13bL, 0xeaf1ff7b5ceca249L
            ];
        performStatePermute(input, output);
    }

    @Test("ToffoliSimulator")
    operation testStatePermuteAdvanced() : Unit {
        let input = [
                0x927098cc84cdd4cdL, 0xbb7461967bd7f0e1L, 0x7ced2a0430443cd7L, 0xd40e5b430e58c07bL, 0xf35a064046611bf1L, 0x2f96068fe71557b7L, 0xc5a06f4e8f614ffbL, 0x4c9cdf7a2f3cfe22L, 0x0483aa93087e21bbL, 0x78fbc387a30bd235L, 0xa3555b3c06b26504L, 0x93d1f91ee5666022L, 0xcf58cbb8eeeef714L, 0xe19cd814cfd160d1L, 0x218cda6b21ae3f3eL, 0xaec8e7836277e525L, 0x36db7d9ab4ac95c8L, 0xa1d684de0a527182L, 0x872912ade185b516L, 0xcd396847e3a5cd93L, 0x24acec95f9559907L, 0x9bbb9a2305388c48L, 0xb59fd58c267d709eL, 0x3da1ade6990a901eL, 0xc1e477fb249385e4L
            ];
        let output = [
                0x718aa3a151859c64L, 0x194381b67a60ca55L, 0x03392fe84c87231dL, 0x51c1379f6938aa6dL, 0x908bd0dfdc0910dfL, 0xa7e8cee05d60ba0dL, 0x4c34e521098a8b0aL, 0x72dab6c359b19bcaL, 0x38197bcb28950589L, 0x32903fbf4a63e820L, 0x3a3a647c51435c62L, 0x904b0c854fe6d949L, 0x171c44cbf060e299L, 0xfd088894f64d1d41L, 0xb80d72e9e2921a4cL, 0x1963eb7acf3a0273L, 0x54ac09886957cb59L, 0x8f0437ab5522b9efL, 0x5148e578f5dd8851L, 0x869d8e62f7575d6fL, 0x0847b970c1a7daf9L, 0xc62eeb2c9cd3c6ddL, 0xf230881fdf3ecab7L, 0xe085fc9881d521beL, 0x90da1773a0f5b129L
            ];
        performStatePermute(input, output);
    }

    /// # Summary
    /// performs a known input known outptut test of the squeeze step of a keccak based hash function given the inputs and expected outputs.
    operation performSqueeze(oldState : BigInt[], newState : BigInt[], nBlocks : Int, output : BigInt[]) : Unit {
        let shake256Rate = getShake256Rate(); // in bytes
        using (state = Qubit[25 * 64]) {

            initialize64(state, oldState);

            using (outputBits = Qubit[nBlocks * shake256Rate / 8 * 64]) {

                keccakSqueeze(outputBits, nBlocks * shake256Rate, state, shake256Rate);

                assert64Multiple(outputBits, output, "Incorrect Output when squeezing blocks.");
                ResetAll(outputBits);
            }

            assert64Multiple(state, newState, "Incorrect State when squeezing blocks.");
            ResetAll(state);
        }
    }

    @Test("ToffoliSimulator")
    operation testSqueezeBlocksSimple() : Unit {
        performSqueeze([
            0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L
        ], [
            0xf1258f7940e1dde7L, 0x84d5ccf933c0478aL, 0xd598261ea65aa9eeL, 0xbd1547306f80494dL, 0x8b284e056253d057L, 0xff97a42d7f8e6fd4L, 0x90fee5a0a44647c4L, 0x8c5bda0cd6192e76L, 0xad30a6f71b19059cL, 0x30935ab7d08ffc64L, 0xeb5aa93f2317d635L, 0xa9a6e6260d712103L, 0x81a57c16dbcf555fL, 0x43b831cd0347c826L, 0x01f22f1a11a5569fL, 0x05e5635a21d9ae61L, 0x64befef28cc970f2L, 0x613670957bc46611L, 0xb87c5a554fd00ecbL, 0x8c3ee88a1ccf32c8L, 0x940c7922ae3a2614L, 0x1841f924a2c509e4L, 0x16f53526e70465c2L, 0x75f644e97f30a13bL, 0xeaf1ff7b5ceca249L
        ], 1, [
            0xf1258f7940e1dde7L, 0x84d5ccf933c0478aL, 0xd598261ea65aa9eeL, 0xbd1547306f80494dL, 0x8b284e056253d057L, 0xff97a42d7f8e6fd4L, 0x90fee5a0a44647c4L, 0x8c5bda0cd6192e76L, 0xad30a6f71b19059cL, 0x30935ab7d08ffc64L, 0xeb5aa93f2317d635L, 0xa9a6e6260d712103L, 0x81a57c16dbcf555fL, 0x43b831cd0347c826L, 0x01f22f1a11a5569fL, 0x05e5635a21d9ae61L, 0x64befef28cc970f2L
        ]);
    }

    @Test("ToffoliSimulator")
    operation testSqueezeBlocksAdvanced() : Unit {
        performSqueeze([
            0x927098cc84cdd4cdL, 0xbb7461967bd7f0e1L, 0x7ced2a0430443cd7L, 0xd40e5b430e58c07bL, 0xf35a064046611bf1L, 0x2f96068fe71557b7L, 0xc5a06f4e8f614ffbL, 0x4c9cdf7a2f3cfe22L, 0x0483aa93087e21bbL, 0x78fbc387a30bd235L, 0xa3555b3c06b26504L, 0x93d1f91ee5666022L, 0xcf58cbb8eeeef714L, 0xe19cd814cfd160d1L, 0x218cda6b21ae3f3eL, 0xaec8e7836277e525L, 0x36db7d9ab4ac95c8L, 0xa1d684de0a527182L, 0x872912ade185b516L, 0xcd396847e3a5cd93L, 0x24acec95f9559907L, 0x9bbb9a2305388c48L, 0xb59fd58c267d709eL, 0x3da1ade6990a901eL, 0xc1e477fb249385e4L
        ], [
            0x4e4d6d2bcdcddcc7L, 0xbd08f5a055bb2947L, 0x9c4935bfd78c959dL, 0x488d7295b8d6059fL, 0x41572093b9ab8660L, 0x82dcc1491946bc26L, 0x7377b674ce03aaf7L, 0xaf0bcbd925f3d399L, 0x3a8d9a1e93351f6bL, 0x52aa7422ee0cf47fL, 0x4e658d65faf5cbdaL, 0xe9747b13d775eda4L, 0x72b13c75b2bbfe33L, 0xf0c120ff18f30527L, 0x8a71e783c84d37f2L, 0x45c2f4ef2ba124ccL, 0x94c94e8c81f93295L, 0x54701e1f33882693L, 0xabcccc491196ea3fL, 0x61dabf7c9cec6039L, 0x8d2d34dd6e9bbda1L, 0xcff1bb99c5b59564L, 0x7673b5db094e978bL, 0x4c8234f3d52ee88aL, 0x1e48584623614fedL
        ], 3, [
            0x718aa3a151859c64L, 0x194381b67a60ca55L, 0x03392fe84c87231dL, 0x51c1379f6938aa6dL, 0x908bd0dfdc0910dfL, 0xa7e8cee05d60ba0dL, 0x4c34e521098a8b0aL, 0x72dab6c359b19bcaL, 0x38197bcb28950589L, 0x32903fbf4a63e820L, 0x3a3a647c51435c62L, 0x904b0c854fe6d949L, 0x171c44cbf060e299L, 0xfd088894f64d1d41L, 0xb80d72e9e2921a4cL, 0x1963eb7acf3a0273L, 0x54ac09886957cb59L, 0x8e3473e22154f72bL, 0x884edaef6247fef1L, 0x6d33cc0ebeb2cf9dL, 0xb9c28f9082f1be50L, 0x8b10e2533d55837cL, 0xf0bee66424b6c880L, 0x57aa0b728cf91388L, 0x8195e0bd247932bcL, 0x8469246917ef3054L, 0xcf9340b60a841b30L, 0x6a389d5ff6424e2dL, 0x92fe3e35a41587d4L, 0x0488e12a3f5adf87L, 0x34cf2e0b81c3f0aaL, 0x5ebd614d622e884dL, 0xc813f8cf9070fd72L, 0xebb4c6bc5fb4b5f9L, 0x4e4d6d2bcdcddcc7L, 0xbd08f5a055bb2947L, 0x9c4935bfd78c959dL, 0x488d7295b8d6059fL, 0x41572093b9ab8660L, 0x82dcc1491946bc26L, 0x7377b674ce03aaf7L, 0xaf0bcbd925f3d399L, 0x3a8d9a1e93351f6bL, 0x52aa7422ee0cf47fL, 0x4e658d65faf5cbdaL, 0xe9747b13d775eda4L, 0x72b13c75b2bbfe33L, 0xf0c120ff18f30527L, 0x8a71e783c84d37f2L, 0x45c2f4ef2ba124ccL, 0x94c94e8c81f93295L
        ]);
    }

    /// # Summary
    /// performs a known input known outptut test of the absorb step of a keccak based hash function given the inputs and expected outputs.
    operation performAbsorb(originalInput : BigInt[], inputLength : Int, expectedState : BigInt[]) : Unit {
        let shake256Rate = getShake256Rate(); // in bytes
        let shake256Separator = getShake256Separator();

        using ((inputBits, state) = (Qubit[inputLength * 8], Qubit[25 * 64])) {

            initialize64(inputBits, originalInput);

            keccakAbsorb(state, qbitsToMaybeQbit(inputBits), shake256Rate, shake256Separator);

            assert64Multiple(state, expectedState, "");

            ResetAll(inputBits);
            ResetAll(state);
        }

    }

    @Test("ToffoliSimulator")
    operation testAbsorbNoInput() : Unit {
        performAbsorb(new BigInt[0], 0, [
            0x000000000000001fL, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x8000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L
        ]);
    }

    @Test("ToffoliSimulator")
    operation testAbsorbSmall() : Unit {
        performAbsorb([
            0x00000000badc0de1L
        ], 4, [
            0x0000001fbadc0de1L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x8000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L
        ]);
    }

    @Test("ToffoliSimulator")
    operation testAbsorbMultipleBigInts() : Unit {
        performAbsorb([
            0xb7b41bcaf97c1c58L, 0x56c9cd1528850ce2L, 0x833974e619b4a23eL
        ], 24, [
            0xb7b41bcaf97c1c58L, 0x56c9cd1528850ce2L, 0x833974e619b4a23eL, 0x000000000000001fL, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x8000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L
        ]);
    }

    @Test("ToffoliSimulator")
    operation testAbsorbMisaligned() : Unit {
        performAbsorb([
            0x63980d4f0ddb15b9L, 0x3df124f24f639138L, 0x97ea07bb38d06d56L, 0x5755d9cc83b4dd65L, 0x0097f1c3b186a71fL
        ], 39, [
            0x63980d4f0ddb15b9L, 0x3df124f24f639138L, 0x97ea07bb38d06d56L, 0x5755d9cc83b4dd65L, 0x1f97f1c3b186a71fL, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x8000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L, 0x0000000000000000L
        ]);
    }

    @Test("ToffoliSimulator")
    operation testAbsorbLong() : Unit {
        performAbsorb([
            0xceef0f08bac44445L, 0x913c2b9fbc9b6437L, 0x62f4b1514634fd40L, 0x4a35ef661ff76924L, 0x912283cbe7479aa7L, 0x00b0283372beb766L, 0x40001fe86ea4bcc3L, 0x22baa1e1da8b58c8L, 0x985e19ddb085ce31L, 0x4bd7cc842099b2f5L, 0xb7f49ddf176aab0aL, 0x3daf3eb7f4517d3bL, 0x9b322c8d41601644L, 0x14b5893e8341ce91L, 0xabd52aac406da157L, 0x38452fce5ec187dbL, 0x94623818b707ea23L, 0xe10ddb2622b59e6bL, 0x933481f9bfce5310L, 0x317c186249130acbL
        ], 160, [
            0x7b0ba6ccb43461c2L, 0x9e387bdd0bf5932cL, 0xdc2947139e30abdcL, 0xee8070e9c54b2401L, 0x8901c4f94da99c24L, 0xeae50bb5f72e810dL, 0x3519ffea8e2b3b2fL, 0x59c2aa28f61d35a1L, 0x9df06c39478f7139L, 0xbbbd1b134f6d6ca0L, 0x0bd8f25d2501b3efL, 0x9b01afed8a433800L, 0xe5e8a32e1e5c50c3L, 0x6cca22c50aabaaaeL, 0xf3d727a15f32d1a0L, 0x351c791acb377783L, 0xf2d3c4c052adab53L, 0xe0344918f58d44b7L, 0x87699ce7a759f36cL, 0xbe51782a03221340L, 0xa181e748cca99627L, 0x57b85166c65679c1L, 0x5581cc7d99955ed2L, 0x3341d36a3648aa15L, 0x7e768e53da01a5c6L
        ]);
    }
}