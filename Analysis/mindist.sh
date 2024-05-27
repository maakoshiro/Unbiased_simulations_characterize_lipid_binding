#Lipids for which to compute the minimum distance to the protein
declare -a LipidArray=("olac" "dopc")

#Name of the protein
prot="apom"

for lipid in ${LipidArray[@]}
do

#Write results in a new folder
mkdir mindist_$lipid
cd ./mindist_$lipid

        for replica in `seq 1 5`
        do
        echo 1 13 | gmx mindist -f ../md_${lipid}_seed${replica}_prot_center_pbcmol.xtc -s ../md_${lipid}_seed${replica}.tpr -od md_${prot}_${lipid}_seed${replica}.xvg
        done
cd ..
done

