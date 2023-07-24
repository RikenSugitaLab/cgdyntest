#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p256_XX.inp p256_${n}.inp
    cp p256_XX.sh p256_${n}.sh
    sed -e "s/XX/$n/g" -i p256_${n}.inp
    sed -e "s/XX/$n/g" -i p256_${n}.sh
    sleep 0.1
    pjsub p256_${n}.sh
done

