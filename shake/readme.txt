This project contains the implementation of the shake256 hash function.
It can be executed to retrieve the resource estimate for the different steps in the keccak permutation.
The resource estimate for the iota step is summed over the 24 iterations of the permutation. The resource estimate for all other steps are reported from a single iteration.

To compute a hash value, the "shake256hash" operation in the "keccak.shake256" namespace needs to be called with the input and output qubits as parameters.

It can be run with "dotnet run [options]"
Required options are:
    --step [name of the step of the keccak permutation]
        Valid values are:
            theta
            chi
            inversechi
            iota
        example:
            --step theta
            --step inversechi

Example:
    dotnet run --step theta