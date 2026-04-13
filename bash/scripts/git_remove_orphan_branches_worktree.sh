#!/bin/bash

ORPHAN_FILE=".orphan_branches"
> "$ORPHAN_FILE"

while IFS= read -r LINE; do
    BRANCH=$(echo "$LINE" | awk '{print $1}')

    # Fang branches hvor remote er slettet (gone)
    if echo "$LINE" | grep -q '\[.*: gone\]'; then
        echo "$BRANCH" >> "$ORPHAN_FILE"
        continue
    fi

    UPSTREAM=$(echo "$LINE" | grep -oP '\[origin/\K[^\]:]+')

    # Fang branches uden remote eller hvor remote ikke matcher
    if [ -z "$UPSTREAM" ] || [ "$UPSTREAM" != "$BRANCH" ]; then
        echo "$BRANCH" >> "$ORPHAN_FILE"
    fi
done < <(git branch -vv | grep -v "^[+*]" | sed 's/^[[:space:]]*//')

if [ ! -s "$ORPHAN_FILE" ]; then
    echo "Ingen orphan branches fundet."
    exit 0
fi

echo ""
echo "Følgende branches har ingen matchende remote:"
echo "------------------------------------"
cat "$ORPHAN_FILE"
echo "------------------------------------"
echo ""
read -r -p "Skriv YES for at slette alle lokalt: " CONFIRM

if [ "$CONFIRM" = "YES" ]; then
    while IFS= read -r BRANCH; do
        git branch -d "$BRANCH"
        echo "Slettet: $BRANCH"
    done < "$ORPHAN_FILE"
    rm "$ORPHAN_FILE"
    echo "Færdig."
else
    echo "Ingen branches slettet."
    rm "$ORPHAN_FILE"
fi
