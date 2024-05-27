mol delete all
mol new dops_v.gro
mol addfile traj_dops_v.xtc waitfor all
set frame0 [atomselect top "name BB or name N or name SC1 or name SC2 or name SC3 or name SC4 or name SC5" frame 0]
set nf [molinfo top get numframes]
for {set x 1} {$x<$nf} {incr x} {
set sel [atomselect top "name BB or name N or name SC1 or name SC2 or name SC3 or name SC4 or name SC5" frame $x]
set all [atomselect top "all" frame $x]
$all move [measure fit $sel $frame0]
$sel delete
}
volmap density [atomselect top "resname DOPS and not name PO4 CNO"] -res 0.5 -allframes -combine avg -mol top -o volmap_density_all_dops_lt.dx
$frame0 writepdb prot_dops_frame0_lt.pdb
exit
