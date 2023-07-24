#!/bin/bash

#PJM -L "rscgrp=small"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=4x4x4"
#PJM --mpi "proc=512"
#PJM -L "elapse=00:10:00"
#PJM -j
#PJM -S

export OMP_NUM_THREADS=6

bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
llio_transfer $bindir/cgdyn
mpiexec -stdout p512_t6.out -stderr p512_t6.err $bindir/cgdyn p512_t6.inp

