#!/usr/bin/env python3

def main(filename, outname):
    new_pdb = open(outname, "w")

    is_first_base = True
    new_B_line = ""
    new_S_line = ""
    new_P_line = ""

    fuck_dict = {"C": "O", "G": "C", "T": "S", "A": "N"}
    # chain_id_dict = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    chain_id_dict = "あかさたな濱家らわ一二三四五六"
    def get_cid(i_chain):
        ib = i_chain // 10
        ia = i_chain % 10
        # return chain_id_dict[ib] + chain_id_dict[ia]
        return chain_id_dict[ia]

    with open(filename, "r") as fin:
        i_chain = 0
        cid = "a"
        for line in fin:
            if line.startswith("ATOM"):
                atm_name = line[13:16].strip()
                res_name = line[17:19].strip()
                atm_indx = int(line[6:11])
                if atm_name == "DP":
                    new_atm_name = "P"
                    new_indx = (atm_indx + 1) % 1000
                    fuck_c = "P"
                    new_P_line = "{0}{1:>5d}  {2:<3}{3}{4:>2}{5}{6:>23}\n".format(line[:6], new_indx, new_atm_name, line[16:20], cid, line[22:54], fuck_c)
                elif atm_name == "DS":
                    new_atm_name = "S"
                    new_indx = (atm_indx + 1) % 1000
                    fuck_c = "H"
                    new_S_line = "{0}{1:>5d}  {2:<3}{3}{4:>2}{5}{6:>23}\n".format(line[:6], new_indx, new_atm_name, line[16:20], cid, line[22:54], fuck_c)
                else:
                    new_atm_name = res_name[-1]
                    new_indx = (atm_indx - 1 if is_first_base else atm_indx - 2) % 1000
                    fuck_c = fuck_dict[new_atm_name]
                    new_B_line = "{0}{1:>5d}  {2:<3}{3}{4:>2}{5}{6:>23}\n".format(line[:6], new_indx, new_atm_name, line[16:20], cid, line[22:54], fuck_c)
                    # output
                    new_pdb.write(new_B_line)
                    if not is_first_base:
                        new_pdb.write(new_P_line)
                    new_pdb.write(new_S_line)
                    # reset first base flag
                    is_first_base = False
            elif line.startswith("TER"):
                i_chain += 1
                cid = get_cid(i_chain)
                is_first_base = True
                new_pdb.write(line)
    new_pdb.close()


if __name__ == '__main__':
    import argparse
    def parse_arguments():
        parser = argparse.ArgumentParser(description='Convert GENESIS standard PDB to whatever stupid one...')
        parser.add_argument('-f', '--filename', type=str, help="Old PDB file name")
        parser.add_argument('-o', '--outname',  type=str, help="New PDB file name")

        return parser.parse_args()
    args = parse_arguments()
    main(args.filename, args.outname)
