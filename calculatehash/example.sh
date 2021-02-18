#!/bin/bash

#run with ./example.sh or with ./example.sh -s ResourcesEstimator

dotnet run --input 0 255 13 47 --input-length 4 --output-length 20 --type shake $@
