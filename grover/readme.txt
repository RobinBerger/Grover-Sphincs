This project implements different grover oracles.
It is also executable to allow getting resource estimates for these oracles as well as the hash functions and permutations used.

It can be run with "dotnet run [options]"
Required options are:
    --input-length [inputlength]
        This specifies the input length of a hash function in bytes.
        example:
            --input-length 32
    --prefix-length [prefixlength]
        This specifies the length of a prefix of the input  of the hash function.
        The prefix length adds to the input length, but adds classical inputs to the hash function therefore not increasing the amount of qubits needed directly.
        example:
            --prefix-length 32
    --output-length [outputlength]
        This specifies the output length of a hash function in bytes.
        example:
            --output-length 32
    --evaluation-type [what to evaluate]
        This specifies what will be evaluated.
        Valid values are:
            hash
                Evaluates the hash function.
            permutation
                Evaluates a permutation.
            hashOracle
                Evaluates a grover oracle for a hash function.
            spongeHash
                Evaluates a sponge-based hash function using optimizations available for sponge-based hash functions.
        example:
            --evaluation-type hash
            --evaluation-type permutation
    --function-type [hash function]
        This specifies which hash function is used.
        Valid values are:
            shake
                The Shake256 hash function and the Keccak permutation.
            haraka
                The Sponge-based Haraka hash function and the haraka512 permutation with all round constants being zero.
            haraka256
                The Haraka256 hash function and the haraka256 permutation with all round constants being zero.
            haraka512
                The Haraka512 hash function and the haraka512 permutation with all round constants being zero.
            harakaDefault
                Same as haraka but using the default haraka round constants.
            haraka256Default
                Same as haraka256 but using the default haraka round constants.
            haraka512Default
                Same as haraka512 but using the default haraka round constants.
        example:
            --function-type shake
            --function-type harakaDefault

Example:
    dotnet run --input-length 32 --prefix-length 16 --output-length 32 --evaluation-type hash --function-type haraka256
    dotnet run --input-length 42 --prefix-length 50 --output-length 17 --evaluation-type hashOracle --function-type shake
    dotnet run --input-length 64 --prefix-length 0 --output-length 64 --evaluation-type permutation --function-type haraka512Default