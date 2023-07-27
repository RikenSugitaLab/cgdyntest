#!/usr/bin/env julia

include("/home/tan/Workspace/genesis_CG_julia/src/lib/gcj.jl")
using Dates

function analyze_structure(i_test, i_run)

    # ---------
    # variables
    # ---------
    pro_name_A = "hero11"
    pro_name_B = "tdp43"
    num_pro_A  = 0
    num_atom_A = 99
    num_pro_B  = 1000
    num_atom_B = 154
    num_atom_all = num_pro_A * num_atom_A + num_pro_B * num_atom_B

    top_fname = @sprintf("../../tdp43_1000.top")
    traj_fname = @sprintf("/home/jung/scallop/tests/droplet/80_tdp43_1000_dup_test_280K/test%d/step%d.dcd", i_test, i_run)

    mytop = read_grotop(top_fname)
    args = Dict("verbose"=>false, "begin" => 1, "end" => 10000, "step" => 10)
    mytraj = read_dcd(traj_fname, args)
    # mytraj = read_dcd(traj_fname)
    num_frames = length(mytraj.conformations)
    # println(" Total number of frames:", num_frames)

    # get box sizes
    box_size_x = mytraj.boundary_box_size[1, 1] # 1000
    box_size_y = mytraj.boundary_box_size[3, 1] # 1000
    box_size_z = mytraj.boundary_box_size[6, 1] # 1500
    # println(box_size_x, " ", box_size_y, " ", box_size_z)
    box_size = [box_size_x, box_size_y, box_size_z]

    # data structure
    chain_cluster_all = zeros(Int, (num_pro_B, num_frames))
    chain_pair_distance_ave_11 = zeros(Float64, num_frames)
    chain_pair_distance_ave_12 = zeros(Float64, num_frames)
    chain_pair_distance_ave_22 = zeros(Float64, num_frames)

    t0_global = now()

    # ------------------------------
    # read in clustering information
    # ------------------------------
    clstr_fname = @sprintf("../11_clustering_analysis/test%d_clustering_%02d.dat", i_test, i_run)
    i_frame = 0
    i_chain = 0
    for line in eachline(clstr_fname)
        if startswith(line, "#### BEGIN")
            i_frame += 1
            continue
        end
        if startswith(line, "#### END")
            i_chain = 0
            continue
        end
        i_chain += 1
        i1 = parse(Int, strip(line))
        chain_cluster_all[i_chain, i_frame] = i1
    end


    # ==================
    # analyze trajectory
    # ==================
    log_name = @sprintf("test%d_chain_pair_distance_step_%02d.log", i_test, i_run)
    log_out  = open(log_name, "w")
    t0 = [now() for i in 1:Threads.nthreads()]
    t1 = [now() for i in 1:Threads.nthreads()]
    t2 = [now() for i in 1:Threads.nthreads()]
    Threads.@threads for i_step in 1:num_frames
        my_id = Threads.threadid()
        t0[my_id] = now()
        # get conformation
        myconf = mytraj.conformations[i_step]
        mycoors = myconf.coors

        # --------------
        # preparation...
        # --------------
        com_chain_tmp = zeros(Float64, (3, num_pro_B))
        # com
        i_shift = 0
        for i_chain in 1:num_pro_B
            com_chain = sum(mycoors[:, i_shift + 1 : i_shift + num_atom_B], dims=2) ./ num_atom_B
            com_chain_tmp[:, i_chain] = com_chain[:]
            i_shift += num_atom_B
        end

        # ------------------------
        # calculate distance pairs
        # ------------------------
        dist_sum_11 = 0
        dist_sum_12 = 0
        dist_sum_22 = 0
        count_11 = 0
        count_12 = 0
        count_22 = 0
        for i_chain in 1:num_pro_B
            i_cluster_label_init = chain_cluster_all[i_chain, 1]
            i_cluster_label_tmp  = chain_cluster_all[i_chain, i_step]
            if i_cluster_label_init == 0
                continue
            end
            if i_cluster_label_tmp  == 0
                continue
            end
            coor_i = com_chain_tmp[:, i_chain]

            for j_chain in i_chain + 1:num_pro_B
                j_cluster_label_init = chain_cluster_all[j_chain, 1]
                j_cluster_label_tmp  = chain_cluster_all[j_chain, i_step]
                if j_cluster_label_init == 0
                    continue
                end
                if j_cluster_label_tmp  == 0
                    continue
                end
                coor_j = com_chain_tmp[:, j_chain]

                d_coor = rem.(coor_i - coor_j, box_size, RoundNearest)
                dist = sqrt(d_coor' * d_coor)

                if i_cluster_label_init == 1 && j_cluster_label_init == 1
                    dist_sum_11 += dist
                    count_11    += 1
                elseif i_cluster_label_init == 2 && j_cluster_label_init == 2
                    dist_sum_22 += dist
                    count_22    += 1
                elseif i_cluster_label_init == 1 && j_cluster_label_init == 2
                    dist_sum_12 += dist
                    count_12    += 1
                elseif i_cluster_label_init == 2 && j_cluster_label_init == 1
                    dist_sum_12 += dist
                    count_12    += 1
                end
            end
        end

        chain_pair_distance_ave_11[i_step] = dist_sum_11 / count_11
        chain_pair_distance_ave_12[i_step] = dist_sum_12 / count_12
        chain_pair_distance_ave_22[i_step] = dist_sum_22 / count_22

        t1[my_id] = now()
        dt = t1[my_id] - t0[my_id]
        @printf(log_out, " Step %8d on thread %02d | step time: %8d ms. \n", i_step, my_id, dt.value)
    end
    t1_global = now()
    dt = t1_global - t0_global
    @printf(log_out, " ================================================== \n")
    @printf(log_out, " Total time: %8d s. \n", dt.value / 1000)

    # ======
    # output
    # ======
    fname = @sprintf("test%d_chain_pairwise_distance_sum_step_%02d.dat", i_test, i_run)
    fout  = open(fname, "w")
    for i_step in 1:num_frames
        @printf(fout, "%6d  %18.12f %18.12f %18.12f \n", i_step, chain_pair_distance_ave_11[i_step], chain_pair_distance_ave_12[i_step], chain_pair_distance_ave_22[i_step])
    end
    close(fout)

end

if abspath(PROGRAM_FILE) == @__FILE__
    i_test = 0
    i_run = 0
    analyze_structure(i_test, i_run)
end
