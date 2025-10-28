#!/usr/bin/awk -f

BEGIN {
  # Compteurs pour savoir combien de RTT ont été relevés
  flow1_index = 0
  flow2_index = 0

  # On n'initialise PAS "departure_time_flow1" comme une chaine,
  # on veut un tableau associatif. Au besoin :
  delete departure_time_flow1
  delete departure_time_flow2
}

# Rappel du format (adaptez si besoin) :
# $1  = event   (-, r, d, ...)
# $2  = time    (timestamp)
# $5  = proto   (tcp, ack, etc.)
# $8  = fid     (flow id : 1 ou 2)
# $11 = seqnum  (numéro de séquence)
{
  event   = $1
  time    = $2
  proto   = $5
  fid     = $8
  seqnum  = $11
}

# À l’envoi d’un paquet du flux 1 ou 2, on enregistre l’heure d’envoi
(event == "-" && proto == "tcp" && fid == 1) {
  departure_time_flow1[seqnum] = time
}
(event == "-" && proto == "tcp" && fid == 2) {
  departure_time_flow2[seqnum] = time
}

# À la réception d’un paquet (souvent un ACK vu par la source),
# on calcule le RTT si on trouve l’heure d’envoi correspondante.
(event == "r" && proto == "tcp" && fid == 1) {
  send_time = departure_time_flow1[seqnum]
  if (send_time > 0) {
    rtt = time - send_time
    flow1_index++                       # on incrémente l'indice
    rtt_flow1[flow1_index] = rtt       # on stocke le RTT pour flux 1
    departure_time_flow1[seqnum] = 0    # réinitialiser
  }
}
(event == "r" && proto == "tcp" && fid == 2) {
  send_time = departure_time_flow2[seqnum]
  if (send_time > 0) {
    rtt = time - send_time
    flow2_index++
    rtt_flow2[flow2_index] = rtt
    departure_time_flow2[seqnum] = 0
  }
}

END {
  # On va écrire un entête puis imprimer sur chaque ligne :
  #    i   rtt_flux1[i]   rtt_flux2[i]
  # Mais attention : flux1 et flux2 n'ont pas forcément le même nombre de mesures.
  print "# index   rtt_flux1   rtt_flux2"

  # On prend l'indice le plus grand pour balayer toutes les mesures
  max_idx = (flow1_index > flow2_index ? flow1_index : flow2_index)

  for (i = 1; i <= max_idx; i++) {
    val1 = (i <= flow1_index) ? rtt_flow1[i] : 0.0
    val2 = (i <= flow2_index) ? rtt_flow2[i] : 0.0
    print i, val1, val2
  }
}
