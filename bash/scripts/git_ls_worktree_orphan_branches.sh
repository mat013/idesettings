#!/bin/bash

# Farver til output
RED='\033[0;31m'
NC='\033[0;m' # No Color

# Kør 'git branch -vv' og filtrer resultaterne
git branch -vv | while read -r line; do
    echo "---------------------------------------------"
    echo "Hele linje: $line"

    # Ekstraher branch-navn og fjern eventuelle '*' eller '+'
    local_branch=$(echo "$line" | sed -E 's/^[*+ ]*//; s/ .*//')
    echo "Lokal branch: '$local_branch'"

    # Spring over, hvis lokal_branch er tom
    if [[ -z "$local_branch" ]]; then
        echo "Tom lokal branch, springer over..."
        continue
    fi

    # Tjek om linjen indeholder en remote-tracking reference
    if [[ "$line" =~ \[origin/[^]]*\] ]]; then
        # Ekstraher remote-tracking-info
        remote_info=$(echo "$line" | grep -oE '\[origin/[^]]+\]')
        echo "Remote info: '$remote_info'"

        # Ekstraher remote-branch-navn (fjern 'origin/')
        remote_branch=$(echo "$remote_info" | sed -E "s/.*origin\/([^]:[]+)[]:]?.*/\1/")
        echo "Remote branch: '$remote_branch'"

        
        status=$(echo "$remote_info" | grep -oP ': \K[^]]+(?=])' || echo "")
        echo "status: '$status'"
        

        # Tjek om lokal og remote branch-navn er ens
        if [[ "$local_branch" != "$remote_branch" ]]; then
            echo "Forskellig! Udskriver lokal branch..."
            echo -e "${RED}$local_branch${NC}"
        fi
    fi
done

#+ develop                                        9d308aad7f6 (/home/w98579/sources/osm2-monorepo-) [origin/develop: behind 1105] Merge pull request #15515 from osm2/team-platform/OSMDVU-00000-renovate-checkstyle-13.x
#+ develop1                                       458d0c3807f (/home/w98579/sources/osm2-monorepo-udv) Merge pull request #15554 from osm2/release/release-6.04.0
#+ production                                     7d32a664e1a (/home/w98579/sources/osm2-monorepo-fkt) [origin/production] Merge pull request #15638 from osm2/release/release-6.05.0
#* production-test                                a276e4ef175 [origin/production-test] Merge pull request #13449 from osm2/release/release-9.98.0
#  team-dare-w98579/OSMDVU-7076/OSMDVU-7076-tacit daef0a5eaae [origin/team-dare-w98579/OSMDVU-7076/OSMDVU-7076-tacit: gone] Merge remote-tracking branch 'origin/develop' into team-dare-w98579/OSMDVU-7076/OSMDVU-7076-tacit
