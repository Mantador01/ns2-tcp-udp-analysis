#!/usr/bin/awk -f
# Script pour calculer le taux de perte de paquets UDP

BEGIN {
    # Initialisation des variables
    pkt_send = 0;  # Nombre de paquets envoyés
    pkt_recv = 0;  # Nombre de paquets reçus
    loss = 0;      # Nombre de paquets perdus
    t1 = ARGV[1];  # Temps de début (fourni en argument)
    t2 = ARGV[2];  # Temps de fin (fourni en argument)
    ARGV[1] = "";  # Supprimer t1 de la liste des arguments
    ARGV[2] = "";  # Supprimer t2 de la liste des arguments
}

{
    # Extraction des champs
    event = $1;      # Événement (+, -, r, d)
    time = $2;       # Temps de l'événement (en secondes)
    type = $5;       # Type de paquet (cbr, tcp, etc.)
    idseq = $11;     # Numéro de séquence

    # Filtrer les événements UDP entre t1 et t2
    if (type == "cbr" && time >= t1 && time <= t2) {
        if (event == "+") {
            pkt_send++;  # Paquet envoyé
        }
        else if (event == "r") {
            pkt_recv++;  # Paquet reçu
        }
        else if (event == "d") {
            loss++;      # Paquet perdu
        }
    }
}

END {
    # Calcul du taux de perte
    total_loss = pkt_send - pkt_recv;
    loss_rate = (total_loss / pkt_send) * 100;

    # Afficher les résultats
    printf("Intervalle: [%s, %s]\n", t1, t2);
    printf("Paquets envoyés: %d\n", pkt_send);
    printf("Paquets reçus: %d\n", pkt_recv);
    printf("Paquets perdus: %d\n", total_loss);
    printf("Taux de perte: %.2f%%\n", loss_rate);
}
