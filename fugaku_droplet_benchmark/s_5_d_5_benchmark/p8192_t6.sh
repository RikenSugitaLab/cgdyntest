#!/bin/bash

#PJM -L "rscgrp=large"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=16x8x8:strict"
#PJM --mpi "proc=8192"
#PJM -L "elapse=00:10:00"
#PJM -j
#PJM -S

export OMP_NUM_THREADS=6

bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
llio_transfer $bindir/cgdyn
mpiexec -stdout p8192_t6.out -stderr p8192_t6.err $bindir/cgdyn p8192_t6.inp

