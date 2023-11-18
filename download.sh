#!/bin/bash -e

docker pull stelzo/swf-to-svg:latest
docker pull stelzo/svg-to-png:latest

if [[ $(uname) == "Linux" ]]; then
    os="Linux"
elif [[ $(uname) == "Darwin" ]]; then
    os="Darwin"
else
    echo "Unsupported operating system"
    exit 1
fi

rm -rf out

curl -s https://api.github.com/repos/dofusdude/doduda/releases/latest \
    | grep "browser_download_url.*${os}_x86_64.tar.gz" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -

tar -xzf "doduda_${os}_x86_64.tar.gz"
rm "doduda_${os}_x86_64.tar.gz"
chmod +x doduda

./doduda --headless --release beta
echo "Done with loading"

./doduda map --headless --indent --release beta
echo "Done with mapping"

mkdir out

tar -czf items_images.tar.gz data/img/item/
tar -czf mounts_images.tar.gz data/img/mount/

mv items_images.tar.gz out/
mv mounts_images.tar.gz out/
echo "Created bitmaps"

tar -czf items_images_vector.tar.gz data/vector/item/
tar -czf mounts_images_vector.tar.gz data/vector/mount/

mv items_images_vector.tar.gz out/
mv mounts_images_vector.tar.gz out/
echo "Created vectors"

mkdir -p data/vector/mount
mkdir -p data/img/mount

echo "Starting rendering"
./doduda render data/vector/mount data/img/mount 200 --headless --incremental dofusdude/dofus2-beta/mounts_images_200
tar -czf mounts_images_200.tar.gz $( find data/img/mount -name "*-200.png" )

./doduda render data/vector/mount data/img/mount 400 --headless --incremental dofusdude/dofus2-beta/mounts_images_400
tar -czf mounts_images_400.tar.gz $( find data/img/mount -name "*-400.png" )

./doduda render data/vector/mount data/img/mount 800 --headless --incremental dofusdude/dofus2-beta/mounts_images_800
tar -czf mounts_images_800.tar.gz $( find data/img/mount -name "*-800.png" )

mv mounts_images_200.tar.gz out/
mv mounts_images_400.tar.gz out/
mv mounts_images_800.tar.gz out/
echo "Done with mounts image rendering"

mkdir -p data/vector/item
mkdir -p data/img/item
./doduda render data/vector/item data/img/item 200 --headless --incremental dofusdude/dofus2-beta/items_images_200
tar -czf items_images_200.tar.gz $( find data/img/item -name "*-200.png" )

./doduda render data/vector/item data/img/item 400 --headless --incremental dofusdude/dofus2-beta/items_images_400
tar -czf items_images_400.tar.gz $( find data/img/item -name "*-400.png" )

./doduda render data/vector/item data/img/item 800 --headless --incremental dofusdude/dofus2-beta/items_images_800
tar -czf items_images_800.tar.gz $( find data/img/item -name "*-800.png" )

mv items_images_200.tar.gz out/
mv items_images_400.tar.gz out/
mv items_images_800.tar.gz out/
echo "Done with items image rendering"

mv data/*.json out/
mv data/languages/*.json out/

echo "Cleaning up"
rm -rf data
rm -rf manifest.json

echo "~~ Finished ~~"