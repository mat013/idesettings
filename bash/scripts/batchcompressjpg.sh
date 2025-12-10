# install imagemagick
# create a folder

mkdir resized
for f in `find . -name "*.jpg"`; 
do     
  convert $f -resize 50% resized/$f.resized.jpg; 
done
