#!/usr/bin/env julia

using Clustering
using Printf

function main(i_step, i_frame)
    # input
    data_fname = @sprintf("../01_distance_matrix/step%02d_chain_contact_analysis_frame_%05d.dat", i_step, i_frame)
    n_chain = 16657
    n_steps = 1

    # output
    out_fname = @sprintf("test_clustering_%02d_frame_%05d.dat", i_step, i_frame)
    out_file  = open(out_fname, "w")
    log_fname = @sprintf("test_clustering_%02d_frame_%05d.log", i_step, i_frame)
    log_file  = open(log_fname, "w")

    # data structure
    cnt_matrix = zeros(Float64, (n_chain, n_chain))

    # load "connectivity matrix"
    println("Analyzing ...", data_fname)
    i_step = 0
    for line in eachline(data_fname)
        if startswith(line, "#### BEGIN")
            i_step += 1
            # cnt_matrix .= 0
            continue
        end
        if startswith(line, "#### END")
            # clustering = dbscan(cnt_matrix, 100, min_neighbors = 20, min_cluster_size = div(n_chain, 10), metric = nothing)
            # println(" Step ", i_step, "   num of clusters: ", length(clustering.counts))
            # @printf(out_file, "#### BEGIN step %6d | #clusters %3d \n", i_step, length(clustering.counts))
            # @printf("#### BEGIN step %6d | #clusters %3d \n", i_step, length(clustering.counts))
            # for j_chain in 1:n_chain
                # @printf(out_file, "%2d \n", clustering.assignments[j_chain])
            # end
            # @printf("#### END step %6d \n", i_step)
            continue
        end
        words = split(line)
        r1 = parse(Int, words[1])
        r2 = parse(Int, words[2])
        d  = parse(Float64, words[3])
        cnt_matrix[r1, r2] = d
        cnt_matrix[r2, r1] = d
        if mod(r1, 1000) == mod(r2, 1000) == 0
            println(r1, "  ", r2,  "  ", d)
        end
    end

    # begin clustering
    println(" Begin clustering... ")
    clustering = dbscan(cnt_matrix, 50, min_neighbors = 5, min_cluster_size = 50, metric = nothing)
    @printf(out_file, "#### BEGIN | #clusters %3d \n", length(clustering.counts))
    @printf("####  #clusters %3d \n",  length(clustering.counts))
    @printf(log_file, "####  #clusters %3d \n",  length(clustering.counts))
    for j_chain in 1:n_chain
        @printf(out_file, "%2d \n", clustering.assignments[j_chain])
    end
    @printf(out_file, "#### END  \n")

    # finalizing
    close(out_file)
end

if abspath(PROGRAM_FILE) == @__FILE__
    # step_list = [20:25...]
    step_list = [1 for i in 1:4]
    frame_list = [500 * i for i in 1:4]
    # i_step = 0
    # i_frame = 0
    for (i_step, i_frame) in zip(step_list, frame_list)
        main(i_step, i_frame)
    end
end
