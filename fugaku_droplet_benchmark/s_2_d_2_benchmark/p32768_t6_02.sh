#!/bin/bash

#PJM -L "rscgrp=large"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=16x16x16:strict"
#PJM --mpi "proc=32768"
#PJM -g ra000003
#PJM -x PJM_LLIO_GFSCACHE=/vol0004
#PJM -L "elapse=00:10:59"
#PJM -j
#PJM -S

module switch lang/tcsds-1.2.37

export OMP_NUM_THREADS=6
export PLE_MPI_STD_EMPTYFILE=off

export bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn

llio_transfer ${bindir}/cgdyn

mpiexec sh -c 'if [ ${PMIX_RANK} == 0 ]; then ${bindir}/cgdyn p32768_t6_02.inp > p32768_t6_02.out; else ${bindir}/cgdyn p32768_t6_02.inp; fi'
