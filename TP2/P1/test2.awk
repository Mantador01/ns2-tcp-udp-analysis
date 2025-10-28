BEGIN {
    # Initialisation des variables
    sent_time = 0
    rtt_sum = 0
    packet_count = 0
    count_sent = 0
}

# Lorsque nous rencontrons un paquet envoyé (+), on enregistre l'heure d'envoi
/^\+ / {
    packet_id = $12    # Le paquet est identifié par l'ID (par exemple, 1040)
    sent_time = $2    # L'heure d'envoi est dans la 2e colonne
    packets[packet_id] = sent_time   # Stocke l'heure d'envoi du paquet en utilisant l'ID du paquet comme clé
    count_sent++
}

# Lorsqu'un ACK est reçu (r ou -), on cherche si l'ID correspond à un paquet envoyé
/^\r / || /^\- / {
    received_time = $2   # L'heure de réception est dans la 2e colonne
    packet_id = $12       # L'ID du paquet (par exemple, 1040)

    # Si l'ID du paquet correspond à un paquet envoyé, on calcule le RTT
    if (packet_id in packets) {
        sent_time = packets[packet_id]  # Récupère l'heure d'envoi du paquet
        rtt = received_time - sent_time   # Calcul du RTT
        rtt_sum += rtt       # Ajoute le RTT à la somme
        packet_count++       # Incrémente le compteur de paquets reçus
        delete packets[packet_id]  # Supprime le paquet de la table après le calcul du RTT
    }
}

# À la fin de la lecture, on affiche le RTT moyen
END {
    if (packet_count > 0) {
        avg_rtt = rtt_sum / packet_count   # Calcul du RTT moyen
        print "RTT moyen : " avg_rtt " secondes"
    loss_rate = (1 - (packet_count / count_sent)) * 100
    print "Taux de perte : " loss_rate " %"
    } else {
        print "Aucun paquet reçu ou RTT non calculable."
    }
}