#!/usr/bin/env bash
set -euo pipefail

ME=$(basename "$0")

usage() {
	echo "usage sample: $ME falar indicativo presente" >&2
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

test -v CONJUGAR_CACHE_DIR || fail "CONJUGAR_CACHE_DIR not set"

get_html() {
	local HTML_PATH="$CONJUGAR_CACHE_DIR/${VERB}.html"
	test -s "$HTML_PATH" || {
        wget -q -O "$HTML_PATH" "https://www.conjugacao.com.br/verbo-${VERB}/"
        test -s "$HTML_PATH"
    }
    cat "$HTML_PATH"
}

parse_html() {
    get_html | \
    sed '1,/<div id="conjugacao"/d' | \
    sed -e "1,/<h3 class=\"verb-tense verb-tense--title\">${MOOD}<\/h3>/Id" -e '/<h3 class="verb-tense verb-tense--title">/,$d' | \
    sed "1,/<h4 class=\"verb-tense verb-tense--subtitle\">${TENSE}<\/h4>/Id" | \
    sed -n '/<span>/{s/^ *//g;s/ *<\/p> *//;s/<br>$//;p;q}' | \
    sed 's/<br>/\n/g' | \
    sed -r -e 's|</span>|,|g' -e 's|<span[^>]*>|,|g' -e 's|^,*||' -e 's|,*$||g' -e 's|[ ,]+| |g'
}

parse_html
exit 1

declare -A TABLE=( ['eu']='' ['tu']='' ['ele']='' ['nós']='' ['vós']='' ['eles']='' )
while read PRONOUN CONJUGATION ; do
    #echo $PRONOUN $CONJUGATION
    case $PRONOUN in
        'eu'|'tu'|'ele'|'nós'|'vós'|'eles') TABLE[$PRONOUN]=$CONJUGATION ;;
    esac
done <<<$(parse_html)

for PRONOUN in 'eu' 'tu' 'ele' 'nós' 'vós' 'eles' ; do
    CONJUGATION=${TABLE[$PRONOUN]}
    test -n "$CONJUGATION" || fail "missing conjugation: '$PRONOUN'"
    echo $PRONOUN $CONJUGATION
done

