#!/bin/bash

while read ipaddr; do

    countryCode=$(curl -s ipinfo.io/$ipaddr/country)
    echo "$ipaddr,$countryCode" >> "$HOME/iploc.csv"

done <"$HOME/iplist.txt"