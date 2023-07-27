#!/usr/bin/env julia

using Clustering
using Printf

function main(i_test, i_step)
    # input
    data_fname = @sprintf("../03_chain_pairwise_contact_analysis_20230506/test%d_chain_contact_analysis_step_%02d.dat", i_test, i_step)
    n_chain = 1000
    n_steps = 1000

    # output
    out_fname = @sprintf("test%d_clustering_%02d.dat", i_test, i_step)
    out_file  = open(out_fname, "w")

    # data structure
    cnt_matrix = ones(Int, (n_chain, n_chain))

    # load "connectivity matrix"
    println("Analyzing ...", data_fname)
    i_step = 0
    for line in eachline(data_fname)
        if startswith(line, "#### BEGIN")
            i_step += 1
            cnt_matrix .= 1
            continue
        end
        if startswith(line, "#### END")
            clustering = dbscan(cnt_matrix, 0.5, min_neighbors = 20, min_cluster_size = div(n_chain, 10), metric = nothing)
            # println(" Step ", i_step, "   num of clusters: ", length(clustering.counts))
            @printf(out_file, "#### BEGIN step %6d | #clusters %3d \n", i_step, length(clustering.counts))
            for j_chain in 1:n_chain
                @printf(out_file, "%2d \n", clustering.assignments[j_chain])
            end
            @printf(out_file, "#### END step %6d \n", i_step)
            continue
        end
        words = split(line)
        r1 = parse(Int, words[1])
        r2 = parse(Int, words[2])
        cnt_matrix[r1, r2] = 0
        cnt_matrix[r2, r1] = 0
    end

    # finalizing
    close(out_file)
end

if abspath(PROGRAM_FILE) == @__FILE__
    # i_test = 2
    # i_step = 1
    for i_test in 2:5
        for i_step in 1:5
            main(i_test, i_step)
        end
    end

end
