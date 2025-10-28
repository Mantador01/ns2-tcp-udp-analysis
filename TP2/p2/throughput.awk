#!/usr/bin/awk -f

BEGIN {
  sum_bytes = 0
  duration  = 5.0     # Simulation stoppe à t=5
}

{
  event  = $1         # s / r / d ...
  time   = $2
  node   = $3         # _0_ / _1_ ...
  proto  = $7         # cbr ? AODV ? etc.
  size   = $8         # taille du paquet (ex: 1520)

  # On ne compte que les receptions (r)
  # sur le noeud destinataire (ici _1_)
  # et dont le trafic est 'cbr'
  if (event == "r" && node == "_1_" && proto == "cbr") {
    sum_bytes += size
  }
}

END {
  # Conversion en bits, division par la durée puis par 1e6 pour Mb/s
  throughput = (sum_bytes * 8) / (duration * 1e6)
  printf "Débit moyen (flux CBR) : %.3f Mbit/s\n", throughput
}
