#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p16384_XX.inp p16384_${n}.inp
    cp p16384_XX.sh p16384_${n}.sh
    sed -e "s/XX/$n/g" -i p16384_${n}.inp
    sed -e "s/XX/$n/g" -i p16384_${n}.sh
    sleep 0.1
    pjsub p16384_${n}.sh
done

