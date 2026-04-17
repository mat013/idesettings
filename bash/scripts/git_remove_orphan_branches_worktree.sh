#!/bin/bash
ORPHAN_FILE=".orphan_branches"
IGNORE_BRANCHES=("develop-sit" "develop-fkt" "develop-udv")

git fetch --prune
CURRENT_REPO=$(git rev-parse --show-toplevel)

is_ignored() {
    local branch="$1"
    for ignored in "${IGNORE_BRANCHES[@]}"; do
        if [ "$branch" = "$ignored" ]; then
            return 0
        fi
    done
    return 1
}

force_delete_prompt() {
    local branch="$1"
    echo "Advarsel: '$branch' er ikke fully merged."
    read -r -p "Tving sletning med -D? (y/n): " FORCE
    if [ "$FORCE" = "y" ]; then
        git branch -D "$branch"
        echo "Slettet (tvunget): $branch"
    else
        echo "Sprunget over: $branch"
    fi
}

delete_branch() {
    local entry="$1"
    local clean_branch
    clean_branch=$(echo "$entry" | sed 's/ (CHECKET UD.*)//')
    if echo "$entry" | grep -q "CHECKET UD"; then
        echo "Springer over (checket ud): $clean_branch - skift worktree og kør scriptet igen"
    else
        if git branch -d "$clean_branch" 2>/dev/null; then
            echo "Slettet: $clean_branch"
        else
            force_delete_prompt "$clean_branch"
        fi
    fi
}

add_to_orphan_file() {
    local branch="$1"
    local checked_out="$2"
    local worktree_other="$3"
    local worktree="$4"

    if $checked_out; then
        local display_path="${worktree:-$CURRENT_REPO}"
        echo "$branch (CHECKET UD i: $display_path - slet manuelt)" >> "$ORPHAN_FILE"
    elif $worktree_other; then
        echo "$branch (CHECKET UD i worktree: ${worktree:-ukendt} - slet manuelt)" >> "$ORPHAN_FILE"
    else
        echo "$branch" >> "$ORPHAN_FILE"
    fi
}

> "$ORPHAN_FILE"
while IFS= read -r LINE; do
    CHECKED_OUT=false
    WORKTREE_OTHER=false
    if echo "$LINE" | grep -q '^\*'; then
        CHECKED_OUT=true
    elif echo "$LINE" | grep -q '^+'; then
        WORKTREE_OTHER=true
    fi

    BRANCH=$(echo "$LINE" | sed 's/^[*+[:space:]]*//' | awk '{print $1}')
    WORKTREE=$(echo "$LINE" | grep -oP '\(\K[^)]+' | head -1)

    if echo "$LINE" | grep -q '\[.*: gone\]'; then
        if ! is_ignored "$BRANCH"; then
            add_to_orphan_file "$BRANCH" "$CHECKED_OUT" "$WORKTREE_OTHER" "$WORKTREE"
        fi
        continue
    fi
    UPSTREAM=$(echo "$LINE" | grep -oP '\[origin/\K[^\]:]+')
    if [ -z "$UPSTREAM" ] || [ "$UPSTREAM" != "$BRANCH" ]; then
        if ! is_ignored "$BRANCH"; then
            add_to_orphan_file "$BRANCH" "$CHECKED_OUT" "$WORKTREE_OTHER" "$WORKTREE"
        fi
    fi
done < <(git branch -vv | sed 's/^[[:space:]]*//')

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
read -r -p "Skriv ALL for at slette alle, SOME for at vælge, eller andet for at annullere: " CONFIRM

if [ "$CONFIRM" = "ALL" ]; then
    while IFS= read -r BRANCH <&3; do
        delete_branch "$BRANCH"
    done 3< "$ORPHAN_FILE"
    echo "Færdig."
elif [ "$CONFIRM" = "SOME" ]; then
    while IFS= read -r BRANCH <&3; do
        CLEAN_BRANCH=$(echo "$BRANCH" | sed 's/ (CHECKET UD.*)//')
        if echo "$BRANCH" | grep -q "CHECKET UD"; then
            echo "Springer over (checket ud): $CLEAN_BRANCH - skift worktree og kør scriptet igen"
        else
            read -r -p "Slet '$CLEAN_BRANCH'? (y/n): " CHOICE
            if [ "$CHOICE" = "y" ]; then
                if git branch -d "$CLEAN_BRANCH" 2>/dev/null; then
                    echo "Slettet: $CLEAN_BRANCH"
                else
                    force_delete_prompt "$CLEAN_BRANCH"
                fi
            else
                echo "Sprunget over: $CLEAN_BRANCH"
            fi
        fi
    done 3< "$ORPHAN_FILE"
    echo "Færdig."
else
    echo "Ingen branches slettet."
fi

rm "$ORPHAN_FILE"
