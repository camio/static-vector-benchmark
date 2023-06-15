#!/bin/bash -e
#
# Utility script to turn the bechmark output (from multirun.sh) into a readily
# readable form.

usage() {
  cat <<EOF
Usage: collate.sh --prefix string

Utility script to turn the bechmark output (from multirun.sh) into a readily
readable form.  --prefix should be set to a string that was used with
multirun.sh. The readable form is sent to stdout

This command is expected to be run at the top level of the repository where it
can find multirun.sh output in the runs/ folder. It also requires jq to be in
the current path.
EOF
}

if ! command -v jq >/dev/null; then
  echo "ERROR: jq executable could not be found. Is it installed" >&2
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

jq --slurp '[.[].benchmarks[]]
  | group_by(.name)
  | [ .[] | [.[].items_per_second]             as $frequencySamples
          | ($frequencySamples | add / length) as $frequencyMean
          | ($frequencySamples | map(1/.))     as $periodSamples
          | ($periodSamples | add / length)    as $periodMean
          | { test_name:   .[0].name | sub("BM_(?<test>.*)/.*";.test)
            , $frequencySamples
            , $frequencyMean
            , frequencyStddev:  ( $frequencySamples
                                | (map(. - $frequencyMean | . * .) | add) / (length - 1)
                                | sqrt
                                )
            , $periodSamples
            , $periodMean
            , periodStddev:  ( $periodSamples
                             | (map(. - $periodMean | . * .) | add) / (length - 1)
                             | sqrt
                             )
            }
    ]
  | group_by(.test_name)
  | [ .[] | { test_name: .[0].test_name,
              results: [.[] | del (.test_name)]
            }
    ]
  ' run/${PREFIX}.run.*.json
