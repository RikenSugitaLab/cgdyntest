#!/bin/bash

#PJM -L "rscgrp=small"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=2x2x1"
#PJM --mpi "proc=16"
#PJM -L "elapse=00:10:00"
#PJM -j
#PJM -S

export OMP_NUM_THREADS=12

bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
llio_transfer $bindir/cgdyn
mpiexec -stdout p16.out -stderr p16.err $bindir/cgdyn p16.inp

