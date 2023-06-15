#!/bin/bash -e
#
# Utility script to run the benchmark multiple times and collect output.

usage() {
  cat <<EOF
Usage: multirun.sh --prefix string [--runs number]

Utility script to run the benchmark multiple times and collect output.
--prefix should be set to a string that uniquely describes the hardware,
OS, and compiler configuration you'd like to run the benchmark on.

This command is expected to be run at the top level of the repository where it
can find an already built benchmark executable.

The benchmark will run the given number of times (defaulting to 10) and create
JSON files in the run/ directory with the name "<prefix>.run.<i>.json" where i
is the ith run.
EOF
}

if ! command -v ./benchmark >/dev/null; then
  echo "ERROR: benchmark executable could not be found in the current directory" >&2
  echo "Did you build with make?"
  exit 1
fi

RUNS=10

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit ;;
    --prefix)
      PREFIX="$2"
      shift ;;
    --runs)
      RUNS="$2"
      shift ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      exit 1;;
  esac
  shift
done

if [[ -z "${PREFIX}" ]]; then
  echo "--prefix must be specified. See --help for more info" >&2
  exit 1
fi

mkdir -p run

for i in $(seq 1 $RUNS)
do
  echo "Executing run $i/$RUNS for $PREFIX"
  ./benchmark \
    --benchmark_min_time=2s \
    --benchmark_out=run/$PREFIX.run.$i.json \
    --benchmark_out_format=json
done
