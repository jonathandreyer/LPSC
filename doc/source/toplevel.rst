Top-Level
=========

L'architecture principale de notre système peut être vue à la :numref:`fig_top_level`. 

.. _fig_top_level:
.. figure:: figures/top_level.png
	:scale: 50%

	Top-Level


Notre système s'articule autours d'une RAM à deux interface ("Dual port RAM"). Une interface est utilisée pour la lecture alors que la seconde est utilisée pour l'écriture. Les donnée de chaque pixel de la fractale sont stockée à l’intérieur de cette RAM. Du coté de l'interface de lecture, nous trouvons la logique qui permet de transférer les données de la RAM à l'interface DVI. Sur l'interface d'écriture se trouve la logique qui permet de générer les données de la fractale. Chaque bloc se trouvent détaillé ci-dessous.

Le système travaille sur deux horloge différentes. La dual-port RAM permet ceci elle utilise une fréquence d'horloge par port. La génération des données est cadencé à 110MHz. La partie DVI est cadencé par le bloc "*DVI control*" qui fournit un signal d'horloge à 125MHz.

Génération des données
----------------------

Du coté de la génération des données tout est orchestré par le bloc "*Mandelbrot ManageGenerator FSM*". Ce bloc est une machine d'état qui attend que le calcul de la valeur de Mandelbrot soit terminée, puis elle demande au Générateur de nombre complexe la valeurs suivante en mettant son entrée ``Start`` à 1 et finalement démarre le calcule de la valeur du pixel effectué par le bloc "*Mandelbrot calculator*" selon la nouvelle coordonnée complexe. Cette machine d'état peut être vue dans la :numref:`ManageGenerator_FSM`. 

.. _ManageGenerator_FSM:
.. figure:: figures/Mandelbrot_Manage_FSM.png

	Mandelbrot ManageGenerator FSM	


Le bloc "*Complex Value Generator*" génère une nouvelle coordonnée complexe ainsi que les coordonnée X et Y correspondante à chaque fois que son signal d'entrée ``Start`` est mis à 1. La coordonnée complexe est générer dans un plan complexe allant de -2-i à 1+i, incrémenté de 3/512 dans le sens des réels et de 2/512 dans la direction complexe. La coordonnée complexe est donnée décomposée une valeur réel et une valeur imaginaire sur deux signaux, ``C_re`` et ``C_im``. Ces nombres son représenté en valeur à virgule fixe de 16 bits avec la partie entière sur 4 bits. Ce format à été choisi car il permet de mettre la valeur la plus extrême, soit 2, au carré sans débordement ni perte de bit de signe. En effet :math:`2^2=< 2^{4-1}`. 1 LSB vaut 1/4096 (env 0.000244). Pour chaque coordonnée complexe générée, une coordonnée X et Y est générée, avec le point X,Y=0,0 équivalent à la coordonnée complexe -2+i, soit le coins supérieur gauche de l'image. L'incrément en X et Y est de 1. Y est incrémenté quand X atteins 512. Ces coordonnée sont  celle du pixel sur l’écran correspondant à la coordonnée complexe.

Chaque coordonnée complexe est reçu par le bloc "*Mandelbrot Calculator*". Ce bloc calcule la valeur de mandelbrot en fonction de la coordonnée complexe. Ce bloc intègre une petit machine d'état qui démarre l’itération de la valeur de calcule. lorsque le signal ``Start`` est mis à 1. Cette machine d'état arête l’itération lorsque la valeur à Zi à divergé (>2) ou lorsque le nombre d’itération maximum est atteint. Lorsque l'un de ces 2 conditions est remplie, la sortie ``Finished`` passe à 1. La sortie ``iteration`` représente le nombre d’itérations et évolue au cours du temps. Elle est remise à zéro lorsque ``Start`` est actif.

Le schéma interne de ce bloc peut être vue dans la :numref:`mandelbrot_calculator`. 

.. _mandelbrot_calculator:
.. figure:: figures/mandelbrot_calculator.png
	:scale: 50%

	Mandelbrot calculator 

Ce bloc est composé de trois parties:

 - Le bloc "*MandelBrotComplexCalculator*" calcule une iteration du calcule de mandelbrot. Ce bloc est détaillé dans le chapitre ":ref:`calc_mandelbrot`".
 - Le bloc "*Mandelbrot FS: M*" est une machine d'état qui supervise le calcul.
 - Un simple compteur sur 7 bits.

La machine d'état "*Mandelbrot FSM*" est dessinée à la :numref:`mandelbrot_fsm`. 

.. _mandelbrot_fsm:
.. figure:: figures/Mandelbrot_FSM.png
	:scale: 80%

	Machine d'état pour le calcul de Mandelbrot 

Elle comporte 4 état:

:Wait: Attend le signal de démarrage de la machine d'état "*Mandelbrot ManageGenerator FSM*"
:Load: Charge les donnée initial dans le bloc de calcul et remise à zero du compteur
:Calculate: Itération de mandelbrot par le bloc de calcul.
:Finished: Fin du calcul. Soit par divergence signalée par le bloc de calcul, soit par nombre d’itération maximum atteins.

Le bloc "*XYtoAddress*" se charge de convertir les coordonnée Y et X en adresse pour la RAM.  Cela se fait simplement en concaténant la coordonnée Y et X.

Finalement, la sorte du bloc "*Mandelbrot Calculator*" et "*XYtoAddress*" sont utilisé pour piloter la RAM. L'adresse est donnée par le bloc "*XYtoAddress*", la donnée par la sorite ``iteration`` du bloc "*Mandelbrot Calculator*", et le signal "Write enable" qui permet d'activer l'écriture en RAM est piloté par le signal ``Finished`` fournis par le bloc "*Mandelbrot Calculator*".

Lecture des données
-------------------

L'autre interface de la RAM est utilisé pour lire les données. La lecture est orchestrée par le bloc "*DVI Ctrl*". Ce bloc était fournis au debut du projet. Ce bloc pilote l'interface DVI et fournis une horloge à 125MHz. A chaque coup d'horloge, le bloc fournit une coornonée X et Y. La logique connectée doit fournir en retour une valeur de couleur au format RGB, soit une intensité de rouge, vert et bleu. Trois signaux sont à disposition à cet effet.

Le coordonnée en X et Y sont passé au travers d'un bloc "*limiter*" qui se charge de limiter l'amplitude à la taille de l'image généré. La RAM ne permettant de stocker qu'une image de 512 pixel par 512 pixel, l'image est mise à l'échelle. A chaque coordonnée X et Y fournie par le bloc "DVI Ctrl" correspond 4 pixel de l'image générer. Cela est simplement fait en décalant les coordonnée X et Y vers la droite, supprimant le bit de pois faible.

Le bloc "*YX to Ram*" est identique à celui utilisé pour la génération. Cela permet de s'assurer de la consistance des données. La sortie de ce bloc permet de piloter l'adresse de la RAM.

Le signal "Read enable" qui permet d'activer la lecture est mis de manière permanente à 1. Ce circuit est temporisé par l'horloge à 125Mhz fournie par le bloc "*DVI Ctrl*". A chaque coup d'horloge une nouvelle donnée est donc lue.

Les données lues sont passé dans un bloc qui convertis le nombre d’itération (valeur entre 1 et 100) stocké dans la RAM en niveau de gris. Cela est fait en décalant vers la gauche la valeur cette valeurs, puis en répliquant cette valeur pour les canaux rouge, vert et bleu.


