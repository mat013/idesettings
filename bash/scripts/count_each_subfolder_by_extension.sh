find . -maxdepth 1 -type d \( ! -name . \) ! -path "*/.*" ! -path "*/." -execdir bash -c 'cd "{}" && echo -n "{}" && find . -name "*.java" -type f | wc -l' \;
