#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt

def main(i_test):
    fig, axes = plt.subplots(1, 1, figsize=(5, 3), constrained_layout=True, sharex=False, sharey=False)

    # i_test = 1

    m_data_name = "../03_mixing_coordinate/test{0}_chain_distance_mixing_step_01.dat".format(i_test)
    e_data_name = "../06_shape_analysis/test{0}_chain_pairwise_distance_sum_step_01.dat".format(i_test)

    m_data = np.loadtxt(m_data_name)
    e_data = np.loadtxt(e_data_name, usecols=(1))

    carray = np.array([k for k in range(m_data.size)])
    # carray = e_data
    axes.scatter(m_data, e_data, s=2, cmap="jet", c=carray)

    axes.set_xticks([0.2 * j for j in range(6)])
    axes.set_xticklabels([round(0.2 * j, 1) for j in range(6)], fontsize=12)
    axes.set_xlim(0.35, 1.05)
    axes.set_xlabel("m", fontsize=16)

    axes.set_yticks([2.5 + 0.5 * j for j in range(6)])
    axes.set_yticklabels([2.5 + 0.5 * j for j in range(6)], fontsize=12)
    axes.set_ylim(2.8, 5.7)
    axes.set_ylabel(r"$\eta$", fontsize=16)

    figname = "test{0}_single_m_vs_eta_c_time.svg".format(i_test)
    plt.savefig(figname, dpi=150)

if __name__ == '__main__':
    main(1)
