#!/bin/bash
rm -rf decomp
mkdir decomp
cd decomp

git init

echo ".*"          >> .gitignore
echo "!.gitignore" >> .gitignore

wget "https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar" -O .cfr.jar

curl -s "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json" | \
jq -r '.versions | reverse[] | select(.type == "release") | "\(.id) \(.url)"' | \
while read -r version_info; do
    id=$(echo "$version_info" | awk '{print $1}')
    url=$(echo "$version_info" | awk '{print $2}')
    data=$(curl -s "$url")
    
    has_mappings=$(echo "$data" | jq -r '.downloads.client_mappings')
    if [ "$has_mappings" == "null" ]; then
        continue
    fi
    
    for file in *; do
        if [[ "$file" != *.* ]]; then
            rm -rf "$file"
        fi
    done

    wget $(echo "$data" | jq -r '.downloads.client_mappings.url') -O mappings.txt
    wget $(echo "$data" | jq -r '.downloads.client.url') -O client.jar

    java -jar .cfr.jar client.jar --outputdir . --obfuscationpath mappings.txt
    git add .
    git commit -m $id
done
