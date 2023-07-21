#!/usr/bin/env python

import glob
import argparse
import numpy as np
import os
import re
import matplotlib.pyplot as plt

def main(log_dir, sysname="", verbose=False):

    N_RUN = 100                 # upper limit of runs per ( process x thread )
    N_MPI = 10000               # upper limit of MPI processes

    if verbose:
        print("Getting information from ", log_dir)

    if len(sysname) == 0:
        sysname = "atdyn_cg"

    run_simu_name = []
    run_simu_name_index = []

    # run_simulation_time     = []
    run_total_time_all      = []  # "dynamics"
    run_energy_time_all     = []  # "energy"
    run_integrator_time_all = []  # "integrator"
    run_pairlist_time_all   = []  # "pairlist"

    run_bond_time_all          = []  # "bond"
    run_angle_time_all         = []  # "angle"
    run_dihedral_time_all      = []  # "dihedral"
    run_base_stacking_time_all = []  # "base stacking"
    run_nonbond_time_all       = []  # "nonbond" (total)

    run_CG_exv_time_all        = []  # "CG exv"
    run_CG_DNA_bp_time_all     = []  # "CG DNA bp"
    run_CG_DNA_exv_time_all    = []  # "CG DNA exv"
    run_CG_ele_time_all        = []  # "CG ele"
    run_CG_PWMcos_time_all     = []  # "CG PWMcos"
    run_CG_PWMcosns_time_all   = []  # "CG PWMcosns"
    run_CG_IDR_HPS_time_all    = []  # "CG IDR-HPS"
    run_CG_IDR_KH_time_all     = []  # "CG IDR-KH"
    run_CG_KH_time_all         = []  # "CG KH"
    run_CG_contace_time_all    = []  # "CG contact"
    run_pme_real_time_all      = []  # "pme real"
    run_pme_recip_time_all     = []  # "pme recip"

    run_mpi_barrier_time_all   = []
    run_mpi_reduce_time_all    = []

    sim_time_per_day_all = []
    sim_step_per_day_all = []

    for filename in glob.glob(log_dir + "*.log"):
        if verbose:
            print("Analyzing ", filename, " ...")
        m = re.search(r"p([0-9]*)_t([0-9]*)_r([0-9]{2})", filename)
        mpinum = int(m[1])
        ompnum = int(m[2])
        runnum = int(m[3])

        run_simu_name.append("p{0:0>4d}-t{1:0>2d}-r{2:0>2d}".format(mpinum, ompnum, runnum))
        run_simu_name_index.append(N_RUN * N_MPI * ompnum + N_RUN * mpinum + runnum)
        with open(filename, "r") as fin:
            time_stepsize = 0
            md_steps = 0
            tot_time = 0
            for line in fin:
                words = line.split()
                if len(words) < 2:
                    continue
                if len(line) >= 18:
                    keyword = line[:18].strip()

                if line.startswith("INFO:") and words[1] != "STEP":
                    md_steps = int(words[1])
                if keyword == "timestep" and line[18] == "=":
                    time_stepsize = float(words[2])

                if keyword == "dynamics" and line[18] == "=":
                    tot_time = float(words[2])
                    run_total_time_all.append(tot_time)
                elif keyword == "energy" and line[18] == "=":
                    run_energy_time_all.append(float(words[2]))
                elif keyword == "integrator" and line[18] == "=" and len(words) == 3:
                    run_integrator_time_all.append(float(words[2]))
                elif keyword == "pairlist" and line[18] == "=":
                    run_pairlist_time_all.append( (float(words[2]), float(words[4][:-1]), float(words[5][:-1])) )
                elif keyword == "bond" and line[18] == "=":
                    run_bond_time_all.append( (float(words[2]), float(words[4][:-1]), float(words[5][:-1])) )
                elif keyword == "angle" and line[18] == "=":
                    run_angle_time_all.append( (float(words[2]), float(words[4][:-1]), float(words[5][:-1])) )
                elif keyword == "dihedral" and line[18] == "=":
                    run_dihedral_time_all.append( (float(words[2]), float(words[4][:-1]), float(words[5][:-1])) )
                elif keyword == "base stacking" and line[18] == "=":
                    run_base_stacking_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "nonbond" and line[18] == "=":
                    run_nonbond_time_all.append( (float(words[2]), float(words[4][:-1]), float(words[5][:-1])) )
                elif keyword == "CG exv" and line[18] == "=":
                    run_CG_exv_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "CG DNA bp" and line[18] == "=":
                    run_CG_DNA_bp_time_all.append( (float(words[4]), float(words[6][:-1]), float(words[7][:-1])) )
                elif keyword == "CG DNA exv" and line[18] == "=":
                    run_CG_DNA_exv_time_all.append( (float(words[4]), float(words[6][:-1]), float(words[7][:-1])) )
                elif keyword == "CG ele" and line[18] == "=":
                    run_CG_ele_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "CG PWMcos" and line[18] == "=":
                    run_CG_PWMcos_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "CG PWMcosns" and line[18] == "=":
                    run_CG_PWMcosns_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "CG IDR-HPS" and line[18] == "=":
                    run_CG_IDR_HPS_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "CG IDR-KH" and line[18] == "=":
                    run_CG_IDR_KH_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "CG KH" and line[18] == "=":
                    run_CG_KH_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "pme real" and line[18] == "=":
                    run_pme_real_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "pme recip" and line[18] == "=":
                    run_pme_recip_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "MPI Barrier" and line[18] == "=":
                    run_mpi_barrier_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                elif keyword == "MPI Reduce" and line[18] == "=":
                    run_mpi_reduce_time_all.append( (float(words[3]), float(words[5][:-1]), float(words[6][:-1])) )
                else:
                    pass
            # local simulation time estimation
            if tot_time == 0:
                print("WARNING: ", filename, " total simulation time == 0!!!")
                run_simu_name.pop()
                run_simu_name_index.pop()
            else:
                sim_step_per_day = md_steps / tot_time * 86400
                sim_step_per_day_all.append(sim_step_per_day)
                sim_time_per_day = ( time_stepsize / 1000 ) * sim_step_per_day
                sim_time_per_day_all.append(sim_time_per_day)


    # =====================
    # pick out output terms
    # =====================
    termnames = ["run", "total",
                 "energy", "integrat",
                 "pairlist ( min , max )"
                 ]
    data_all_in_one = [run_total_time_all,
                       run_energy_time_all,
                       run_integrator_time_all,
                       run_pairlist_time_all
                       ]
    if len(run_bond_time_all) > 0 and sum(run_bond_time_all[0]) > 0:
        termnames.append("bond ( min , max )")
        data_all_in_one.append(run_bond_time_all)
    if len(run_angle_time_all) > 0 and sum(run_angle_time_all[0]) > 0:
        termnames.append("angle ( min , max )")
        data_all_in_one.append(run_angle_time_all)
    if len(run_dihedral_time_all) > 0 and sum(run_dihedral_time_all[0]) > 0:
        termnames.append("dihedral ( min , max )")
        data_all_in_one.append(run_dihedral_time_all)
    if len(run_base_stacking_time_all) > 0 and sum(run_base_stacking_time_all[0]) > 0:
        termnames.append("bs ( min , max )")
        data_all_in_one.append(run_base_stacking_time_all)
    if len(run_nonbond_time_all) > 0 and sum(run_nonbond_time_all[0]) > 0:
        termnames.append("nonbond ( min , max )")
        data_all_in_one.append(run_nonbond_time_all)
    if len(run_CG_exv_time_all) > 0 and sum(run_CG_exv_time_all[0]) > 0:
        termnames.append("general exv ( min , max )")
        data_all_in_one.append(run_CG_exv_time_all)
    if len(run_CG_DNA_bp_time_all) > 0 and sum(run_CG_DNA_bp_time_all[0]) > 0:
        termnames.append("DNA bp ( min , max )")
        data_all_in_one.append(run_CG_DNA_bp_time_all)
    if len(run_CG_DNA_exv_time_all) > 0 and sum(run_CG_DNA_exv_time_all[0]) > 0:
        termnames.append("DNA_exv ( min , max )")
        data_all_in_one.append(run_CG_DNA_exv_time_all)
    if len(run_CG_ele_time_all) > 0 and sum(run_CG_ele_time_all[0]) > 0:
        termnames.append("ele ( min , max )")
        data_all_in_one.append(run_CG_ele_time_all)
    if len(run_CG_PWMcos_time_all) > 0 and sum(run_CG_PWMcos_time_all[0]) > 0:
        termnames.append("PWMcos ( min , max )")
        data_all_in_one.append(run_CG_PWMcos_time_all)
    if len(run_CG_PWMcosns_time_all) > 0 and sum(run_CG_PWMcosns_time_all[0]) > 0:
        termnames.append("PWMcosns ( min , max )")
        data_all_in_one.append(run_CG_PWMcosns_time_all)
    if len(run_CG_IDR_HPS_time_all) > 0 and sum(run_CG_IDR_HPS_time_all[0]) > 0:
        termnames.append("IDR-HPS ( min , max )")
        data_all_in_one.append(run_CG_IDR_HPS_time_all)
    if len(run_CG_IDR_KH_time_all) > 0 and sum(run_CG_IDR_KH_time_all[0]) > 0:
        termnames.append("IDR-KH ( min , max )")
        data_all_in_one.append(run_CG_IDR_KH_time_all)
    if len(run_CG_KH_time_all) > 0 and sum(run_CG_KH_time_all[0]) > 0:
        termnames.append("KH ( min , max )")
        data_all_in_one.append(run_CG_KH_time_all)
    if len(run_pme_real_time_all) > 0 and sum(run_pme_real_time_all[0]) > 0:
        termnames.append("pme real ( min , max )")
        data_all_in_one.append(run_pme_real_time_all)
    if len(run_pme_recip_time_all) > 0 and sum(run_pme_recip_time_all[0]) > 0:
        termnames.append("pme recip ( min , max )")
        data_all_in_one.append(run_pme_recip_time_all)
    if len(run_mpi_barrier_time_all) > 0 and sum(run_mpi_barrier_time_all[0]) > 0:
        termnames.append("MPI Barrier ( min , max )")
        data_all_in_one.append(run_mpi_barrier_time_all)
    if len(run_mpi_reduce_time_all) > 0 and sum(run_mpi_reduce_time_all[0]) > 0:
        termnames.append("MPI Reduce ( min , max )")
        data_all_in_one.append(run_mpi_reduce_time_all)
    termnames.append("estimate steps")
    data_all_in_one.append(sim_step_per_day_all)
    termnames.append("estimate time")
    data_all_in_one.append(sim_time_per_day_all)

    # ======
    # output
    # ======
    data1_name = "{0}.benchmark_details.org".format(sysname)
    of = open(data1_name, "w")
    of.write("| {0:18s} |".format("run name"))
    for name in termnames[1:4]:
        of.write(" {0:8s} |".format(name))
    for name in termnames[4:]:
        of.write(" {0:32s} |".format(name))
    of.write("\n")
    of.write("|--------------------|")
    for name in termnames[1:4]:
        of.write("----------|")
    for name in termnames[4:]:
        of.write("----------------------------------|")
    of.write("\n")

    for run_name_index in sorted( run_simu_name_index ):
        i = run_simu_name_index.index(run_name_index)
        of.write("| {0:18s} |".format(run_simu_name[i]))
        for data in data_all_in_one[:3]:
            of.write(" {0:8.3f} |".format(data[i]))
        for data in data_all_in_one[3:-2]:
            of.write(" {0:8.3f} ( {1:8.3f} , {2:8.3f} ) |".format(data[i][0], data[i][1], data[i][2]))
        of.write(" {0:8.1f} |".format(data_all_in_one[-2][i]))
        of.write(" {0:8.1f} |".format(data_all_in_one[-1][i]))
        of.write("\n")

    of.close()

    # ===========
    # Plotting...
    # ===========
    num_subfigs = len(data_all_in_one)

    # determine profile lists of different omp numbers
    omp_run_dict = {}
    mpi_num_list = []
    for n in sorted( run_simu_name_index ):
        i = run_simu_name_index.index(n)

        omp_num = n // (N_MPI * N_RUN)
        mpi_num = n % (N_MPI * N_RUN) // N_RUN
        if mpi_num not in mpi_num_list:
            mpi_num_list.append(mpi_num)

        if omp_num not in omp_run_dict.keys():
            omp_run_dict[omp_num] = {mpi_num: (i, sim_time_per_day_all[i])}
        else:
            if mpi_num not in omp_run_dict[omp_num].keys():
                omp_run_dict[omp_num][mpi_num] = (i, sim_time_per_day_all[i])
            else:
                time_tmp = omp_run_dict[omp_num][mpi_num][1]
                if sim_time_per_day_all[i] > time_tmp:
                    omp_run_dict[omp_num][mpi_num] = (i, sim_time_per_day_all[i])
    if verbose:
        print(sorted( omp_run_dict.keys() ))

    # make figure
    fig, axes = plt.subplots(( num_subfigs - 1 ) // 2 + 1, 2, figsize=(9, 2 * num_subfigs // 2), constrained_layout=True, sharex=True, sharey=False)
    omp_color_num = len(omp_run_dict.keys())

    # output estimation
    data2_name = "{0}.benchmark_summary.org".format(sysname)
    of = open(data2_name, "w")

    for i_omp, n_omp in enumerate( omp_run_dict.keys() ):
        mpi_run_dict = omp_run_dict[n_omp]
        c_tmp = (i_omp / omp_color_num, 0, 1 - i_omp/omp_color_num)
        X = sorted(mpi_run_dict.keys())
        Y_idx = [mpi_run_dict[x][0] for x in X]

        # energy and integrator
        for i_axis in [0, 1, 2, num_subfigs - 2, num_subfigs - 1]:
            Y = []
            for j in Y_idx:
                Y.append(data_all_in_one[i_axis][j])
            axes[i_axis//2, i_axis%2].plot(X, Y, ls="--", marker="o", c=c_tmp, mec=c_tmp, lw=1.0)
            axes[i_axis//2, i_axis%2].set_title(termnames[i_axis+1])
            if i_axis == num_subfigs - 2:
                for j in range(len(X)):
                    of.write("{0:>6d}  {1:>6d}    {2:>18.6e}  \n".format(n_omp, X[j], Y[j]))

        # Detailed energy terms
        for i_axis in range(3, num_subfigs - 2):
            Y = []
            yerr_min = []
            yerr_max = []
            for j in Y_idx:
                Y.append(data_all_in_one[i_axis+0][j][0])
                yerr_min.append(data_all_in_one[i_axis+0][j][0] - data_all_in_one[i_axis+0][j][1])
                yerr_max.append(data_all_in_one[i_axis+0][j][2] - data_all_in_one[i_axis+0][j][0])
            y_err = np.array([yerr_min, yerr_max])
            axes[i_axis//2, i_axis%2].errorbar(X, Y, yerr=y_err, ls="--", marker="o", c=c_tmp, mec=c_tmp, ecolor=c_tmp, capsize=5, lw=1.0)
            axes[i_axis//2, i_axis%2].set_title(termnames[i_axis+1])

    for i_axis in range(num_subfigs):
        # xticks = axes[i_axis//2, i_axis%2].get_xticks()
        xticks = mpi_num_list
        yticks = axes[i_axis//2, i_axis%2].get_yticks()
        axes[i_axis//2, i_axis%2].set_xscale("log")
        axes[i_axis//2, i_axis%2].minorticks_off()
        axes[i_axis//2, i_axis%2].set_xticks(xticks)
        axes[i_axis//2, i_axis%2].set_xticklabels(xticks, fontsize=14)
        axes[i_axis//2, i_axis%2].set_yticks(yticks)
        axes[i_axis//2, i_axis%2].set_yticklabels([round( y, 3 ) for y in yticks], fontsize=14)
        ymin, ymax = max(min(yticks), 0), max(yticks)
        axes[i_axis//2, i_axis%2].set_ylim(ymin, ymax)
        axes[i_axis//2, i_axis%2].set_ylabel("cpu time (s)", fontsize=16)
        axes[i_axis//2, i_axis%2].grid(axis="y", ls="-", color="black", alpha=0.2)
    i_axis = num_subfigs - 2
    axes[i_axis//2, i_axis%2].set_ylabel("speed (steps/day)", fontsize=16)
    i_axis = num_subfigs - 1
    axes[i_axis//2, i_axis%2].set_ylabel("speed (ns/day)", fontsize=16)

    fig1_name = "{0}.benchmark_details.svg".format(sysname)
    plt.savefig(fig1_name, dpi=150)

    of.close()


if __name__ == '__main__':
    def parse_arguments():
        parser = argparse.ArgumentParser(description='Analyze MD simulation time from GENESIS log files.')
        parser.add_argument('log_dir', type=str, help="Directory of the log files.")
        parser.add_argument('-n', '--name', type=str, help="Name of the benchmark system.", default="")
        parser.add_argument('-v', '--verbose', help="Output more information", action="store_true")
        return parser.parse_args()

    args = parse_arguments()
    main(log_dir = args.log_dir, sysname = args.name, verbose = args.verbose)
