This project can calculate hash values for the haraka-sponge and shake256 hash functions.

The program will first print the input it uses to calculate a hash value, followed with the hash function name and the hash value. All values are in base 16.

It can be run with "dotnet run [options]"
Required options are:
    --input [space separated list of bytes in base 10]
        Contains the input to calculate the hash for.
        The input must not be empty, even when calculating the hash value with an empty input.
        example:
            --input 17 255 0 13 42
            --input 0
    --input-length [input length]
        Contains the length of the input.
        This must be smaller or equals to the amount of bytes given to --input
        example:
            --input-length 5
            --input-length 0
    --output-length [output length]
        Contains the amount of bytes to output.
        This must be greater than zero.
        example:
            --output-length 120
            --output-length 1
    --type [hash function]
        Contains the hash function to calculate.
        Valid values for hash functions are:
            shake
            haraka
            haraka256
            haraka512
        example:
            --type shake
            --type haraka

Optional options are:
    --simulator [simulator]
        Specifies the quantum simulator to use.
        Valid simulators are:
            ToffoliSimulator
            ResourcesEstimator
        example:
            --simulator ToffoliSimulator
            --simulator ResourcesEstimator
        The default simulator is ToffoliSimulator

Example:
    dotnet run --input 0 255 13 47 --input-length 4 --output-length 20 --type shake
    dotnet run --input 0 --input-length 0 --output-length 1 --type haraka --simulator ResourcesEstimator
    dotnet run --input 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 --input-length 16 --output-length 256 --type haraka256