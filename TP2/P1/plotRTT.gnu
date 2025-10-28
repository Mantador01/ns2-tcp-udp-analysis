# Choix du terminal (décommentez celui qui convient à votre environnement)
set terminal qt
#set terminal x11

# (Si vous préférez générer une image PNG, décommentez les lignes suivantes)
#set terminal pngcairo size 800,600
#set output 'rtt.png'

set title "RTT des flux 1 et 2"
set xlabel "Temps (s)"
set ylabel "RTT (ms)"
set grid

set key right top

# On force Gnuplot à s'adapter si la plage est trop faible
set autoscale

# Tracé des deux fichiers de données
plot "plot1.txt" using 1:2 with linespoints lt rgb "blue" title "Flux 1", \
     "plot2.txt" using 1:2 with linespoints lt rgb "red" title "Flux 2"

# Pour une fenêtre interactive, on peut ajouter un pause
pause -1 "Appuyez sur une touche pour quitter"
