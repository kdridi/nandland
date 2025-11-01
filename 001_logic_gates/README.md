# Exercice 001 : Logic Gates (Portes Logiques)

## Objectif

Implémenter et tester les portes logiques de base (AND, OR, XOR, NOT) en utilisant les switches et les LEDs.

**Concepts abordés** :
- Opérateurs logiques Verilog (`&`, `|`, `^`, `~`)
- Logique combinatoire
- Tables de vérité
- Assignations continues multiples

## Comportement attendu

Utilise les 2 premiers switches comme entrées (A et B), et les 4 LEDs comme sorties :

- **LED 1** : `A AND B` - Allumée seulement si les 2 switches sont ON
- **LED 2** : `A OR B` - Allumée si au moins 1 switch est ON
- **LED 3** : `A XOR B` - Allumée si exactement 1 switch est ON (différents)
- **LED 4** : `NOT A` - Allumée si Switch 1 est OFF (inverse)

### Tables de vérité

| Switch 1 (A) | Switch 2 (B) | LED 1 (AND) | LED 2 (OR) | LED 3 (XOR) | LED 4 (NOT A) |
|--------------|--------------|-------------|------------|-------------|---------------|
| 0            | 0            | 0           | 0          | 0           | 1             |
| 0            | 1            | 0           | 1          | 1           | 1             |
| 1            | 0            | 0           | 1          | 1           | 0             |
| 1            | 1            | 1           | 1          | 0           | 0             |

## Architecture

```
   Go Board
   ┌─────────────────┐
   │  Switches       │
   │  ┌─┐┌─┐         │
   │  │A││B│         │  ──► Entrées (Switch 1, Switch 2)
   │  └─┘└─┘         │
   │                 │
   │  Portes logiques│
   │  AND OR XOR NOT │  ──► Opérations
   │                 │
   │   ┌─┐┌─┐┌─┐┌─┐  │
   │   │●││●││●││●│  │  ──► LEDs (sorties)
   │   └─┘└─┘└─┘└─┘  │
   └─────────────────┘
```

## Instructions

### 1. Aller dans le répertoire de l'exercice

```bash
cd /path/to/nandland
```

### 2. Simuler (TDD)

```bash
make -C 001_logic_gates sim
```

Vérifie que tous les tests (16 tests : 4 combinaisons × 4 portes) passent.

### 3. Construire le bitstream

```bash
make -C 001_logic_gates build
```

### 4. Programmer la Go Board

```bash
make -C 001_logic_gates flash
```

### 5. Tester sur la board

| Action                    | LED 1 (AND) | LED 2 (OR) | LED 3 (XOR) | LED 4 (NOT) |
|---------------------------|-------------|------------|-------------|-------------|
| Tous switches OFF         | OFF         | OFF        | OFF         | **ON**      |
| Switch 1 ON, Switch 2 OFF | OFF         | **ON**     | **ON**      | OFF         |
| Switch 1 OFF, Switch 2 ON | OFF         | **ON**     | **ON**      | **ON**      |
| Tous switches ON          | **ON**      | **ON**     | OFF         | OFF         |

## Nettoyage

```bash
make -C 001_logic_gates clean
```

## Notes techniques

- **Logique combinatoire** : Pas d'horloge, réponse instantanée
- **Opérateurs** :
  - `&` : AND bit à bit
  - `|` : OR bit à bit
  - `^` : XOR bit à bit
  - `~` : NOT (inversion)
- **Switches 3 et 4** : Non utilisés dans cet exercice

## Prochaine étape

Exercice 002 : Implémenter un multiplexeur 4→1 avec sélection par switches.
