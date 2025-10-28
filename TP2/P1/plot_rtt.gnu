# Configuration de la sortie
set term png
set output 'rtt_plot.png'

# Ajouter des étiquettes pour les axes
set xlabel 'Time (s)'
set ylabel 'RTT (s)'

# Titre du graphique
set title 'Évolution du RTT pour Flux 1 et Flux 2'

# Tracer la première courbe pour le Flux 1 (colonne 2)
plot 'rtt_data.txt' using 1:2 title 'Flux 1' with lines ls 1

# Ajouter une seconde courbe pour le Flux 2 (colonne 3)
replot 'rtt_data.txt' using 1:3 title 'Flux 2' with lines ls 2

# Sauvegarder le graphe dans un fichier PNG
set term png
set output 'rtt_plot.png'
replot
