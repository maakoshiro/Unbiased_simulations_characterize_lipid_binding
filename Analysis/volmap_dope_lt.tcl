mol delete all
mol new dope_v.gro
mol addfile traj_dope_v.xtc waitfor all
set frame0 [atomselect top "name BB or name N or name SC1 or name SC2 or name SC3 or name SC4 or name SC5" frame 0]
set nf [molinfo top get numframes]
for {set x 1} {$x<$nf} {incr x} {
set sel [atomselect top "name BB or name N or name SC1 or name SC2 or name SC3 or name SC4 or name SC5" frame $x]
set all [atomselect top "all" frame $x]
$all move [measure fit $sel $frame0]
$sel delete
}
volmap density [atomselect top "resname DOPE and not name PO4 NH3"] -res 0.5 -allframes -combine avg -mol top -o volmap_density_all_dope_lt.dx
$frame0 writepdb prot_dope_frame0_lt.pdb
exit
