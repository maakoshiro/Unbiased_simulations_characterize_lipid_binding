#Source the installed GROMACS in your workstation
source /opt/GROMACS/2021.2/bin/GMXRC

#Write the name of the PDB ID used for the protocol
pdb=250v

#Use CHARMM-GUI PDB Reader to prepare the PDB for the workflow
#Untar the result, the workflow will use step1_pdbreader.pdb

cp ./charmm-gui*/step1_pdbreader.pdb step1_pdbreader_his.pdb

#Changing the name of the histidines for martinize script
sed -i 's/HSD/HIS/g' step1_pdbreader_his.pdb
sed -i '/HD1 HIS/d' step1_pdbreader_his.pdb

#Make sure to change the path for DSSP
martinize2 -f step1_pdbreader_his.pdb -x ${pdb}_cg_fc1000_eu8.pdb -o topol.top -ff martini3001 -elastic -ef 1000 -eu 0.8 -nt -scfix -cys auto -dssp /usr/bin/dssp 

#CHOOSE -merge <chainID> for multimers

#Inserting the CG protein in a cubic box with 2 nm of distance
gmx editconf -f ${pdb}_cg_fc1000_eu8.pdb  -c -d 2.0 -bt cubic -o ${pdb}_cg_newbox.gro

cp ./common/cg.top .
