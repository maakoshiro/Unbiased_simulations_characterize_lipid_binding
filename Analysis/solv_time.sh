#Select the lipid for which to compute the solvation interactively
echo "lipid?"
read lipid

for val in `seq 1 5`
do

cat >source_$lipid$val.txt << EOF
source calc_$lipid$val.vmd
exit
EOF

#Make sure to change the lipid tail beads according to your simulated lipid
cat >calc_$lipid$val.vmd << EOF
mol delete all
mol new ./md_${lipid}_seed${val}_prot_center_pbcmol.gro
mol addfile ./md_${lipid}_seed${val}_prot_center_pbcmol.xtc waitfor all
set file [open "water_around_lipid_${lipid}_seed${val}_time.dat" w]
set sel [atomselect top "name W and pbwithin 5 of (name C1A D2A C3A C4A C1B D2B C3B C4B)"]
set n [molinfo top get numframes]
for {set i 0} {\$i<\$n} {incr i} {
     \$sel frame \$i
     \$sel update
     set len1  [llength [lsort -unique [\$sel get resid]]]
     puts \$file "\$i	\$len1"
     }
close \$file
exit
EOF
	vmd -dispdev none -e source_${lipid}${val}.txt
done
rm calc_$lipid*vmd
rm source_$lipid*txt

#Concatenation of the results
cat water_around_lipid_${lipid}_seed*time.dat > water_around_lipid_${lipid}_all_time.dat 
