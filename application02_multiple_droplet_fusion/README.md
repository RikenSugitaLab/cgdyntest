## MD simulations of two-droplet fusion system with cgdyn

```bash
cd 00_MD/

cp ../fugaku_droplet_benchmark/_DROPLET_test_eq_s_5_d_2_05_02_*.rst .
cp ../fugaku_droplet_benchmark/_DROPLET_test_eq_s_5_d_5_05_05_*.rst .

cd crd/
cp ../fugaku_droplet_benchmark/crd/rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho1.00.gro.tar.gz .
cp ../fugaku_droplet_benchmark/crd/rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho0.62.gro.tar.gz .
gunzip rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho1.00.gro.tar.gz
gunzip rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho0.62.gro.tar.gz
cd ../

# high density system
cd run_high_density/
GENESIS/bin/cgdyn step1.inp > step1.log
GENESIS/bin/cgdyn step2.inp > step2.log
GENESIS/bin/cgdyn step3.inp > step3.log
# ...

cd ..

# low density system
cd run_low_density/
GENESIS/bin/cgdyn step1.inp > step1.log
GENESIS/bin/cgdyn step2.inp > step2.log
GENESIS/bin/cgdyn step3.inp > step3.log
# ...

cd ../../
```

## Data analysis of multiple droplet dynamics (Figure 4)

```bash
cd 01_analysis/

# construct chain-chain (COM) distance matrix
cd 01_distance_matrix
./00_distance_matrix.jl
cd ..

# clustering
cd 02_clustering
./01_clustering_assignments.jl
cd ..
```
