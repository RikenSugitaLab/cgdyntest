#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p128_XX.inp p128_${n}.inp
    cp p128_XX.sh p128_${n}.sh
    sed -e "s/XX/$n/g" -i p128_${n}.inp
    sed -e "s/XX/$n/g" -i p128_${n}.sh
    sleep 0.1
    pjsub p128_${n}.sh
done

