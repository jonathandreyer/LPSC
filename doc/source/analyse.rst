Analyse du design
=================

Utilisation des fréquences d'horloges
-------------------------------------

La fréquence maximum utilisable pour le générateur de Mandelbrot est donnée par Xilinx ISE lors du processus "Place & Route" lors de l'étape "Analyse Post-Place & Route Static Timing". Un ficher de rapport est généré. À la fin de celui-ci, on peut lire::

	Timing summary:
	---------------

	Timing errors: 1  Score: 161  (Setup/Max: 161, Hold: 0)

	Constraints cover 263172 paths, 0 nets, and 6130 connections

	Design statistics:
	   Minimum period:   9.017ns{1}   (Maximum frequency: 110.902MHz)

Ce rapport donne une fréquence maximum de 110.9MHz. Nous utiliserons la valeur entière qui lui est inférieure, c'est-à-dire 110MHz, avec succès.



Utilisation des ressources de la FPGA
-------------------------------------

Le fichier "top_summary.html" renseigne sur les ressources FPGA utilisée. Nous résumons ici les chiffres dignes d’intérêt:

+-------------------------+------+-----------+-------------+
| Slice Logic Utilization | Used | Available | Utilisation |
+=========================+======+===========+=============+
| Slice LUTs              | 417  | 27'288    | 1%          |
+-------------------------+------+-----------+-------------+
| Occupied Slices         | 175  | 6822      | 2%          |
+-------------------------+------+-----------+-------------+
| RAMB16BWERs             | 113  | 116       | 97          |
+-------------------------+------+-----------+-------------+ 
| DSP48A1s                | 3    | 58        | 5%          |
+-------------------------+------+-----------+-------------+


Ces chiffres montrent que la seule ressource limitante ici est la BRAM. Toute la BRAM utilisée l'est pour implémenter la "dual-port RAM". La logique combinatoire est encore disponible en grande quantité, puisque seulement 2% sont utilisés.

Seulement 3 DSP sont utilisés, car les DSP sont ici uniquement utilisés pour effectuer les multiplications dans le bloc de calcul d'une itération de Mandelbrot.