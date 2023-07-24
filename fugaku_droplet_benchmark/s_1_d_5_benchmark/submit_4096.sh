#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p4096_XX.inp p4096_${n}.inp
    cp p4096_XX.sh p4096_${n}.sh
    sed -e "s/XX/$n/g" -i p4096_${n}.inp
    sed -e "s/XX/$n/g" -i p4096_${n}.sh
    sleep 0.1
    pjsub p4096_${n}.sh
done

