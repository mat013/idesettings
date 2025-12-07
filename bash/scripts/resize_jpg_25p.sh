# use imagemagick
for img in *.jpg; do
  mogrify -resize 25% "$img"
done
