#!/bin/bash -e
#
# Utility script to create Linux runs of the benchmark

# sudo cpupower frequency-set -g performance

make clean
make CXX="clang++ -std=c++20"
./scripts/multirun.sh --prefix Mac+AppleClang-14.0.0+M2Max

# sudo cpupower frequency-set -g schedutil
