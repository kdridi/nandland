# Nandland Go Board - Exercices CLI

[![Test Exercises](https://github.com/kdridi/nandland/actions/workflows/test-exercises.yml/badge.svg?branch=main)](https://github.com/kdridi/nandland/actions/workflows/test-exercises.yml)

Exercices d'apprentissage FPGA pour la Go Board de Nandland, utilisant uniquement des outils en ligne de commande.

## Installation des outils (macOS ARM64)

### Installation rapide

```bash
# 1. Cloner le dépôt
git clone <url-du-depot>
cd nandland

# 2. Installer les outils FPGA (télécharge ~504 MB)
./install_tools.sh

# 3. Charger l'environnement
source ./env.sh
```

Les outils seront installés dans `./tools/` (exclu de Git).

### Utilisation des outils

Dans chaque session terminal, depuis la racine du projet :

```bash
source ./env.sh
```

Cela chargera automatiquement :
- **yosys** - Synthèse
- **nextpnr-ice40** - Place & Route
- **iceprog** - Programmation FPGA
- **icepack** - Génération bitstream
- Et bien d'autres outils

### Outils supplémentaires (optionnels)

Pour la simulation Verilog, installer via Homebrew :

```bash
brew install icarus-verilog  # Simulateur Verilog
brew install gtkwave         # Visualiseur de formes d'onde
```

### Notes

- Les outils sont installés localement dans `./tools/` (pas dans le home)
- Chaque projet peut avoir sa propre version des outils
- Le répertoire `tools/` est ignoré par Git (voir `.gitignore`)
- Pour Intel Mac, modifier l'URL dans `install_tools.sh`

## Organisation du projet

### Structure des fichiers

```
nandland/
├── tools/                    # Outils FPGA (installés localement, gitignore)
├── go_board.pcf              # Contraintes de broches officielles Nandland
├── common.mk                 # Makefile commun (chemins absolus des outils)
├── install_tools.sh          # Script d'installation des outils
├── .gitignore                # Ignore tools/ et */build/
├── CLAUDE.md                 # Documentation pour Claude Code
├── README.md                 # Ce fichier
└── XXX_nom_exercice/         # Chaque exercice
    ├── README.md             # Description de l'exercice (français)
    ├── nom_exercice.v        # Design Verilog
    ├── nom_exercice_tb.v     # Testbench (TDD)
    ├── Makefile              # 3 lignes : MODULE + include common.mk
    └── build/                # Fichiers générés (gitignore)
        ├── sim.out
        ├── *.vcd
        ├── *.json
        ├── *.asc
        └── *.bin             # Bitstream prêt pour flash
```

### Workflow de développement (TDD)

Depuis la **racine du projet**, pour chaque exercice :

```bash
# 1. Simulation (Test Driven Development)
make -C 000_switch_to_led sim

# 2. Build (synthèse + place & route + bitstream)
make -C 000_switch_to_led build

# 3. Flash sur la Go Board
make -C 000_switch_to_led flash

# 4. Nettoyage
make -C 000_switch_to_led clean
```

### Conventions

- **Documentation** : en français (README, commentaires)
- **Code** : en anglais (noms de variables, modules, signaux)
- **Nommage des signaux** : `i_` pour inputs, `o_` pour outputs, `r_` pour registres
- **Nommage PCF** : Suivre la convention Nandland (ex: `i_Switch_1`, `o_LED_1`)

## Liste des exercices

Cette progression de **25 exercices** couvre tous les aspects de la Go Board, du plus simple au plus avancé.

### 🟢 Niveau 1 : Logique combinatoire de base

- [x] **000_switch_to_led** - Connexion directe switches → LEDs
- [x] **001_logic_gates** - Portes logiques (AND, OR, XOR, NOT)
- [x] **002_multiplexer** - Multiplexeur 4→1
- [x] **003_decoder** - Décodeur binaire 2→4
- [x] **004_binary_to_7seg** - Affichage hexadécimal sur 7 segments

### 🟡 Niveau 2 : Logique séquentielle et horloge

- [ ] **005_blink_led** - LED clignotante (horloge 25 MHz)
- [ ] **006_binary_counter** - Compteur binaire 4 bits sur LEDs
- [ ] **007_button_debounce** - Anti-rebond pour boutons
- [ ] **008_counter_with_buttons** - Compteur up/down avec boutons
- [ ] **009_pwm_dimmer** - PWM pour variation d'intensité LED

### 🟠 Niveau 3 : Afficheurs et machines à états

- [ ] **010_decimal_counter_7seg** - Compteur décimal 0-9
- [ ] **011_two_digit_counter** - Compteur 0-99 avec multiplexage
- [ ] **012_stopwatch** - Chronomètre avec start/stop/reset
- [ ] **013_reaction_game** - Jeu de temps de réaction
- [ ] **014_traffic_light_fsm** - Feu tricolore (machine à états)

### 🔴 Niveau 4 : Communication série et VGA

- [ ] **015_uart_tx** - Transmission UART (avec LEDs d'activité)
- [ ] **016_uart_rx** - Réception UART
- [ ] **017_uart_echo** - Echo UART bidirectionnel
- [ ] **018_vga_color_bars** - Barres de couleurs VGA
- [ ] **019_vga_moving_square** - Carré mobile VGA

### 🟣 Niveau 5 : Projets avancés

- [ ] **020_pong_game** - Jeu Pong complet sur VGA
- [ ] **021_serial_terminal** - Terminal série avec commandes
- [ ] **022_snake_game** - Snake sur VGA avec score
- [ ] **023_spi_master** - Communication SPI sur PMOD
- [ ] **024_memory_game** - Jeu de mémoire (Simon)
- [ ] **025_simple_cpu** - Processeur simple 8 bits avec ALU

### Progression : 5/25 exercices terminés (20%)

### Concepts couverts

✅ Logique combinatoire et séquentielle
✅ Gestion d'horloge et diviseurs de fréquence
✅ Machines à états finis (FSM)
✅ Anti-rebond et synchronisation
✅ PWM et modulation
✅ Afficheurs 7 segments et multiplexage
✅ Communication UART (série)
✅ Génération vidéo VGA
✅ Communication SPI
✅ Détection de collision
✅ Architecture processeur basique

## Ressources

- **Documentation officielle** : [nandland.com](https://nandland.com)
- **Go Board pinout** : Voir `go_board.pcf`
- **Outils open-source** : [YosysHQ](https://github.com/YosysHQ)

Voir `CLAUDE.md` pour plus de détails sur le workflow de développement.