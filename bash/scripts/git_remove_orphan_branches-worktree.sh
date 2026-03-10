#!/bin/bash

# Farver til output
RED='\033[0;31m'
NC='\033[0;m' # No Color

# Kør 'git branch -vv' og filtrer resultaterne
git branch -vv | while read -r line; do
 #   echo "---------------------------------------------"
 #   echo "Hele linje: $line"

    # Ekstraher branch-navn og fjern eventuelle '*' eller '+'
    local_branch=$(echo "$line" | sed -E 's/^[*+ ]*//; s/ .*//')
#    echo "Lokal branch: '$local_branch'"

    # Spring over, hvis lokal_branch er tom
    if [[ -z "$local_branch" ]]; then
#        echo "Tom lokal branch, springer over..."
        continue
    fi

    # Tjek om linjen indeholder en remote-tracking reference
    if [[ "$line" =~ \[origin/[^]]*\] ]]; then
        # Ekstraher remote-tracking-info
        remote_info=$(echo "$line" | grep -oE '\[origin/[^]]+\]')
#        echo "Remote info: '$remote_info'"

        # Ekstraher remote-branch-navn (fjern 'origin/')
        remote_branch=$(echo "$remote_info" | sed -E "s/.*origin\/([^]:[]+)[]:]?.*/\1/")
 #       echo "Remote branch: '$remote_branch'"

        # Tjek om lokal og remote branch-navn er ens
        if [[ "$local_branch" != "$remote_branch" ]]; then
  #          echo "Forskellig! Udskriver lokal branch..."
            echo -e "${RED}$local_branch${NC}"
        fi
    fi
done

