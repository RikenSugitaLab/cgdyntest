#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p16_XX.inp p16_${n}.inp
    cp p16_XX.sh p16_${n}.sh
    sed -e "s/XX/$n/g" -i p16_${n}.inp
    sed -e "s/XX/$n/g" -i p16_${n}.sh
    sleep 0.1
    pjsub p16_${n}.sh
done

