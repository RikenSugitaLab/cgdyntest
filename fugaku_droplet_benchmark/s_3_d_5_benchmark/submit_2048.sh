#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p2048_XX.inp p2048_${n}.inp
    cp p2048_XX.sh p2048_${n}.sh
    sed -e "s/XX/$n/g" -i p2048_${n}.inp
    sed -e "s/XX/$n/g" -i p2048_${n}.sh
    sleep 0.1
    pjsub p2048_${n}.sh
done

