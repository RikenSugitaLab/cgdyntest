#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p32_XX.inp p32_${n}.inp
    cp p32_XX.sh p32_${n}.sh
    sed -e "s/XX/$n/g" -i p32_${n}.inp
    sed -e "s/XX/$n/g" -i p32_${n}.sh
    sleep 0.1
    pjsub p32_${n}.sh
done

