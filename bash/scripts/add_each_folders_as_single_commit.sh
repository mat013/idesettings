# cp ../m . && find . -maxdepth 1 -type d \( ! -name . \) ! -path "*/.*" ! -path "*/." -execdir bash -c './m "{}"' \;
folder_name=${1:2:${#1}-2}
echo "$folder_name"
git add "$folder_name" 
git commit -m "Adding $folder_name"

