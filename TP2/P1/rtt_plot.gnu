# rtt_plot.gnu
reset

# Le fichier de données
filename = "plot_rtt.txt"

# Sélection du terminal PNG et du nom du fichier de sortie
set terminal png
set output "rtt_flux.png"

# Titre et légendes
set title "Evolution du RTT"
set xlabel "Index de mesure"
set ylabel "RTT (s)"

# Première courbe : RTT flux 1 (colonne 2)
plot filename using 1:2 title "Flux 1" with lines ls 1

# Seconde courbe : RTT flux 2 (colonne 3)
replot filename using 1:3 title "Flux 2" with lines ls 2

# Fermer le fichier PNG (produit l'image)
set output
