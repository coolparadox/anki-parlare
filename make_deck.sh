#!/usr/bin/env bash
set -euo pipefail

WHEREAMI=$(dirname "$0")

DECK_FILE=$WHEREAMI/italian.txt

cat >$DECK_FILE <<__eod__
#separator:tab
#html:false
#notetype column:1
#deck column:2
#tags column:7
__eod__

$WHEREAMI/combine.sh | \
while IFS=',' read IT IT_CTX PT PT_CTX ; do
    echo -ne 'words'
    echo -ne "\\titalian"
    echo -ne "\\t$IT"
    echo -ne "\\t$IT_CTX"
    echo -ne "\\t$PT"
    echo -ne "\\t$PT_CTX"
    echo -ne "\\tverbo"
    echo -ne "\\n"
done >>$DECK_FILE
echo "updated: $DECK_FILE"

