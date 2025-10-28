#!/usr/bin/awk -f
BEGIN {
    # Intervalle d'observation (par défaut [0,5] sec) et taille du paquet en octets
    interval   = 5;
    packetSize = 1040;

    # Initialisation du débit : on retiendra le temps de réception du dernier paquet et son numéro de séquence
    flux1_lastTime = 0;  
    flux1_lastSeq  = 0;
    flux2_lastTime = 0;
    flux2_lastSeq  = 0;

    # Comptage pour le taux de pertes (en fonction des paquets envoyés, reçus et des paquets drop)
    flux1_sent = 0;
    flux1_recv = 0;
    flux1_drop = 0;
    flux2_sent = 0;
    flux2_recv = 0;
    flux2_drop = 0;

    # Initialisation pour le calcul du RTT moyen
    total_RTT_flux1 = 0; nb_RTT_flux1 = 0;
    total_RTT_flux2 = 0; nb_RTT_flux2 = 0;

    # Tableaux pour stocker l'heure d'envoi des paquets (clé : numéro de séquence)
    # Pour flux1 et flux2
}

#/* --- Pour le Flux 1 --- */
# Envoi : événement '+' avec protocole tcp, champ 8 = "1",
# et champs 9/10 == "0.0"/"3.0" ET $4 == "3"
$1 == "+" && $2 <= interval && $5 == "tcp" && $8 == "1" && $9 == "0.0" && $10 == "3.0" {
    flux1_sent++;
    seq = $11;
    if (!(seq in sendTime_flux1))
        sendTime_flux1[seq] = $2;
}

# Réception (données) : événement 'r' avec protocole tcp et mêmes conditions
$1 == "r" && $2 <= interval && $5 == "tcp" && $8 == "1" && $9 == "0.0" && $10 == "3.0" && $4 == "3" {
    flux1_recv++;
    flux1_lastTime = $2;
    flux1_lastSeq  = $11;
}

# Gestion du drop : événement 'd' avec les mêmes conditions pour Flux 1
$1 == "d" && $2 <= interval && $5 == "tcp" && $8 == "1" && $9 == "0.0" && $10 == "3.0" && $4 == "3" {
    flux1_drop++;
}

# ACK pour flux 1 : événement 'r' avec protocole ack, avec inversion des champs 9 et 10 (donc 9 = "3.0", 10 = "0.0")
$1 == "r" && $2 <= interval && $5 == "ack" && $8 == "1" && $9 == "3.0" && $10 == "0.0" {
    seq = $11;
    if (seq in sendTime_flux1) {
        rtt = $2 - sendTime_flux1[seq];
        total_RTT_flux1 += rtt;
        nb_RTT_flux1++;
        delete sendTime_flux1[seq];
    }
}

#/* --- Pour le Flux 2 --- */
# Envoi : événement '+' avec protocole tcp, champ 8 = "2",
# et champs 9/10 == "1.0"/"4.0"
$1 == "+" && $2 <= interval && $5 == "tcp" && $8 == "2" && $9 == "1.0" && $10 == "4.0" && $4 == "3"{
    flux2_sent++;
    seq = $11;
    if (!(seq in sendTime_flux2))
        sendTime_flux2[seq] = $2;
}

# Réception (données) : événement 'r' avec protocole tcp et mêmes conditions
$1 == "r" && $2 <= interval && $5 == "tcp" && $8 == "2" && $9 == "1.0" && $10 == "4.0" && $4 == "3"{
    flux2_recv++;
    flux2_lastTime = $2;
    flux2_lastSeq  = $11;
}

# Gestion du drop : événement 'd' avec les mêmes conditions pour Flux 2
$1 == "d" && $2 <= interval && $5 == "tcp" && $8 == "2" && $9 == "1.0" && $10 == "4.0" && $4 == "3"{
    flux2_drop++;
}

# ACK pour flux 2 : événement 'r' avec protocole ack, avec inversion des champs 9 et 10 (9 = "4.0", 10 = "1.0")
$1 == "r" && $2 <= interval && $5 == "ack" && $8 == "2" && $9 == "4.0" && $10 == "1.0" {
    seq = $11;
    if (seq in sendTime_flux2) {
        rtt = $2 - sendTime_flux2[seq];
        total_RTT_flux2 += rtt;
        nb_RTT_flux2++;
        delete sendTime_flux2[seq];
    }
}

END {
    # --- Calcul du débit moyen ---
    if (flux1_lastTime > 0)
        flux1_throughput = flux1_lastSeq * packetSize * 8 / (flux1_lastTime * 1e6);
    else
        flux1_throughput = 0;
    
    if (flux2_lastTime > 0)
        flux2_throughput = flux2_lastSeq * packetSize * 8 / (flux2_lastTime * 1e6);
    else
        flux2_throughput = 0;
    
    print "Débit moyen (Flux 1):", flux1_throughput, "Mbps";
    print "Débit moyen (Flux 2):", flux2_throughput, "Mbps";
    
    # --- Calcul du taux de pertes ---
    # On considère ici que le total des paquets "concernés" est (reçus + drop)
    # Le taux de pertes correspond donc au pourcentage de paquets drop sur ce total.
    if ((flux1_recv + flux1_drop) > 0)
        loss_rate_flux1 = flux1_drop / (flux1_recv + flux1_drop) * 100;
    else
        loss_rate_flux1 = 0;
    
    if ((flux2_recv + flux2_drop) > 0)
        loss_rate_flux2 = flux2_drop / (flux2_recv + flux2_drop) * 100;
    else
        loss_rate_flux2 = 0;
    
    print "Taux de pertes (Flux 1):", loss_rate_flux1, "%";
    print "Taux de pertes (Flux 2):", loss_rate_flux2, "%";
    
    # --- Calcul du RTT moyen ---
    if (nb_RTT_flux1 > 0)
        avg_RTT_flux1 = total_RTT_flux1 / nb_RTT_flux1;
    else
        avg_RTT_flux1 = 0;
    
    if (nb_RTT_flux2 > 0)
        avg_RTT_flux2 = total_RTT_flux2 / nb_RTT_flux2;
    else
        avg_RTT_flux2 = 0;
    
    print "RTT moyen (Flux 1):", avg_RTT_flux1, "sec";
    print "RTT moyen (Flux 2):", avg_RTT_flux2, "sec";

    print flux1_recv;


}
