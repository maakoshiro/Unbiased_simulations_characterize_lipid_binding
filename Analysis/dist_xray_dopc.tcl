mol delete all
mol new dopc_BB_fit.pdb
mol addfile traj_dopc_fit_time.xtc waitfor all

#Time trace of the distance to the headgroups
#Calculate the center of mass (com1) using VMD, the selection will depend for each crystallographic ligand
set com1 {17.759000778198242 -49.86960220336914 -6.260799884796143}
set outfile [open "dist_hg_xray_dopc_time.dat" w]
set sel2 [atomselect top "name PO4"]
set nf [molinfo top get numframes]
for {set i 0} {$i < $nf} {incr i} {
	$sel2 frame $i
	set com2 [measure center $sel2]
	set dis [veclength [vecsub $com1 $com2]]
	set simdata($i.r) $dis
	puts $outfile "$i   $simdata($i.r)"
}
close $outfile

#Time trace of the distance to the lipid tails
#Calculate the center of mass (com1) using VMD, the selection will depend for each crystallographic ligand
set com1 {10.33353328704834 -54.3484992980957 4.4825334548950195}
set outfile [open "dist_lt_xray_dopc_time.dat" w]
set sel2 [atomselect top "resname DOPC and not name PO4 NC3 GL1 GL2"]
set nf [molinfo top get numframes]
for {set i 0} {$i < $nf} {incr i} {
	$sel2 frame $i
	set com2 [measure center $sel2]
	set dis [veclength [vecsub $com1 $com2]]
	set simdata($i.r) $dis
	puts $outfile "$i   $simdata($i.r)"
}
close $outfile
exit

