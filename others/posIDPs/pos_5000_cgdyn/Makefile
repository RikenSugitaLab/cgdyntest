default:

clean:
	rm -f p*.log p*.job.*[oe]*
localtest:
	cp pro.atin __test__.atin
	sed -e "/nsteps/s/100/100/g" -e "/eneout/s/100/20/g" -i __test__.atin
	export OMP_NUM_THREADS=2; mpirun -np 4 ~/Workspace/genesis/src/atdyn/atdyn __test__.atin | tee __test__.log
localclean:
	rm -f __test__.log __test__.atin
purge: clean localclean
	rm -f p*.job benchmark*.md benchmark*.png
