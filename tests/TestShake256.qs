namespace keccak.shake256.test {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open keccak;
    open keccak.test;
    open keccak.shake256;
    open common;
    open common.test;
    open common.maybeqbit;
    
    /// # Summary
    /// performs a known input known outptut test of shake256 hash function given the inputs and expected outputs.
    operation performShake256Test(input : BigInt[], inputLength : Int, output : BigInt[], outputLength : Int) : Unit {

        using ((outputBits, inputBits) = (Qubit[outputLength * 8], Qubit[inputLength * 8])) {
            initialize64(inputBits, input);

            shake256Hash(qbitsToMaybeQbit(inputBits), outputBits);

            assert64Multiple(outputBits, output, "");

            ResetAll(outputBits);
            ResetAll(inputBits);
        }
    }

    @Test("ToffoliSimulator")
    operation testShake256NoInputSmall() : Unit {
        performShake256Test(new BigInt[0], 0, [ 0x0000000b2bddb946L ], 5);
    }

    @Test("ToffoliSimulator")
    operation testShake256NoInputFullBlock() : Unit {
        performShake256Test(new BigInt[0], 0, [
            0x138da80b2bddb946L, 0x24eb3e74eb3f3b23L, 0x821bb862ea52cd3fL, 0x2f76d56e64270cb5L, 0x00f2c0d8ddc45dd7L, 0xf692b5679d0105cbL, 0x86b49a47491c82fcL, 0xbec4b7b3ac2e2940L, 0x5739b16f61961e14L, 0xe35ab4d0edc72c69L, 0x7b93928e3c2207dcL, 0x532886ab0ebc84efL, 0xb78ff54655c79e34L, 0x10502c46385c77c2L, 0xe51151c185c146d8L, 0x86cf16cd6b2a5295L, 0xdd1f3b9e1022d1f3L
        ], 136);
    }

    @Test("ToffoliSimulator")
    operation testShake256NoInputMultipleBlocks() : Unit {
        performShake256Test(new BigInt[0], 0, [
            0x138da80b2bddb946L, 0x24eb3e74eb3f3b23L, 0x821bb862ea52cd3fL, 0x2f76d56e64270cb5L, 0x00f2c0d8ddc45dd7L, 0xf692b5679d0105cbL, 0x86b49a47491c82fcL, 0xbec4b7b3ac2e2940L, 0x5739b16f61961e14L, 0xe35ab4d0edc72c69L, 0x7b93928e3c2207dcL, 0x532886ab0ebc84efL, 0xb78ff54655c79e34L, 0x10502c46385c77c2L, 0xe51151c185c146d8L, 0x86cf16cd6b2a5295L, 0xdd1f3b9e1022d1f3L, 0x622d8a46ec6a3b94L, 0x000057a9c6067c1aL
        ], 150);
    }

    @Test("ToffoliSimulator")
    operation testShake256SmallInputSmall() : Unit {
        performShake256Test([
            0x63980d4f0ddb15b9L, 0x3df124f24f639138L, 0x97ea07bb38d06d56L, 0x5755d9cc83b4dd65L, 0x0f97f1c3b186a71fL
        ], 40, [
            0x000000fd56731731L
        ], 5);
    }

    @Test("ToffoliSimulator")
    operation testShake256SmallInputMultipleBlocks() : Unit {
        performShake256Test( [
            0x63980d4f0ddb15b9L, 0x3df124f24f639138L, 0x97ea07bb38d06d56L, 0x5755d9cc83b4dd65L, 0x0f97f1c3b186a71fL
        ], 40, [
            0x784798fd56731731L, 0xcd6e2541a3c131dbL, 0x7a66df115c7e3dc8L, 0xda25f00413d845efL, 0x879daaab191e7fa7L, 0x494e7b6c54e22201L, 0xe8b82886701531a8L, 0xa37c34a27ef8c0abL, 0x5f641e35f8cd039eL, 0xaea04181188e9763L, 0xa89aaa6ad1a35badL, 0xcf79240fdb915a6cL, 0x9a852f436b1280b4L, 0xa807078b1741ed3fL, 0xe24a520436a31064L, 0x8e7bccb3a9055084L, 0x0466bff08d187a36L, 0x1e44a39a7bbac67cL, 0x00001abf7a2cf3aaL
        ], 150);
    }

    @Test("ToffoliSimulator")
    operation testShake256NonalignedInputSmall() : Unit {
        performShake256Test([
            0x63980d4f0ddb15b9L, 0x3df124f24f639138L, 0x97ea07bb38d06d56L, 0x5755d9cc83b4dd65L, 0x0097f1c3b186a71fL
        ], 39, [
            0x000000343f109e0bL
        ], 5);
    }

    @Test("ToffoliSimulator")
    operation testShake256NonalignedInputLarge() : Unit {
        performShake256Test([
            0x63980d4f0ddb15b9L, 0x3df124f24f639138L, 0x97ea07bb38d06d56L, 0x5755d9cc83b4dd65L, 0x0000f1c3b186a71fL
        ], 38, [
            0x63868cdbaa08f8c3L, 0xa46989ee43734f58L, 0xf8ec003a32fb2171L, 0xf8fafe6355e07489L, 0x727dd352489e6625L, 0x718d175872439a1bL, 0xda0fc2bdc81d1dd8L, 0x317154cbe4b3e6bbL, 0x2973e0fc12c9017dL, 0x537ea549c1cdfb53L, 0x873a7bc0325f18dbL, 0x7f7ff2305f573418L, 0x8aabd9d9570416c9L, 0x96bb7d334e5e5848L, 0x02cb0d8cbf890444L, 0x3c38bb4550975c37L, 0x8100f27f88b1d9e0L, 0x8e58fca1bd3a4227L, 0x0000d037dbea6c78L
        ], 150);
    }

    @Test("ToffoliSimulator")
    operation testShake256LargeInputSmall() : Unit {
        performShake256Test( [
            0x8252d51dd141ece2L, 0x31708a28003fea50L, 0x1c5cc833b39902f5L, 0x07753201a618bbdbL, 0x6021c91996aa00b8L, 0x92869b696e0d078eL, 0xa43864d8d271fe37L, 0x578e7f13492da27eL, 0x1467f7008e98b9b9L, 0x57847edbb39feaf8L, 0x510004b964e65748L, 0x0b5148fb91e47da1L, 0x61e1b51723d7146fL, 0xa0e43a7bfdf198ddL, 0x1837fab18bcff445L, 0xe8dc34e54205d274L, 0xd4904273d823a7aaL, 0x2cfb9b3b263e0373L, 0x6fcebbb4324735d0L, 0x5eaaaa2941438e50L
        ], 160, [
            0x000000811e7eda82L
        ], 5);
    }

    @Test("ToffoliSimulator")
    operation testShake256LargeInputLarge() : Unit {
        performShake256Test( [
            0x8252d51dd141ece2L, 0x31708a28003fea50L, 0x1c5cc833b39902f5L, 0x07753201a618bbdbL, 0x6021c91996aa00b8L, 0x92869b696e0d078eL, 0xa43864d8d271fe37L, 0x578e7f13492da27eL, 0x1467f7008e98b9b9L, 0x57847edbb39feaf8L, 0x510004b964e65748L, 0x0b5148fb91e47da1L, 0x61e1b51723d7146fL, 0xa0e43a7bfdf198ddL, 0x1837fab18bcff445L, 0xe8dc34e54205d274L, 0xd4904273d823a7aaL, 0x2cfb9b3b263e0373L, 0x6fcebbb4324735d0L, 0x5eaaaa2941438e50L
        ], 160, [
            0x55f226811e7eda82L, 0x0d7e64a0270ebed5L, 0x44e269503968edecL, 0x2d3324685306b838L, 0x98fab39338df866aL, 0x8504585df6c5937eL, 0xd4a691249c05fc46L, 0x2945b25bff7e01dfL, 0x2ca81ead9d5cbf47L, 0xa84bf37f490f19dcL, 0x36366e48dc34496fL, 0xd6791d60af290d4bL, 0x91a0ae06670b74deL, 0x0aed1c877f6b2373L, 0x93195d0d84606b96L, 0x378ef6f874fad100L, 0xe763ceae465cb65bL, 0xcd7db0a6defc69f9L, 0x0000d90fe1ee1e41L
        ], 150);
    }
}