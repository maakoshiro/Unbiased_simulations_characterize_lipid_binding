#Select the lipids for which to compute the volumetric density map
declare -a LipidArray=("dops" "dopc")

for lipid in ${LipidArray[@]}
do
        for val in `seq 1 5`
        do
	#Create trajectories with only lipid and protein and the last 100 ns of the simulations
	echo -e " 1|13 \n q" | gmx make_ndx -f md_${lipid}_seed${val}_prot_center_pbcmol.gro -o index_${lipid}_seed${val}_v.ndx
	echo 16 | gmx trjconv -f md_${lipid}_seed${val}_prot_center_pbcmol.xtc -s md_${lipid}_seed${val}_prot_center_pbcmol.gro -n index_${lipid}_seed${val}_v.ndx -b 900000 -o md_${lipid}_seed${val}_prot_center_pbcmol_v.xtc
	echo 16 | gmx trjconv -f md_${lipid}_seed${val}_prot_center_pbcmol.gro -s md_${lipid}_seed${val}_prot_center_pbcmol.gro -n index_${lipid}_seed${val}_v.ndx -e 1 -o md_${lipid}_seed${val}_prot_center_pbcmol_v.gro
	done

	#Save a separate gro file
	cp md_${lipid}_seed1_prot_center_pbcmol_v.gro ${lipid}_v.gro

	#Concatenate all trajectories
	gmx trjcat -f  md_${lipid}_seed*_prot_center_pbcmol_v.xtc -o traj_${lipid}_v.xtc -settime < ./inputc.txt
	vmd -e ./volmap_${lipid}_lt.tcl -dispdev none
done

