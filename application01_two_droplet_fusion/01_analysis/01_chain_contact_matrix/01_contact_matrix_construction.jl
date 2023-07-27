#!/usr/bin/env julia

include("/home/tan/Workspace/genesis_CG_julia/src/lib/gcj.jl")
using Dates

function analyze_structure(i_test, i_run)
    ct_cutoff = 10
    ct_cellsz = 5

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
    n_cell_x = Int(round(box_size_x / ct_cellsz))
    n_cell_y = Int(round(box_size_y / ct_cellsz))
    n_cell_z = Int(round(box_size_z / ct_cellsz))

    # data structure
    chain_contact_matrix_all = zeros(Int, (num_pro_B, num_pro_B, num_frames))
    # chain_contact_matrix_all = BitArray(undef, (num_pro_B, num_pro_B, num_frames))
    chain_contact_matrix_all .= 0

    # ==================
    # analyze trajectory
    # ==================
    lname = @sprintf("test%d_chain_contact_analysis_step_%02d.log", i_test, i_run)
    log_out  = open(lname, "w")
    n = Threads.nthreads()
    t0_global = now()
    t0 = [now() for i in 1:n]
    t1 = [now() for i in 1:n]
    Threads.@threads for i_step in 1:num_frames
        my_id = Threads.threadid()
        t0[my_id] = now()
        # get conformation
        myconf = mytraj.conformations[i_step]
        mycoors = myconf.coors

        # -------------
        # cell division
        # -------------
        cell_contents = [[] for i = 1:n_cell_x, j = 1:n_cell_y, k = 1:n_cell_z]
        atom_location = zeros(Int, (3, num_atom_all))
        for i_atom in 1:num_atom_all
            wrapped_coors = rem.(mycoors[:, i_atom], box_size, RoundDown)
            c_x, c_y, c_z = mod.(Int.(ceil.(wrapped_coors ./ ct_cellsz)) .- 1, [n_cell_x, n_cell_y, n_cell_z]) .+ 1
            atom_location[:, i_atom] = [c_x, c_y, c_z]
            push!(cell_contents[c_x, c_y, c_z], i_atom)
            # println(i_atom, "  ", mycoors[:, i_atom], "  in ", c_x, " ", c_y, " ", c_z)
        end
        t1[my_id] = now()
        dt = t1[my_id] - t0[my_id]
        @printf(log_out, "   ~~~> Step %8d | cell division: %8d ms \n", i_step, dt.value)

        # -----------------------------------
        # detect contacts between chain pairs
        # -----------------------------------
        chain_contact_matrix = zeros(Int, (num_pro_B, num_pro_B))
        # chain_contact_matrix = BitArray(undef, (num_pro_B, num_pro_B))
        chain_contact_matrix .= 0

        for a_atom in 1:num_atom_all
            # println(" Processing atom ", a_atom)
            a_chain = div(a_atom - 1, num_atom_B) + 1
            a_coor  = mycoors[:, a_atom]
            i_cell, j_cell, k_cell = atom_location[:, a_atom]
            b_upper_limit = (a_chain - 1) * num_atom_B

            # check local cell
            # println("   > substep 1...")
            my_atom_list = cell_contents[i_cell, j_cell, k_cell]
            for b_atom in my_atom_list
                if b_atom > a_atom
                    break
                end
                b_chain = div(b_atom - 1, num_atom_B) + 1
                chain_contact_matrix[a_chain, b_chain] = 1
            end
            # check local cell ends

            # check nearest neighboring cells
            # println("   > substep 2...")
            neighbor_cell_list = [[-1, 0, 0], [1, 0, 0], [0, -1, 0], [0, 1, 0], [0, 0, -1], [0, 0, 1]]
            for other_cell in neighbor_cell_list
                new_cell_index = mod.([i_cell, j_cell, k_cell] .+ other_cell .- 1, [n_cell_x, n_cell_y, n_cell_z]) .+ 1
                neighbor_atom_list = cell_contents[new_cell_index[1], new_cell_index[2], new_cell_index[3]]

                for b_atom in neighbor_atom_list
                    if b_atom > b_upper_limit
                        break
                    end
                    b_chain = div(b_atom - 1, num_atom_B) + 1
                    chain_contact_matrix[a_chain, b_chain] = 1
                end
            end
            # check neighboring cells ends

            # check other neighboring cells
            # println("   > substep 3...")
            for di in -2:2
                for dj in -2:2
                    for dk in -2:2
                        other_cell = [di, dj, dk]
                        if sum(abs.(other_cell)) <= 1
                            continue
                        end
                        new_cell_index = mod.([i_cell, j_cell, k_cell] .+ other_cell .- 1, [n_cell_x, n_cell_y, n_cell_z]) .+ 1
                        neighbor_atom_list = cell_contents[new_cell_index[1], new_cell_index[2], new_cell_index[3]]

                        # check atom pairs
                        for b_atom in neighbor_atom_list
                            if b_atom > b_upper_limit
                                break
                            end
                            b_chain = div(b_atom - 1, num_atom_B) + 1
                            if chain_contact_matrix[a_chain, b_chain] == 1
                                continue
                            end
                            b_coor = mycoors[:, b_atom]
                            d_coor = rem.(a_coor - b_coor, box_size, RoundNearest)
                            dist = sqrt(d_coor' * d_coor)
                            if dist < ct_cutoff
                                chain_contact_matrix[a_chain, b_chain] = 1
                            end
                        end
                        # check atom pairs ends
                    end
                end
            end
            # check other neighboring cells ends
        end

        # ---------------------
        # reflect contact pairs
        # ---------------------
        # for i_chain in 1:num_pro_B
        #     for j_chain in i_chain + 1:num_pro_B
        #         if chain_contact_matrix[i_chain, j_chain] == 1
        #             chain_contact_matrix[j_chain, i_chain] = 1
        #         end
        #     end
        # end

        chain_contact_matrix_all[:, :, i_step] = chain_contact_matrix[:, :]

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
    fname = @sprintf("test%d_chain_contact_analysis_step_%02d.dat", i_test, i_run)
    fout  = open(fname, "w")
    for i_step in 1:num_frames
        @printf(fout, "#### BEGIN step %5d \n", i_step)
        for i_chain in 1:num_pro_B
            for j_chain in i_chain:num_pro_B
                if chain_contact_matrix_all[j_chain, i_chain, i_step] == 1
                    @printf(fout, "%6d  %6d \n", i_chain, j_chain)
                end
            end
        end
        @printf(fout, "#### END step %5d \n", i_step)
    end
    close(fout)

end

if abspath(PROGRAM_FILE) == @__FILE__
    i_test = 2
    i_run = 1
    analyze_structure(i_test, i_run)
end
