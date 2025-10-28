# instantiation du simulateur
set ns [new Simulator]
# associer les couleurs pour NAM
$ns color 1 green
$ns color 2 red
$ns color 3 blue

# instantiation du fichier de traces
set file1 [open out.tr w]
$ns trace-all $file1
# instantiation du fichier de traces pour NAM
set file2 [open out.nam w]
$ns namtrace-all $file2

# proc´edure pour lancer automatiquement le visualisateur NAM `a la fin de la simulation
proc finish {} {
global ns file1 file2
$ns flush-trace
close $file1
close $file2
exec nam out.nam &
exit 0
}

# instantiation de deux noeuds
set n0 [$ns node]
set n1 [$ns node]
# instantiation d’une ligne de communication full duplex entre les noeuds n0 et n1
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
# instantiation d’une connexion UDP
set udp [new Agent/UDP]
$ns attach-agent $n0 $udp
set null [new Agent/Null]
$ns attach-agent $n1 $null
$ns connect $udp $null
$udp set fid_ 1 # permet d’associer un identifiant a ce flux

# instantiation d’un trafic CBR compos´e de paquets de 1000 octets, g´en´er´es toutes les 5 ms
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp
$cbr0 set packetSize_ 1000
$cbr0 set interval_ 0.005
# sc´enario de d´ebut et de fin de g´en´eration des paquets par cbr0
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
# la simulation va durer 5 secondes de temps simul´e
$ns at 5.0 "finish"
# d´ebut de la simulation
$ns run
