#Source the installed GROMACS in your workstation
#source /opt/GROMACS/2021.2/bin/GMXRC

#Write the name of the PDB ID used for the protocol
pdb=250va

#Use CHARMM-GUI PDB Reader to prepare the PDB for the workflow
#Untar the result, the workflow will use step1_pdbreader.pdb

cp ~/protein/250v-step1_pdbreader.pdb 250v-step1_pdbreader_his.pdb

#Changing the name of the histidines for martinize script
sed -i 's/HSD/HIS/g' 250v-step1_pdbreader_his.pdb
sed -i '/HD1 HIS/d' 250v-step1_pdbreader_his.pdb

#Make sure to change the path for DSSP
martinize2 -f 250v-step1_pdbreader_his.pdb -x ${pdb}_cg_fc1000_eu8.pdb -o topol.top -ff martini3001 -elastic -ef 1000 -eu 0.8 -nt -scfix -cys auto -dssp ~/anaconda3/envs/py39/bin/dssp 

#CHOOSE -merge <chainID> for multimers

#Inserting the CG protein in a cubic box with 2 nm of distance
gmx editconf -f ${pdb}_cg_fc1000_eu8.pdb  -c -d 2.0 -bt cubic -o ${pdb}_cg_newbox.gro

cp ~/protein/common/cg.top .

#First minimization in vaccuum
gmx grompp -f ./common/min-vac.mdp -p cg.top -c ${pdb}_cg_newbox.gro -o min-vac.tpr
gmx mdrun -v -deffnm min-vac

#Choose the lipids to apply the protocol to
#declare -a Lipid="dopc" #"chol" "dppc" "to" "olac" "dpsm")
Lipid="dopc"

for lipid in ${dopc[@]}
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
