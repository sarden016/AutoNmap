#!/bin/bash

url=$1

if [ ! -d "url" ];then
	mkdir $url
fi

if [ ! -d "$url/recon" ];then
	mkdir $url/recon
fi

if [ ! -d "$url/recon/scans" ];then
    mkdir $url/recon/scans
fi

if [ ! -d "$url/recon/httprobe" ];then
    mkdir $url/recon/httprobe
fi

if [ ! -f "$url/recon/httprobe/alive.txt" ];then
    touch $url/recon/httprobe/alive.txt
fi

 
echo "[+] Harvesting subdomain with assestfinder"
assetfinder $url >> $url/recon/asset.txt
cat $url/recon/asset.txt | grep $1 >> $url/recon/Final.txt
rm $url/recon/asset.txt 

echo "[+] Probing for alive domains..."
cat $url/recon/Final.txt | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/alive.txt
rm $url/recon/httprobe/a.txt

echo "[+] Scanning for open ports..."
nmap -iL $url/recon/httprobe/alive.txt -T4 -oA $url/recon/scans/scanned.txt
