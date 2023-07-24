#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p32768_t3_XX.inp p32768_t3_${n}.inp
    cp p32768_t3_XX.sh p32768_t3_${n}.sh
    sed -e "s/XX/$n/g" -i p32768_t3_${n}.inp
    sed -e "s/XX/$n/g" -i p32768_t3_${n}.sh
    sleep 0.1
    pjsub p32768_t3_${n}.sh
done

