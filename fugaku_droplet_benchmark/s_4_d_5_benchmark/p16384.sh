#!/bin/bash

#PJM -L "rscgrp=large"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=16x16x16:strict"
#PJM --mpi "proc=16384"
#PJM -L "elapse=00:10:00"
#PJM -j
#PJM -S

export OMP_NUM_THREADS=12

bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
llio_transfer $bindir/cgdyn
mpiexec -stdout p16384.out -stderr p16384.err $bindir/cgdyn p16384.inp

