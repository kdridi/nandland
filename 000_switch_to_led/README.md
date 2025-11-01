# Exercice 000 : Switch to LED

## Objectif

Premier contact avec la Go Board ! Cet exercice connecte directement les 4 commutateurs (switches) aux 4 LEDs.

**Concepts abordés** :
- Structure d'un module Verilog
- Déclaration d'entrées/sorties
- Assignation continue (`assign`)
- Fichier de contraintes de broches (.pcf)
- Workflow de build et flash

## Comportement attendu

- Switch 1 en position haute → LED 1 allumée
- Switch 2 en position haute → LED 2 allumée
- Switch 3 en position haute → LED 3 allumée
- Switch 4 en position haute → LED 4 allumée

C'est une connexion directe, sans logique intermédiaire.

## Architecture

```
   Go Board
   ┌─────────────┐
   │  Switches   │
   │  ┌─┐┌─┐┌─┐┌─┐│
   │  │1││2││3││4││  ──► Entrées
   │  └─┘└─┘└─┘└─┘│
   │             │
   │   [Logic]   │  ──► Assignation directe
   │             │
   │   ┌─┐┌─┐┌─┐┌─┐│
   │   │●││●││●││●││  ──► LEDs (sorties)
   │   └─┘└─┘└─┘└─┘│
   └─────────────┘
```

## Instructions

### 1. Charger l'environnement

```bash
cd /path/to/nandland
source ./env.sh
```

### 2. Aller dans le répertoire de l'exercice

```bash
cd 000_switch_to_led
```

### 3. Simuler (TDD - Test Driven Development)

```bash
make sim
```

Vérifie que tous les tests passent avant de flasher la board.

### 4. Construire le bitstream

```bash
make build
```

Génère le fichier `.bin` prêt à être programmé.

### 5. Programmer la Go Board

Connecte la Go Board via USB, puis :

```bash
make flash
```

### 6. Tester sur la board

Actionne les 4 commutateurs et observe les LEDs correspondantes s'allumer/s'éteindre.

## Nettoyage

Pour supprimer les fichiers générés :

```bash
make clean
```

## Notes techniques

- **Logique combinatoire** : Pas d'horloge, réponse instantanée
- **Assignation continue** : `assign` crée une connexion permanente
- **Sans mémoire** : Pas de registres, pas d'état

## Prochaine étape

Exercice 001 : Implémenter des portes logiques (AND, OR, XOR) avec les switches et LEDs.
