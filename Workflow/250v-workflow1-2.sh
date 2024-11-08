declare -a LipidArray=("dopc") #"chol" "dppc" "to" "olac" "dpsm")

for lipid in ${LipidArray[@]}
do
	#Five replicas
        for replica in `seq 1 5`

        do
	#Inserting the lipid in random positions
        gmx insert-molecules -f min-vac.gro -ci ~/protein/common/cg_${lipid}.gro -nmol 1 -o 1molecule_${lipid}_seed${replica}.gro
        done
