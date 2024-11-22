#!/bin/bash -e

docker pull stelzo/swf-to-svg:latest
docker pull stelzo/svg-to-png:latest
docker pull stelzo/doduda-umbu:latest
docker pull stelzo/assetstudio-cli:latest

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

./doduda --headless --release beta --output data
echo "Done with loading"

#./doduda map --headless --indent --release beta
#echo "Done with mapping"

mkdir out

mv data/*.json out/
mv data/languages/*.json out/
echo "Moved json files"

tar -czf items_images.tar.gz $(find data/img/item -name "*.png" ! -name "*-200.png")
echo "Compressed all icon images"
mv items_images.tar.gz out/

tar -czf items_images_200.tar.gz $(find data/img/item -name "*-200.png")
echo "Compressed all sd images"
mv items_images_200.tar.gz out/

echo "Cleaning up"
rm -rf data
rm -rf manifest.json

echo "~~ Finished ~~"