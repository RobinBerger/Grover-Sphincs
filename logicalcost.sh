#!/bin/bash

# ./logicalcost.sh > out.txt

# This script creates a resource estimate for the grover oracles for each of the proposed attacks.
# The output of this script can be postprocessed to a .csv or .tex file.

cd grover

#################################################################################
# Make sure the program is built, so it can potentially be run in parallel
#################################################################################
dotnet build >/dev/null || (echo Failed build. aborting. && exit)

#################################################################################
# WOTS attacks
#################################################################################
for hashfunction in haraka512 shake; do
    for parameter in 16 24 32; do
        for recursion in {1..16}; do
            let parameterInBit=parameter*8
            echo Logical cost for $parameterInBit bit $hashfunction with recursion depth $recursion
            dotnet run --input-length 64 --prefix-length $recursion --output-length $parameter --evaluation-type recursive --function-type $hashfunction
            echo
            echo
        done
    done
done

#################################################################################
# XMSS attacks
#################################################################################
echo Logical cost for 128 bit shake l/r iterations
dotnet run --input-length 16 --prefix-length 64 --output-length 16 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 192 bit shake l/r iterations
dotnet run --input-length 24 --prefix-length 80 --output-length 24 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 256 bit shake l/r iterations
dotnet run --input-length 32 --prefix-length 96 --output-length 32 --evaluation-type spongeHash --function-type shake
echo
echo

#################################################################################
echo Logical cost for 128 bit haraka l/r iterations
dotnet run --input-length 16 --prefix-length 16 --output-length 16 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 192 bit haraka l/r iterations
dotnet run --input-length 24 --prefix-length 24 --output-length 24 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 256 bit haraka l iterations
dotnet run --input-length 32 --prefix-length 32 --output-length 32 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 256 bit haraka r iterations
dotnet run --input-length 32 --prefix-length 0 --output-length 32 --evaluation-type spongeHash --function-type haraka
echo
echo

#################################################################################
# Message digest attacks
#################################################################################
echo Logical cost for 128 bit shake small
dotnet run --input-length 27 --prefix-length 48 --output-length 27 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 128 bit shake fast
dotnet run --input-length 43 --prefix-length 48 --output-length 43 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 192 bit shake small
dotnet run --input-length 36 --prefix-length 72 --output-length 36 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 192 bit shake fast
dotnet run --input-length 42 --prefix-length 72 --output-length 42 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 256 bit shake small
dotnet run --input-length 47 --prefix-length 96 --output-length 47 --evaluation-type spongeHash --function-type shake
echo
echo

echo Logical cost for 256 bit shake fast
dotnet run --input-length 47 --prefix-length 96 --output-length 47 --evaluation-type spongeHash --function-type shake
echo
echo

#################################################################################
echo Logical cost for 128 bit haraka small
dotnet run --input-length 27 --prefix-length 0 --output-length 27 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 128 bit haraka fast
dotnet run --input-length 43 --prefix-length 0 --output-length 43 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 192 bit haraka small
dotnet run --input-length 36 --prefix-length 16 --output-length 36 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 192 bit haraka fast
dotnet run --input-length 42 --prefix-length 16 --output-length 42 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 256 bit haraka small
dotnet run --input-length 47 --prefix-length 0 --output-length 47 --evaluation-type spongeHash --function-type haraka
echo
echo

echo Logical cost for 256 bit haraka fast
dotnet run --input-length 47 --prefix-length 0 --output-length 47 --evaluation-type spongeHash --function-type haraka
echo
echo

#################################################################################
# generic preimage attack
#################################################################################
for hash in shake haraka; do
	for parameter in 16 24 32; do
		let bitsec=8*$parameter
		echo Logical cost for $bitsec bit $hash preimage
		dotnet run --input-length $parameter --prefix-length 0 --output-length $parameter --evaluation-type spongeHash --function-type $hash
		echo
		echo
	done
done