#Write the lipids that you simulated
for lip in chol dpsm dopc dppc to
do
	for i in $(eval echo "{1..5..1}")
	do
		echo -e "1|13 \n q" | gmx make_ndx -f md_${lip}_seed$i.tpr -o index_${lip}_$i.ndx
		#Change the path of the original xtc files accordingly
		gmx trjconv -f ./*$lip*/$i/md_${lip}_seed${i}.xtc -s md_${lip}_seed${i}.tpr -center -pbc mol -o md_${lip}_seed${i}_prot_center_pbcmol.xtc -n index_${lip}_$i.ndx <<<'1 0'
		gmx trjconv -f ./*$lip*/$i/md_${lip}_seed${i}.xtc -s md_${lip}_seed${i}.tpr -center -pbc mol -o md_${lip}_seed${i}_prot_center_pbcmol.gro -e 1 -n index_${lip}_$i.ndx <<<'1 0'
	done
done
