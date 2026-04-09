#!/bin/bash

ORPHAN_FILE=".orphan_branches"
> "$ORPHAN_FILE"

while IFS= read -r LINE; do
    BRANCH=$(echo "$LINE" | awk '{print $1}')
    UPSTREAM=$(echo "$LINE" | grep -oP '\[origin/\K[^\]:]+')

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
    echo "Færdig."
else
    echo "Ingen branches slettet."
fi
