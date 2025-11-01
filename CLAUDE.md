# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Vue d'ensemble du dépôt

Ce dépôt est un ensemble d'exercices d'apprentissage pour le développement FPGA avec la **Go Board de Nandland** (nandland.com). Chaque exercice est organisé dans un sous-répertoire numéroté et utilise **exclusivement des outils en ligne de commande (CLI)**.

**Carte cible** : Nandland Go Board (FPGA Lattice iCE40 HX1K)

**Outils** : IceStorm toolchain open-source (yosys, nextpnr, iceprog)

**Installation** : Les outils sont installés localement via `./install_tools.sh` dans le répertoire `./tools/` (exclu de Git). Pour charger l'environnement : `source ./env.sh`

## Structure du dépôt

Chaque exercice est dans un répertoire numéroté avec le format :
```
000_nom_exercice/
001_autre_exercice/
002_encore_un_exercice/
...
```

### Structure typique d'un exercice

Chaque répertoire d'exercice contient généralement :

```
XXX_nom_exercice/
├── README.md              # Description de l'exercice (en français)
├── design.v              # Fichier Verilog principal
├── design_tb.v           # Testbench pour simulation
├── go_board.pcf          # Contraintes de broches pour la Go Board
└── Makefile              # Commandes de build/test/flash
```

## Commandes CLI pour le développement

### Prérequis

Avant de commencer, charger l'environnement des outils :
```bash
source ./env.sh
```

### Workflow complet pour un exercice

Dans chaque répertoire d'exercice :

```bash
# 1. Simulation avec iverilog
iverilog -o sim.out design.v design_tb.v
vvp sim.out
gtkwave waveform.vcd  # Visualisation optionnelle

# 2. Synthèse avec yosys
yosys -p "synth_ice40 -top module_name -json design.json" design.v

# 3. Place & Route avec nextpnr
nextpnr-ice40 --hx1k --package vq100 --json design.json --pcf go_board.pcf --asc design.asc

# 4. Génération du bitstream
icepack design.asc design.bin

# 5. Programmation de la Go Board
iceprog design.bin
```

### Utilisation typique avec Makefile

Si un Makefile est présent :

```bash
make sim      # Simulation
make build    # Synthèse + Place & Route + Bitstream
make flash    # Programmer la Go Board
make clean    # Nettoyer les fichiers générés
make all      # Simulation + Build + Flash
```

## Convention importante

**Langue**: Toute la documentation, les commentaires dans le code, et les messages doivent être écrits en français. Le code lui-même (noms de variables, fonctions, modules) doit rester en anglais pour maintenir la compatibilité avec les outils et les conventions standard de l'industrie.

### Exemple de style attendu

```verilog
// Module pour additionner deux nombres de 8 bits
// Entrée: i_data_a et i_data_b
// Sortie: o_sum
module adder_8bit (
    input  wire [7:0] i_data_a,    // Première valeur à additionner
    input  wire [7:0] i_data_b,    // Deuxième valeur à additionner
    output wire [7:0] o_sum        // Résultat de l'addition
);

    // Logique combinatoire pour l'addition
    assign o_sum = i_data_a + i_data_b;

endmodule
```

## Notes de développement

- Les modules HDL doivent être autonomes et bien commentés (en français)
- Chaque module de conception doit avoir un testbench correspondant
- **Toujours simuler avant de flasher** : vérifier la logique avec iverilog/gtkwave
- Utiliser des conventions de nommage cohérentes pour les signaux (ex: `i_` pour les entrées, `o_` pour les sorties, `r_` pour les registres)

## Ressources Go Board

### Broches communes de la Go Board

La Go Board dispose de :
- **4 LEDs** : LED1-LED4
- **4 boutons poussoirs** : BUTTON1-BUTTON4
- **4 commutateurs** : SWITCH1-SWITCH4
- **Horloge** : 25 MHz
- **Segments 7 segments** : 2 afficheurs
- **VGA** : Port VGA
- **PMOD** : Connecteur PMOD

Les numéros de broches exacts se trouvent dans les fichiers `.pcf` de chaque exercice.

## Philosophie d'apprentissage

Ce dépôt suit une approche progressive :
1. **Exercices simples** : Commencer par des designs combinatoires de base (LEDs, portes logiques)
2. **Logique séquentielle** : Ajouter des registres, compteurs, machines à états
3. **Projets avancés** : Interfaces (VGA, UART), processeurs simples
4. **CLI uniquement** : Maîtriser les outils en ligne de commande sans IDE graphique

Chaque exercice doit compiler, simuler et fonctionner sur la carte physique.
