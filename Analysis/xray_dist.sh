#Declare the lipids for the analysis
declare -a LipidArray=("dope")

#First output xtc to only BB + lipid and same resids as in X-Ray file
for lipid in ${LipidArray[@]}
do
        for val in `seq 1 5`
        do
	echo -e "a BB \n  16|r DOPE \n q" | gmx make_ndx -f md_${lipid}_seed${val}_prot_center_pbcmol.gro -o index_${lipid}_seed${val}.ndx
	echo 17 | gmx trjconv -f md_${lipid}_seed${val}_prot_center_pbcmol.xtc -s md_${lipid}_seed${val}_prot_center_pbcmol.gro -n index_${lipid}_seed${val}.ndx -o md_${lipid}_seed${val}_prot_center_pbcmol_BB.xtc
	echo 17 | gmx trjconv -f md_${lipid}_seed${val}_prot_center_pbcmol.gro -s md_${lipid}_seed${val}_prot_center_pbcmol.gro -n index_${lipid}_seed${val}.ndx -e 1 -o md_${lipid}_seed${val}_prot_center_pbcmol_BB.gro
	done
done

#Output the X-ray file to only N and the ligand
#Fit using VMD one of the gro files (per lipid) to the XR one
#Save the aligned structure as ${lipid}_BB_fit.pdb
#Change name of lipid beads (GL1 GL2 D2A D2B) to C (to solve problem of mass reading)

for lipid in ${LipidArray[@]}
do
        for val in `seq 1 5`
        do
	#Fitting the trajectories to the aligned structure
	echo 1 0 | gmx trjconv -f md_${lipid}_seed${val}_prot_center_pbcmol_BB.xtc -s ${lipid}_BB_fit.pdb -o md_${lipid}_seed${val}_prot_center_pbcmol_BB_fit.xtc -fit rot+trans
	done
done

gmx trjcat -f  md_${lipid}_seed*_fit.xtc -o traj_${lipid}_fit_time.xtc -settime < ./inputc.txt

#Then run dist_xray_dope.tcl putting the value of the center of the carbon atoms, not considering the headgroups and the corresponding ones to the GL beads
vmd -e dist_xray_${lipid}.tcl

