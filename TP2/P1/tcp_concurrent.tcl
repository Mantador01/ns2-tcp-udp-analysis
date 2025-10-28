# instantiation du simulateur
set ns [new Simulator]

# associer les couleurs pour NAM
$ns color 1 blue
$ns color 2 orange

# fichiers de traces
set file1 [open out.tr w]
$ns trace-all $file1
set file2 [open out.nam w]
$ns namtrace-all $file2

# procÃ©dure pour NAM
proc finish {} {
    global ns file1 file2
    $ns flush-trace
    close $file1
    close $file2
    exec nam out.nam &
    exit 0
}

# CrÃ©ation des noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

# Connexions entre les noeuds
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 1Mb 10ms DropTail
$ns duplex-link $n3 $n4 1Mb 50ms DropTail

# Configuration des buffers pour le lien entre n2 et n3
$ns queue-limit $n2 $n3 10

# Configuration du flux 1
set tcp1 [new Agent/TCP]
$tcp1 set fid_ 1
$ns attach-agent $n0 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n3 $sink1
$ns connect $tcp1 $sink1

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

# Flux 1 : Start Ã  t=0, Stop Ã  t=5
$ns at 0.0 "$ftp1 start"
$ns at 5.0 "$ftp1 stop"

# Configuration du flux 2
set tcp2 [new Agent/TCP]
$tcp2 set fid_ 2
$ns attach-agent $n1 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n4 $sink2
$ns connect $tcp2 $sink2

set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

# Flux 2 : Start Ã  t=0, Stop Ã  t=10
$ns at 0.0 "$ftp2 start"
$ns at 10.0 "$ftp2 stop"

# DurÃ©e totale de la simulation
$ns at 10.0 "finish"

# Lancer la simulation
$ns run
