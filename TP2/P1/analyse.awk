#!/usr/bin/awk -f

###############################################################################
# Script AWK pour extraire :
#  - Débit moyen (flux 1 et flux 2)
#  - Taux de pertes (flux 1 et flux 2)
#  - RTT moyen (flux 1 et flux 2)
#
# Adapté à la structure de trace NS2 donnée :
#   - 0.11688 2 3 tcp 1040 ------- 1 0.0 3.0 3 8
#
# Hypothèses :
#   - $8 = fid (flow ID)
#   - $11 = numéro de séquence (seqnum) pour distinguer data/ACK
#   - event "-" = envoi, event "r" = réception
#   - proto = "tcp" (champ $5)
###############################################################################

BEGIN {
  # Inutile d'initialiser ces variables en tant que chaînes.
  # On peut simplement faire :
  delete departure_time_flow1
  delete departure_time_flow2
  
  # Vos compteurs habituels :
  flow1_bytes_received = 0
  # Compteurs flux 1
  flow1_bytes_received = 0
  flow1_pkts_sent     = 0
  flow1_pkts_recv     = 0
  flow1_ack_count     = 0
  flow1_rtt_sum       = 0

  # Compteurs flux 2
  flow2_bytes_received = 0
  flow2_pkts_sent     = 0
  flow2_pkts_recv     = 0
  flow2_ack_count     = 0
  flow2_rtt_sum       = 0


}

# On suppose que chaque ligne de trace est découpée ainsi :
# $1  = event       (-, r, d, ...)
# $2  = time        (timestamp)
# $3  = node        (ex: 2)
# $4  = level       (ex: 3) -> "niveau agent" ?
# $5  = proto       (ex: tcp)
# $6  = pktSize     (ex: 1040)
# $7  = flags       (ex: -------)
# $8  = fid         (flow id : 1 ou 2)
# $9  = src_ip      (ex: 0.0)
# $10 = dst_ip      (ex: 3.0)
# $11 = seqnum      (ex: 3)
# $12 = autre champ (ex: 8)
#
# On mappe ces champs dans des variables plus parlantes :
{
  event   = $1
  time    = $2
  node    = $3
  level   = $4
  proto   = $5
  pktSize = $6
  flags   = $7
  fid     = $8
  # $9 et $10 = src/dst IP ou ID
  # On suppose $11 = seqnum
  seqnum  = $11
}

###############################################################################
# (1) Comptage envois/réceptions pour calculer Débit et Taux de pertes
###############################################################################

# Paquet envoyé (event == "-")
(event == "-" && proto == "tcp" && fid == 1) {
  flow1_pkts_sent++
  # On enregistre l'heure d'envoi pour calculer RTT si c'est un segment Data
  departure_time_flow1[seqnum] = time
}
(event == "-" && proto == "tcp" && fid == 2) {
  flow2_pkts_sent++
  departure_time_flow2[seqnum] = time
}

# Paquet reçu (event == "r")
(event == "r" && proto == "tcp" && fid == 1) {
  flow1_pkts_recv++
  flow1_bytes_received += pktSize

  # On suppose que c'est (ou ça inclut) l'ACK correspondant
  # => calcul RTT (Data-ACK). 
  # Dans certains cas, on a besoin de vérifier s'il s'agit vraiment d'un ACK.
  # Mais ici, on simplifie : toute réception de flux 1 sur la source
  # ou ou sur un node "source" correspondrait à un ACK.
  send_time = departure_time_flow1[seqnum]
  if (send_time > 0) {
    rtt = time - send_time
    flow1_rtt_sum += rtt
    flow1_ack_count++
    # On remet à zéro pour éviter de recalculer sur le même seqnum
    departure_time_flow1[seqnum] = 0
  }
}
(event == "r" && proto == "tcp" && fid == 2) {
  flow2_pkts_recv++
  flow2_bytes_received += pktSize

  send_time = departure_time_flow2[seqnum]
  if (send_time > 0) {
    rtt = time - send_time
    flow2_rtt_sum += rtt
    flow2_ack_count++
    departure_time_flow2[seqnum] = 0
  }
}

###############################################################################
# (2) En cas de paquets droppés (si vous voulez compter le nombre de drops)
###############################################################################
#(event == "d" && proto == "tcp" && fid == 1) {
#  # Au besoin, on peut compter les drops pour affiner l'analyse
#}
#(event == "d" && proto == "tcp" && fid == 2) {
#}

###############################################################################
# (3) Fin d'analyse : on calcule débits, pertes, RTT
#    ATTENTION : adapter la durée du flux 1 et flux 2
###############################################################################
END {
  # Flux 1: start=0, stop=5 => durée=5
  # Flux 2: start=0, stop=10 => durée=10
  duree_flux1 = 5.0
  duree_flux2 = 10.0

  # Débit (Mbit/s)
  throughput1 = (flow1_bytes_received * 8) / duree_flux1 / 1e6
  throughput2 = (flow2_bytes_received * 8) / duree_flux2 / 1e6

  # Taux de pertes
  loss_rate1 = 0
  loss_rate2 = 0
  if (flow1_pkts_sent > 0) {
    loss_rate1 = (flow1_pkts_sent - flow1_pkts_recv) / flow1_pkts_sent
  }
  if (flow2_pkts_sent > 0) {
    loss_rate2 = (flow2_pkts_sent - flow2_pkts_recv) / flow2_pkts_sent
  }

  # RTT moyen (en secondes)
  mean_rtt1 = 0
  mean_rtt2 = 0
  if (flow1_ack_count > 0) {
    mean_rtt1 = flow1_rtt_sum / flow1_ack_count
  }
  if (flow2_ack_count > 0) {
    mean_rtt2 = flow2_rtt_sum / flow2_ack_count
  }

  # Affichage
  print "=== Résultats ==="
  printf "Débit moyen (flux 1) : %.3f Mbit/s\n", throughput1
  printf "Débit moyen (flux 2) : %.3f Mbit/s\n", throughput2
  printf "Taux de pertes (flux 1) : %.2f %%\n", loss_rate1*100
  printf "Taux de pertes (flux 2) : %.2f %%\n", loss_rate2*100
  printf "RTT moyen (flux 1) : %.6f s\n", mean_rtt1
  printf "RTT moyen (flux 2) : %.6f s\n", mean_rtt2
}
