#!/bin/bash

#PJM -L "rscgrp=small"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=2x2x1"
#PJM --mpi "proc=16"
#PJM -g ra000003
#PJM -x PJM_LLIO_GFSCACHE=/vol0004
#PJM -L "elapse=00:10:59"
#PJM -j
#PJM -S

module switch lang/tcsds-1.2.37

export OMP_NUM_THREADS=12
export PLE_MPI_STD_EMPTYFILE=off

export bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
illio_transfer ${bindir}/cgdyn

mpiexec sh -c 'if [ ${PMIX_RANK} == 0 ]; then ${bindir}/cgdyn p16_05.inp > p16_05.out; else ${bindir}/cgdyn p16_05.inp; fi'
