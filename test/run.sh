#!/bin/bash
set -eu -o pipefail

cd "$(dirname "$0")"
../pptx2txt sample1.pptx sample2.pptx sample3.pptx
diff sample1.txt expected/sample1.txt
diff sample2.txt expected/sample2.txt
diff sample2.txt expected/sample2.txt
