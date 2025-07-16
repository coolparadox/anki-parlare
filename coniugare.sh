#!/usr/bin/env bash
set -euo pipefail

ME=$(basename "$0")

usage() {
	echo "usage sample: $ME parlare indicativo presente" >&2
	exit 1
}

fail() {
    echo "$ME: error: $*" >&2
    exit 1
}

test $# -eq 3 || usage
VERB=$1
MOOD=$2
TENSE=$3

test -v CONIUGARE_CACHE_DIR || fail "CONIUGARE_CACHE_DIR not set"

get_html() {
	local HTML_PATH="$CONIUGARE_CACHE_DIR/${VERB}.html"
	test -s "$HTML_PATH" || {
        wget -q -O "$HTML_PATH" "https://italianverbs.info/$VERB"
        test -s "$HTML_PATH"
    }
    cat "$HTML_PATH"
}

parse_html() {
    get_html | \
    sed -r \
        -e "s|.*>${MOOD}<||i" \
         -e 's/<h2 .*//' \
        -e "s|.*>${TENSE}<||i" \
        -e 's|</section>.*||' \
        -e 's|</li><li>|\n|g' | \
    sed -r \
        -e 's|.*<span[^>]*>||' \
        -e 's|<[^>]*>||g' \
        -e '$a\'
}

declare -A TABLE=( ['io']='' ['tu']='' ['lui']='' ['noi']='' ['voi']='' ['loro']='' )
while read PRONOUN CONJUGATION ; do
    #echo $PRONOUN $CONJUGATION
    case $PRONOUN in
        'io'|'tu'|'lui'|'noi'|'voi'|'loro') TABLE[$PRONOUN]=$CONJUGATION ;;
    esac
done <<<$(parse_html)

for PRONOUN in 'io' 'tu' 'lui' 'noi' 'voi' 'loro' ; do
    CONJUGATION=${TABLE[$PRONOUN]}
    test -n "$CONJUGATION" || fail "missing conjugation: '$PRONOUN'"
    echo $PRONOUN $CONJUGATION
done

