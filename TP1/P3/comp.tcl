# Création du simulateur
set ns [new Simulator]

# Couleurs pour NAM
$ns color 1 green
$ns color 2 red

# Fichiers de traces
set tracefile [open out.tr w]
set namfile [open out.nam w]
$ns trace-all $tracefile
$ns namtrace-all $namfile

# Procédure pour terminer la simulation
proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam out.nam &
    exit 0
}

# Création des nœuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Configuration des liens
$ns duplex-link $n0 $n2 1Mb 10ms DropTail
$ns duplex-link $n1 $n2 1Mb 10ms DropTail
$ns duplex-link $n2 $n3 500Kb 20ms DropTail

# Limite de la file d’attente entre n2 et n3
# $ns queue-limit $n2 $n3 10
$ns queue-limit $n2 $n3 100


# Positionnement de la file dans NAM
$ns duplex-link-op $n2 $n3 queuePos 0.5

# Création du trafic UDP
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp

set null [new Agent/Null]
$ns attach-agent $n3 $null

$ns connect $udp $null

# Source CBR pour le trafic UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packetSize_ 1000
$cbr set rate_ 1Mb

# Activation des flux UDP
$ns at 0.5 "$cbr start"
$ns at 4.5 "$cbr stop"

# Création du trafic TCP
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n3 $tcpsink

$ns connect $tcp $tcpsink

# Source FTP pour le trafic TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Activation des flux TCP
$ns at 2.0 "$ftp start"
$ns at 4.0 "$ftp stop"

# Démarrage de la simulation
$ns at 5.0 "finish"
$ns run