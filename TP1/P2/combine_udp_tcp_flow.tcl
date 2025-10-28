# Création du simulateur
set ns [new Simulator]

# Fichiers de trace
set file1 [open out.tr w]
$ns trace-all $file1

set file2 [open out.nam w]
$ns namtrace-all $file2

# Procédure pour terminer la simulation
proc finish {} {
    global ns file1 file2
    $ns flush-trace
    close $file1
    close $file2
    exec nam out.nam &
    exit 0
}

# Création des noeuds
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Création des liens full-duplex
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.5Mb 20ms DropTail

# Déclaration du flux TCP (FTP)
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp

set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink

$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Déclaration du flux UDP (CBR)
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp

set null [new Agent/Null]
$ns attach-agent $n3 $null

$ns connect $udp $null

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1000      ;# Taille des paquets en octets
$cbr set rate_ 1Mb             ;# Débit

$cbr attach-agent $udp

# Configuration des temps d'activité
$ns at 1.0 "$cbr start"         ;# Démarrage du flux UDP à t=1 s
$ns at 5.0 "$cbr stop"          ;# Arrêt du flux UDP à t=5 s

$ns at 2.0 "$ftp start"         ;# Démarrage du flux TCP à t=2 s
$ns at 4.0 "$ftp stop"          ;# Arrêt du flux TCP à t=4 s

# Fin de la simulation
$ns at 6.0 "finish"

# Exécution
$ns run