#!/bin/bash -e
#
# Utility script to generate a comparison graph from benchmark output.

usage() {
  cat <<EOF
Usage: build_graph.sh --prefix string

Utility script to generate a comparison graph from benchmark output.  --prefix
should be set to a string that was used with multirun.sh. The generated graph
shows up in a window.

This command is expected to be run at the top level of the repository where it
can find multirun.sh output in the runs/ folder. It also requires jq and
gnuplot to be in the current path.
EOF
}

if ! command -v jq >/dev/null; then
  echo "ERROR: jq executable could not be found. Is it installed?" >&2
  exit 1
fi

if ! command -v gnuplot >/dev/null; then
  echo "ERROR: gnuplot executable could not be found. Is it installed?" >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit ;;
    --prefix)
      PREFIX="$2"
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

scripts/collate.sh --prefix ${PREFIX} | \
  jq --raw-output '
  # Put test entries in the desired order
    [ .[]
    | { key: (.test_name | if   contains("invisible") then 0
                                                      else 1
                           end
              )
      , object: .
      }
    ]
  | sort_by(.key)
  | map(.object)

  # Create CSV
  | del(.[] | select(.test_name | startswith("vector" ) )) # Exclude unrelevant std::vector comparisons
  | .[]
  | .test_name as $test_name
  | (.test_name |
      if   startswith("static_vector_push_back_check_invisible_size") then "T1 push\\\\_back"
      elif startswith("static_vector_push_back_unsafe_invisible_size") then "T1 unchecked\\\\_push\\\\_back"
      elif startswith("static_vector_try_push_back_invisible_size") then "T1 try\\\\_push\\\\_back"
      elif startswith("vector_invisible_size") then "T1 vector push\\\\_back"
      elif startswith("static_vector_push_back_check") then "T2 push\\\\_back"
      elif startswith("static_vector_push_back_unsafe") then "T2 unchecked\\\\_push\\\\_back"
      elif startswith("static_vector_try_push_back") then "T2 try\\\\_push\\\\_back"
      elif startswith("vector") then "T2 vector push\\\\_back"
      else . end
    ) as $test_name
  | .results[]
  | [ $test_name,
      .periodMean,
      .periodStddev
    ]
  | @csv
  ' > /tmp/entries.csv

gnuplot -p <<EOF
set datafile separator ','
set boxwidth 0.8
set style fill solid 1.0 border -1

set title "${PREFIX}" font ",14" tc rgb "#606060"
set ylabel "Nanoseconds per iteration"
# set yrange [0:35e-9]
set xlabel "Test case"
set xtics nomirror rotate by -45
set format y '%.1s %c'
set tic scale 0
set grid ytics
unset border

# Lighter grid lines
set grid ytics lc rgb "#C0C0C0"

set style histogram errorbars gap 2 lw 1
set style data histogram
set bars 2.0
plot "/tmp/entries.csv" using 2:3:xticlabels(1) notitle lt rgb "#FFB6C1"
EOF
