# static-vector-benchmark

This repository contains the source code for a micro benchmark of static vector
operations.

## Building

Use the enclosed `Makefile`. A system installation of [Google
benchmark](https://github.com/google/benchmark) is assumed to be available.

## Running

Run the `benchmark` executable. The output should look something like this:

```shell
2022-12-13T21:46:14-05:00
Running ./benchmark
Run on (24 X 2660.09 MHz CPU s)
CPU Caches:
  L1 Data 32 KiB (x12)
  L1 Instruction 32 KiB (x12)
  L2 Unified 256 KiB (x12)
  L3 Unified 12288 KiB (x2)
Load Average: 1.16, 1.17, 1.12
----------------------------------------------------------------------------
Benchmark                  Time             CPU   Iterations UserCounters...
----------------------------------------------------------------------------
BM_vector/1000000     651827 ns       651795 ns          996 items_per_second=1.53423G/s
```

## The benchmarks

TBD

## MacOS Notes

Install dependencies

```bsh
brew install google-benchmark
brew install pkg-config
```

To build using the stock clang compiler, build like this:

```bsh
make CXX="clang++ --std=c++20"
```
