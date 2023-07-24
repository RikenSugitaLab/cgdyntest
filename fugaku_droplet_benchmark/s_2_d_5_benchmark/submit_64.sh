#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p64_XX.inp p64_${n}.inp
    cp p64_XX.sh p64_${n}.sh
    sed -e "s/XX/$n/g" -i p64_${n}.inp
    sed -e "s/XX/$n/g" -i p64_${n}.sh
    sleep 0.1
    pjsub p64_${n}.sh
done

