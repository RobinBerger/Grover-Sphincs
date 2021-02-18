This project contains implementations of the Shake256, Haraka256, Haraka512 hash functions. It also contains Grover Oracles, that can be used for attacks on the SPHINCS+ signature scheme.

The common directory contains our implementation of the sponge construction.
The haraka directory contains our implementation of the Haraka hash functions as well as the Haraka-based sponge hash function used in the SPHINCS+ signature scheme.
The shake directory contains our implementation of the Keccak permutation and the SHAKE-256 hash function.
The tests directory contains automated tests for the implementations in the directories above.
The calculatehash directory contains a program, that uses the hash function implementations to calculate hash values.
The grover directory contains the implementation of Grover oracles using the hash function implementations as well as a program to estimate the resource requirements for these oracles.

Instructions on how to use the implementations is contained in each of the relevant directories.
The bash script ./logicalcost.sh estimates the resource requirements for the Grover oracles for all attacks proposed in the thesis for all proposed parameter sets.

The implementations were developed with version 0.13.20102604 of the Microsoft Quantum Development Kit and version 3.1.405 of the .NET Core framework on Ubuntu 18.04.
For install instructions see https://docs.microsoft.com/en-us/quantum/quickstarts/install-command-line and https://docs.microsoft.com/en-us/dotnet/core/install/linux.
Using our Q# implementations mentioned above requires these versions of the QDK and the .NET Core framework to be installed.
