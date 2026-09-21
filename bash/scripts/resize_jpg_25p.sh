# use imagemagick
for img in *.jpg; do
  echo "$img"
  mogrify -resize 25% "$img"
done
