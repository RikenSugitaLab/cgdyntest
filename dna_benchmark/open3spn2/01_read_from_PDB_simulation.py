#!/usr/bin/env python3

import open3SPN2
import openmm
import openmm.app
import openmm.unit
import sys
import numpy as np
import time

def main():
    # number of copies of DNA
    n_copy = 36

    my_steps = 10000
    n_run = 5

    print("Generating {0} DNA duplicated system".format(n_copy))
    log_file_name = "__BM_DNA_{0:>03d}_copies__.profile".format(n_copy)
    log_file = open(log_file_name, "w")

    # ==============================
    # prepare structure and topology
    # ==============================
    # print("first step: generate coordinates")
    # dna = open3SPN2.DNA.fromSequence(seq, dna_type="B_curved")
    print("first step: read in PDB coordinates")
    DNA_PDB_fname = "./open3spn2_{0:>03d}.pdb".format(n_copy)
    dna = open3SPN2.DNA.fromCoarsePDB(DNA_PDB_fname, dna_type="B_curved", compute_topology=False)
    # dna = open3SPN2.DNA.fromCoarsePDB(DNA_PDB_fname, dna_type="B", compute_topology=False)
    print("   read in finished, begin compute topology")
    dna.computeTopology(template_from_X3DNA=False)
    dna.periodic = True
    # exit()

    # =========================
    # prepare simulation system
    # =========================
    print("second step: make a system")
    s = open3SPN2.System(dna, periodicBox=[100,100,100])
    print("  2.1: make system finished")
    s.add3SPN2forces(verbose=True)
    print("  2.2: add forces finished")
    # exit()

    print(" > setting up on GPU")
    platform = openmm.Platform.getPlatformByName("CUDA");
    # platform.setPropertyDefaultValue(property="DeviceIndex", value="0,1")
    platform.setPropertyDefaultValue(property="DeviceIndex", value="0")
    # map<string, string> properties;
    # properties = dict();
    # properties["DeviceIndex"] = "0;1";
    # integrator = openmm.LangevinIntegrator(300*openmm.unit.kelvin, 1 / simtk.openmm.unit.picosecond, 10 * simtk.openmm.unit.femtoseconds)
    # context(s, integrator, platform, properties);

    s.initializeMD(temperature=300*openmm.unit.kelvin, platform_name="CUDA")
    simulation = s.simulation

    # openmm.Platform.setPropertyValue(platform, simulation.context, property="DeviceIndex", value="0,1")

    print(" > coordinates...")
    simulation.context.setPositions(s.coord.getPositions())

    energy_unit = openmm.unit.kilocalorie_per_mole

    # single-point test
    # print(" > Single structure info:")
    # state = simulation.context.getState(getEnergy=True)
    # energy = state.getPotentialEnergy().value_in_unit(energy_unit)
    # print("TotalEnergy", round(energy, 6), energy_unit.get_symbol())

    # energies = {}
    # for force_name, force in s.forces.items():
    #     group = force.getForceGroup()
    #     state = simulation.context.getState(getEnergy=True, groups=2**group)
    #     energies[force_name] = state.getPotentialEnergy().value_in_unit(energy_unit)

    # for force_name in s.forces.keys():
    #     print(force_name, round(energies[force_name], 6), energy_unit.get_symbol())

    # ======
    # run MD
    # ======
    # prepare for MD
    print(" > prepare MD...")
    dcd_reporter = openmm.app.DCDReporter(f"dsDNA_trj.dcd", my_steps // 10)
    ene_reporter = openmm.app.StateDataReporter("dsDNA_ene.dat", my_steps // 10, step=True, time=True, potentialEnergy=True, temperature=True)

    simulation.reporters.append(dcd_reporter)
    simulation.reporters.append(ene_reporter)

    print("third step: MD loop")
    my_time_all = []
    for i in range(n_run):
        print(" > RUN # ", i)
        my_start = time.time()
        simulation.step(my_steps)
        my_end = time.time()
        my_time = my_end - my_start
        log_file.write("RUN {0:>3d} {1:>24.18f} {2:>24.18f} \n".format( i, my_time, my_time * 1e6 / my_steps))
        my_time_all.append(my_time)
    my_time_arr = np.array(my_time_all)
    my_time_mean, my_time_std = my_time_arr.mean(), my_time_arr.std()
    log_file.write("STAT {0:24.18f}    {1:24.18f} \n".format(my_time_mean, my_time_std))
    my_million_time = 1e6 / my_steps * my_time_mean
    my_million_std  = 1e6 / my_steps * my_time_std
    log_file.write("ESTM {0:24.18f}    {1:24.18f} \n".format(my_million_time, my_million_std))

if __name__ == '__main__':
    main()
