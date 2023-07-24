#!/bin/bash

#PJM -L "rscgrp=large"
#PJM -L "rscunit=rscunit_ft01"
#PJM -L "node=32x16x16"
#PJM --mpi "proc=32768"
#PJM -L "elapse=00:30:00"
#PJM -j
#PJM -S

export OMP_NUM_THREADS=12

bindir=/home/ra000003/data/jung/program/genesis-mkl-private_20230228/src/cgdyn
llio_transfer $bindir/cgdyn
mpiexec -stdout p32768.out -stderr p32768.err $bindir/cgdyn p32768.inp

