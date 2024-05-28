echo "lipid?"
read lip

for i in 1 2 3 4 5
do

	gmx select -f md_${lip}_seed${i}_prot_center_pbcmol.xtc -s md_${lip}_seed${i}_prot_center_pbcmol.gro -n index_${lip}_seed${i}.ndx -of occ.xvg -ofpdb prot_occ_${lip}_seed${i}.pdb -select 'group 1 and within 0.5 of group 13' -selrpos atom -b 900000 -e 1000000

done
