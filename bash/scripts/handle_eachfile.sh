# creates a file for each line in m.txt
xargs -0 mkdir < <(tr \\n \\0 <m.txt)


ls -d */ | sed 's/.$//' | xargs -0 mkdir

# take each item in a file a.txt and execute
xargs -a output.txt -0 ./m

# take each item in output.txt and execute m with $line as argument
cat output.txt | while read line; do ./m $line; done

# get each item on each line and remove the trailing /
ls -d */ | sed 's/.$//' > output.txt
