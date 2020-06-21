ps aux | grep 'oc port-forward' | grep -v grep | awk '{print $2}' | xargs --no-run-if-empty kill $1 
