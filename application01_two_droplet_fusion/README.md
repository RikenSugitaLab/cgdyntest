## MD simulations of two-droplet fusion system with cgdyn

```bash
cd 00_MD/run/
GENESIS/bin/cgdyn step1.inp > step1.log
GENESIS/bin/cgdyn step2.inp > step2.log
GENESIS/bin/cgdyn step3.inp > step3.log
GENESIS/bin/cgdyn step4.inp > step4.log
GENESIS/bin/cgdyn step5.inp > step5.log
# ...

cd ../../
```

## Data analysis of droplet fusion (Figure 3)

```bash
cd 01_analysis/

# construct chain-chain contact matrix
cd 01_chain_contact_matrix
./01_contact_matrix_construction.jl
cd ..

# DBSCAN clustering
cd 02_clustering
./01_clustering_assignments.jl
cd ..

# calculating the "mixing" coordinate
cd 03_mixing_coordinate
./01_calculate_distance_sum.jl
cd ..

# get the distribution of chains in the simulation box
cd 04_chain_distribution
./01_calculate_distribution.jl
cd ..

# determine the shape of fused droplet
cd 05_shape_analysis
./01_calculate_shape_coor.jl
cd ..

# plot the correlation of coordinates
cd 06_correlation_plot
./01_plot_m_vs_eta.py
cd ..
```
