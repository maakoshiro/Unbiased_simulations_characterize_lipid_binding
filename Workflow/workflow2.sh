
#First minimization in vaccuum
gmx grompp -f ./common/min-vac.mdp -p cg.top -c ${pdb}_cg_newbox.gro -o min-vac.tpr
gmx mdrun -v -deffnm min-vac

#Choose the lipids to apply the protocol to
declare -a LipidArray=("dopc") #"chol" "dppc" "to" "olac" "dpsm")

for lipid in ${LipidArray[@]}
do
	#Five replicas
        for replica in `seq 1 5`

        do
	#Inserting the lipid in random positions
        gmx insert-molecules -f min-vac.gro -ci ./common/cg_${lipid}.gro -nmol 1 -o 1molecule_${lipid}_seed${replica}.gro

	#Solvating with non-polarizable water
        gmx solvate -cp 1molecule_${lipid}_seed${replica}.gro -cs ./common/water.gro -radius 0.21 -o solv_1molecule_${lipid}_seed${replica}.gro
        cp cg.top ${lipid}_seed${replica}.top
        echo "$lipid  1" | tr a-z A-Z >> ${lipid}_seed${replica}.top
        grep -c W solv_1molecule_${lipid}_seed${replica}.gro | sed 's/^/W  /' >> ${lipid}_seed${replica}.top
        gmx grompp -f ./common/ions-cg.mdp -c solv_1molecule_${lipid}_seed${replica}.gro -p ${lipid}_seed${replica}.top -o ions_${lipid}_seed${replica}.tpr  -maxwarn 1

	#Ionizing with NaCl 0.12 M
        echo 14 | gmx genion -s ions_${lipid}_seed${replica}.tpr -o ions_${lipid}_seed${replica}.gro -p ${lipid}_seed${replica}.top -pname NA -nname CL -neutral -conc 0.12

	#Minimization
        gmx grompp -f ./common/min-vac.mdp -c ions_${lipid}_seed${replica}.gro -p ${lipid}_seed${replica}.top -o min-ions_${lipid}_seed${replica}.tpr
        gmx mdrun -v -nt 4 -deffnm min-ions_${lipid}_seed${replica}
        gmx make_ndx -f  min-ions_${lipid}_seed${replica}.gro -o index_${lipid}_seed${replica}.ndx < ./common/input_prot_nonprot.txt

	#Equilibration
        gmx grompp -f ./common/npt_eq.mdp -c min-ions_${lipid}_seed${replica}.gro -p ${lipid}_seed${replica}.top -o npt_eq_${lipid}_seed${replica}.tpr -n index_${lipid}_seed${replica}.ndx -r min-ions_${lipid}_seed${replica}.gro
        gmx mdrun -nt 4 -v -deffnm npt_eq_${lipid}_seed${replica}

	#TPR for production is generated
        gmx grompp -f ./common/martini_v2.x_new-rf_3us.mdp -c  npt_eq_${lipid}_seed${replica}.gro -t npt_eq_${lipid}_seed${replica}.cpt -n index_${lipid}_seed${replica}.ndx -p ${lipid}_seed${replica}.top -o md_${lipid}_seed${replica}.tpr -maxwarn 1
        done
done
