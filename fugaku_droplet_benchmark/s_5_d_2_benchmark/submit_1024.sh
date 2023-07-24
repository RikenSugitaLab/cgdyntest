#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p1024_XX.inp p1024_${n}.inp
    cp p1024_XX.sh p1024_${n}.sh
    sed -e "s/XX/$n/g" -i p1024_${n}.inp
    sed -e "s/XX/$n/g" -i p1024_${n}.sh
    sleep 0.1
    pjsub p1024_${n}.sh
done

