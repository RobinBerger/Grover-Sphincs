This project contains the tests for the haraka and shake hash functions as tests for the sponge constructions used for the hash functions.

It can be run with "dotnet test". Running these tests takes several minutes.
You can also selectively run tests by running "dotnet test --filter [name of test method]"

All tests with known input and output are generated using a reference implementation implemented in C.