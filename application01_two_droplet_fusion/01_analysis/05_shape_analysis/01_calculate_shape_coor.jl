#!/usr/bin/env julia

include("/home/tan/Workspace/genesis_CG_julia/src/lib/gcj.jl")
using Dates

function reverse_tan(x, y)
    if x >= 0 && y >= 0
        return atan(y / x)
    end
    if x >= 0 && y < 0
        return atan(y / x) + 2π
    end
    if x < 0
        return atan(y / x) + π
    end
end
function reverse_tan_vec(vec1::Vector{Float64}, vec2::Vector{Float64})
    vec_new = [0.0, 0.0, 0.0]
    for i = 1:3
        x = vec1[i]
        y = vec2[i]
        vec_new[i] = reverse_tan(x, y)
    end
    return vec_new[:]
end

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
    if i_test == 1
        args = Dict("verbose"=>false, "begin" => 1, "end" => 10000, "step" => 1)
    else
        args = Dict("verbose"=>false, "begin" => 1, "end" => 10000, "step" => 10)
    end
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
    droplet_shape_all = zeros(Float64, num_frames)

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

        # determine real COM (considering PBC)
        com_chain_droplet = com_chain_tmp[:, (chain_cluster_all[:, i_step] .> 0)[:]]
        println(log_out, " Size of droplet:", size(com_chain_droplet)[2])
        cos_circ_coors = cos.(com_chain_droplet ./ box_size .* 2π)
        sin_circ_coors = sin.(com_chain_droplet ./ box_size .* 2π)
        com_cos_circ_coors = sum(cos_circ_coors, dims=2) / size(cos_circ_coors)[2]
        com_sin_circ_coors = sum(sin_circ_coors, dims=2) / size(sin_circ_coors)[2]
        com_circ_coors = reverse_tan_vec(com_cos_circ_coors[:], com_sin_circ_coors[:])
        com_real_coors = com_circ_coors ./ (2π) .* box_size
        # for i_chain in 1:num_pro_B
        #     com_chain = com_chain_tmp[:, i_chain]
        #     com_new   = rem.(com_chain .- com_real_coors, box_size, RoundNearest) .+ (box_size .* 0.5)
        #     com_chain_tmp[:, i_chain] = com_new
        # end
        @printf(log_out, " Step %8d >>>> droplet size: %8.3f %8.3f %8.3f \n", i_step, com_real_coors[1], com_real_coors[2], com_real_coors[3])


        # -----------
        # find minmax
        # -----------
        x_min, x_max = Inf, -Inf
        y_min, y_max = Inf, -Inf
        z_min, z_max = Inf, -Inf

        for i_chain in 1:num_pro_B
            i_cluster_label = chain_cluster_all[i_chain, i_step]
            if i_cluster_label == 0
                continue
            end
            x, y, z = rem.(com_chain_tmp[:, i_chain] .- com_real_coors, box_size, RoundNearest)
            x_min = x < x_min ? x : x_min
            x_max = x > x_max ? x : x_max
            y_min = y < y_min ? y : y_min
            y_max = y > y_max ? y : y_max
            z_min = z < z_min ? z : z_min
            z_max = z > z_max ? z : z_max
        end

        dx = x_max - x_min
        dy = y_max - y_min
        dz = z_max - z_min

        η = max(dx / dy, dy / dx) + max(dy / dz, dz / dy) + max(dz / dx, dx / dz)

        droplet_shape_all[i_step] = η


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
        @printf(fout, "%6d  %18.3f \n", i_step, droplet_shape_all[i_step])
    end
    close(fout)

end

if abspath(PROGRAM_FILE) == @__FILE__
    i_test = 0
    i_run = 0
    analyze_structure(i_test, i_run)
end
