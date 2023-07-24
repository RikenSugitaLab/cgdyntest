#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p512_t3_XX.inp p512_t3_${n}.inp
    cp p512_t3_XX.sh p512_t3_${n}.sh
    sed -e "s/XX/$n/g" -i p512_t3_${n}.inp
    sed -e "s/XX/$n/g" -i p512_t3_${n}.sh
    sleep 0.1
    pjsub p512_t3_${n}.sh
done

