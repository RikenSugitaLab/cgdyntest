#!/bin/bash

#PJM -L "rscgrp=small"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=4x4x4"
#PJM --mpi "proc=1024"
#PJM -L "elapse=00:10:00"
#PJM -j
#PJM -S

export OMP_NUM_THREADS=3

bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
llio_transfer $bindir/cgdyn
mpiexec -stdout p1024_t3.out -stderr p1024_t3.err $bindir/cgdyn p1024_t3.inp

