Analyse du design
=================

Utilisation des fréquences d'horloges
-------------------------------------

La fréquence maximum utilisable pour le générateur de Mandelbrot est donnée par Xilinx ISE lors du processus "Place & Route" lors de l'étape "Analyse Post-Place & Route Static Timing". Un ficher de rapport est généré. A la fin de celui-ci, on peut lire::

	Timing summary:
	---------------

	Timing errors: 1  Score: 161  (Setup/Max: 161, Hold: 0)

	Constraints cover 263172 paths, 0 nets, and 6130 connections

	Design statistics:
	   Minimum period:   9.017ns{1}   (Maximum frequency: 110.902MHz)

Ce rapport donne une fréquence maximum de 110.9MHz. Nous utiliserons la valeur entière qui lui est inférieur, c'est à dire 110MHz, avec succès.



Utilisation des ressources de la FPGA
-------------------------------------

Le fichier "top_summary.html" renseigne sur le ressources FPGA utilisées. Nous résumons ici les chiffres dignes d’intérêt:

+------------------------+------+-----------+------------+
| Slice Logic Uilization | Used | Available | Uilisation |
+========================+======+===========+============+
| Slice LUTs             | 417  | 27'288    | 1%         |
+------------------------+------+-----------+------------+
| Occupied Slices        | 175  | 6822      | 2%         |
+------------------------+------+-----------+------------+
| RAMB16BWERs            | 113  | 116       | 97         |
+------------------------+------+-----------+------------+ 
| DSP48A1s               | 3    | 58        | 5%         |
+------------------------+------+-----------+------------+


Ces chiffres montrent que la seul ressource limitante ici est la BRAM. Toute la BRAM utilisé l'est pour implémenter la "dual-port RAM". La logique combinatoire est encore disponible en grande quantité, puisque seulement 2% est utilisé.

Seulement 3 DSP sont utilisé car les DSP sont ici uniquement utilisé pour effectuer les multiplication dans le bloc de calcul d'une itération de Mandelbrot.