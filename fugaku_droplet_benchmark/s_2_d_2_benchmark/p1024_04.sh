#!/bin/bash

#PJM -L "rscgrp=small"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=8x8x4"
#PJM --mpi "proc=1024"
#PJM -g ra000003
#PJM -x PJM_LLIO_GFSCACHE=/vol0004
#PJM -L "elapse=00:10:59"
#PJM -j
#PJM -S

module switch lang/tcsds-1.2.37

export OMP_NUM_THREADS=12
export PLE_MPI_STD_EMPTYFILE=off

export bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn

mpiexec sh -c 'if [ ${PMIX_RANK} == 0 ]; then ${bindir}/cgdyn p1024_04.inp > p1024_04.out; else ${bindir}/cgdyn p1024_04.inp; fi'
