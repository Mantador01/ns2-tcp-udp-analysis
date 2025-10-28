BEGIN {
    # Initialisation des structures
    delete send_times;  # Assurez-vous que `send_times` est initialisé comme un tableau associatif
    delays_sum = 0;     # Somme des délais
    count = 0;          # Compteur de paquets reçus
}

# Enregistrer les instants d'envoi des paquets (événements "+")
$1 == "+" && $5 == "cbr" && $2 < t2 {
    send_times[$11] = $2;  # Associer numéro de séquence ($11) au temps d'envoi ($2)
}

# Calculer le délai des paquets reçus (événements "r")
$1 == "r" && $5 == "cbr" && $2 >= t1 {
    seq_id = $11;
    if (seq_id in send_times) {
        delay = $2 - send_times[seq_id];
        delays_sum += delay;
        count++;
    }
}

END {
    # Calculer et afficher le délai moyen
    if (count > 0) {
        avg_delay = delays_sum / count;
        printf("Période [%g, %g] :\n", t1, t2);
        printf("  Paquets reçus   : %d\n", count);
        printf("  Délai moyen     : %.6f s\n", avg_delay);
    } else {
        printf("Période [%g, %g] : Aucun paquet reçu.\n", t1, t2);
    }
}
