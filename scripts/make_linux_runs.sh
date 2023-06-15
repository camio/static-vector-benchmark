#!/bin/bash -e
#
# Utility script to create Linux runs of the benchmark

# sudo cpupower frequency-set -g performance

make clean
make CXX=g++
./scripts/multirun.sh --prefix Linux+GCC-13.1.1+Intel-Core-i7-118580H


make clean
make CXX=clang++
./scripts/multirun.sh --prefix Linux+Clang-17.0.0+Intel-Core-i7-118580H

# sudo cpupower frequency-set -g schedutil
