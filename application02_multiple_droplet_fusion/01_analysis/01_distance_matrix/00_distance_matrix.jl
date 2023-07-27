#!/usr/bin/env julia

include("/home/ctan/Workspace/genesis_CG_julia/src/lib/gcj.jl")
using Dates
using Clustering
using Printf

function analyze_structure(i_test, i_frame)
    ct_cutoff = 10
    ct_cellsz = 5

    # ---------
    # variables
    # ---------
    pro_name_A = "hero11"
    pro_name_B = "tdp43"
    num_pro_A  = 0
    num_atom_A = 99
    num_pro_B  = 16657
    num_atom_B = 154
    num_atom_all = num_pro_A * num_atom_A + num_pro_B * num_atom_B

    top_fname = @sprintf("../rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho1.00.top")
    crd_fname = @sprintf("../01_extract_structures/rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho0.56_s_5_d_5_md_%02d_frame_%05d.gro", i_test, i_frame)
    # crd_fname = @sprintf("./rCG_Droplets_50_50_50_100_b100_f85_g20_d0_rho1.00.gro")

    mytop = read_grotop(top_fname)
    # args = Dict("verbose"=>false, "begin" => 1, "end" => 10000, "step" => 10)
    # mytraj = read_dcd(traj_fname, args)
    # mytraj = read_dcd(traj_fname)
    # num_frames = length(mytraj.conformations)
    # println(" Total number of frames:", num_frames)
    mycrd = read_grocrd(crd_fname)

    # get box sizes
    # box_size_x = mytraj.boundary_box_size[1, 1] # 1000
    # box_size_y = mytraj.boundary_box_size[3, 1] # 1000
    # box_size_z = mytraj.boundary_box_size[6, 1] # 1500
    box_size_x = 2087
    box_size_y = 2067
    box_size_z = 2077
    # println(box_size_x, " ", box_size_y, " ", box_size_z)
    box_size = [box_size_x, box_size_y, box_size_z]
    # n_cell_x = Int(round(box_size_x / ct_cellsz))
    # n_cell_y = Int(round(box_size_y / ct_cellsz))
    # n_cell_z = Int(round(box_size_z / ct_cellsz))

    # data structure
    chain_contact_matrix = zeros(Float64, (num_pro_B, num_pro_B))
    chain_contact_matrix .= 0

    # ==================
    # analyze trajectory
    # ==================
    lname = @sprintf("step%02d_chain_contact_analysis_frame_%05d.log", i_test, i_frame)
    log_out  = open(lname, "w")
    n = Threads.nthreads()
    t0_global = now()
    t0 = [now() for i in 1:n]
    t1 = [now() for i in 1:n]
    Threads.@threads for i_step in 1:1
        my_id = Threads.threadid()
        t0[my_id] = now()
        # get conformation
        mycoors = mycrd.coors

        # -----------------------------------
        # detect contacts between chain pairs
        # -----------------------------------

        # ---
        # com
        # ---
        println("Preparing COMs.")
        com_all = zeros(Float64, (3, num_pro_B))
        i_atom = 0
        for i_chain in 1:num_pro_B
            my_com = sum(mycoors[:, i_atom + 1 : i_atom + num_atom_B], dims=2) / num_atom_B
            com_all[:, i_chain] = my_com[:]
            i_atom += num_atom_B
        end

        # ---------------
        # distance matrix
        # ---------------
        println("Computing distance matrix.")
        for i_chain in 1:num_pro_B
            if mod(i_chain, 1000) == 0
                println("computing>", i_chain)
            end
            a_com = com_all[:, i_chain]
            for j_chain in i_chain + 1:num_pro_B
                b_com = com_all[:, j_chain]
                d_coor = rem.(a_com - b_com, box_size, RoundNearest)
                dist = sqrt(d_coor' * d_coor)
                chain_contact_matrix[i_chain, j_chain] = dist
            end
        end

        t1[my_id] = now()
        dt = t1[my_id] - t0[my_id]
        @printf(log_out, " Step %8d on thread %02d | step time: %8d ms. \n", i_step, my_id, dt.value)
    end
    t1_global = now()
    dt = t1_global - t0_global
    @printf(log_out, " Total time: %8d s. \n", dt.value / 1000)

    # ======
    # output
    # ======
    fname = @sprintf("step%02d_chain_contact_analysis_frame_%05d.dat", i_test, i_frame)
    fout  = open(fname, "w")
    for i_step in 1:1
        @printf(fout, "#### BEGIN step %5d \n", i_step)
        for i_chain in 1:num_pro_B
            if mod(i_chain, 1000) == 0
                println("output>", i_chain)
            end
            for j_chain in i_chain:num_pro_B
                if chain_contact_matrix[i_chain, j_chain] > 1e-6
                    @printf(fout, "%5d %5d %6.1f\n", i_chain, j_chain, chain_contact_matrix[i_chain, j_chain])
                end
            end
        end
        @printf(fout, "#### END step %5d \n", i_step)
    end
    close(fout)

end

if abspath(PROGRAM_FILE) == @__FILE__
    i_test = 1
    # i_frame = 2000
    for i_frame in [500, 1000, 1500, 2000]
        analyze_structure(i_test, i_frame)
    end
end
