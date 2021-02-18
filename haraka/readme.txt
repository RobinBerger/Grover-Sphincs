This project contains the implementation of the Haraka hash function.
It is not executable.

Some files are taken with or without modifications from the Microsoft grover-blocks repository at https://github.com/microsoft/grover-blocks
See the header of the individual files for the source.

To compute a hash value, the "haraka256" or "haraka512" operation in the "haraka" namespace need to be called. To compute the haraka-based sponge hash, the operation "harakaHash" in the namespace "haraka.sponge" needs to be called. All methods require the input and output qubits as parameters as well as the used round keys.
