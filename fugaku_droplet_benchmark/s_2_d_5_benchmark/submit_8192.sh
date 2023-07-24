#!/bin/bash

j=01

for n in {01,02,03,04,05}; do
    cp p8192_XX.inp p8192_${n}.inp
    cp p8192_XX.sh p8192_${n}.sh
    sed -e "s/XX/$n/g" -i p8192_${n}.inp
    sed -e "s/XX/$n/g" -i p8192_${n}.sh
    sleep 0.1
    pjsub p8192_${n}.sh
done

