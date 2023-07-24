#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p512_XX.inp p512_${n}.inp
    cp p512_XX.sh p512_${n}.sh
    sed -e "s/XX/$n/g" -i p512_${n}.inp
    sed -e "s/XX/$n/g" -i p512_${n}.sh
    sleep 0.1
    pjsub p512_${n}.sh
done

