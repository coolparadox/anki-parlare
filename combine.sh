#!/usr/bin/env bash
set -euo pipefail

WHEREAMI=$(dirname 0)
VERBS_FILE="$WHEREAMI/verbs.lst"
TENSES_FILE="$WHEREAMI/tenses.lst"
BASE_CACHE_DIR="$WHEREAMI/cache"
export CONIUGARE_CACHE_DIR="$BASE_CACHE_DIR/coniugare"
export CONJUGAR_CACHE_DIR="$BASE_CACHE_DIR/conjugar"
mkdir -p "$CONIUGARE_CACHE_DIR" "$CONJUGAR_CACHE_DIR"

declare -A TABLE_IT
declare -A TABLE_PT

coniugare() {
    $WHEREAMI/coniugare.sh $VERB_IT $MOOD_IT $TENSE_IT
}

update_table_it() {
    while read PRONOUN CONJUGATION ; do
        TABLE_IT[$PRONOUN]="$CONJUGATION"
    done <<<$(coniugare)
}

conjugar() {
    $WHEREAMI/conjugar.sh $VERB_PT $MOOD_PT $TENSE_PT
}

update_table_pt() {
    while read PRONOUN CONJUGATION ; do
        TABLE_PT[$PRONOUN]="$CONJUGATION"
    done <<<$(conjugar)
}

update_tables() {
    update_table_it
    update_table_pt
}

while IFS=',' read VERB_IT VERB_PT ; do
    echo "$VERB_IT,,$VERB_PT,"
    while IFS=',' read MOOD_IT TENSE_IT MOOD_PT TENSE_PT ; do
        update_tables
        echo "io ${TABLE_IT['io']},,eu ${TABLE_PT['eu']},"
        echo "tu ${TABLE_IT['tu']},,você ${TABLE_PT['ele']},"
        echo "lui ${TABLE_IT['lui']},,ele ${TABLE_PT['ele']},"
        echo "lei ${TABLE_IT['lui']},,ela ${TABLE_PT['ele']},"
        echo "noi ${TABLE_IT['noi']},,nós ${TABLE_PT['nós']},"
        echo "loro ${TABLE_IT['loro']},maschile,eles ${TABLE_PT['eles']},"
        echo "loro ${TABLE_IT['loro']},femminile,elas ${TABLE_PT['eles']},"
    done <"$TENSES_FILE"
done <"$VERBS_FILE"

