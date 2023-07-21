#!/bin/bash


#for n in {1,2,3,4,5,6,7,8,9,10,15,20,30}; do        # epsilon
for n in {64,128,256,512,1024}; do        # epsilon
#   n2=$(echo "$n * $n * 1" | bc)
    for i in {01..05}; do
#       cp test.atin __dupDNA_${n}_r_$i.atin
#       cp dna.job   __dupDNA_${n}_r_$i.job
#       cp ./BIGMOL_mul_${n}_${n}_1_n_${n2}.top  __dupDNA_${n}_r_$i.top
#       cp ./BIGMOL_mul_${n}_${n}_1_n_${n2}.gro  __dupDNA_${n}_r_$i.gro
        sed -e "s/cgin/atin/g" -i p${n}_t05_r$i.job
        sed -e "s/cgdyn/atdyn/g" -i p${n}_t05_r$i.job
#       sed -e "s/RUNNAME/__dupDNA_${n}_r_$i/g" -i __dupDNA_${n}_r_$i.job
        sleep 0.1
        pjsub p${n}_t05_r$i.job
    done
done
