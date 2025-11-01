# Exercice 002 : Multiplexer (Multiplexeur 4→1)

## Objectif

Implémenter un multiplexeur 4→1 qui sélectionne une entrée parmi 4 selon un signal de sélection de 2 bits.

**Concepts abordés** :
- Multiplexeur (structure conditionnelle)
- Instruction `case` en Verilog
- Sélection binaire (2 bits → 4 choix)
- Logique combinatoire avec choix multiples
- Registres combinatoires (`always @(*)`)

## Comportement attendu

Utilise 2 switches pour sélectionner une entrée parmi 4 valeurs câblées (pattern `4'b1010`), et affiche le résultat sur les LEDs :

- **Switches 1-2** : Signal de sélection `sel[1:0]`
  - Switch 1 = `sel[0]` (bit de poids faible)
  - Switch 2 = `sel[1]` (bit de poids fort)

- **4 entrées câblées** : `data[3:0] = 4'b1010`
  - `data[0] = 0`
  - `data[1] = 1`
  - `data[2] = 0`
  - `data[3] = 1`

- **Sorties LEDs** :
  - **LED 1** : Sortie du multiplexeur (entrée sélectionnée)
  - **LED 2** : Écho de `sel[0]` (Switch 1)
  - **LED 3** : Écho de `sel[1]` (Switch 2)
  - **LED 4** : Inverse de la sortie (pour visualisation)

### Table de vérité

| Switch 2 (sel[1]) | Switch 1 (sel[0]) | Sélection | Entrée | LED 1 | LED 2 | LED 3 | LED 4 |
|-------------------|-------------------|-----------|--------|-------|-------|-------|-------|
| 0                 | 0                 | `2'b00`   | data[0]| 0     | 0     | 0     | 1     |
| 0                 | 1                 | `2'b01`   | data[1]| 1     | 1     | 0     | 0     |
| 1                 | 0                 | `2'b10`   | data[2]| 0     | 0     | 1     | 1     |
| 1                 | 1                 | `2'b11`   | data[3]| 1     | 1     | 1     | 0     |

## Architecture

```
   Go Board
   ┌─────────────────────┐
   │  Switches           │
   │  ┌─┐┌─┐             │
   │  │1││2│  sel[1:0]   │  ──► Sélecteur (2 bits)
   │  └─┘└─┘             │
   │                     │
   │  Multiplexeur 4→1   │
   │  ┌───────────────┐  │
   │  │ data[0] = 0   │  │
   │  │ data[1] = 1   │  │  ──► 4 entrées câblées
   │  │ data[2] = 0   │  │
   │  │ data[3] = 1   │  │
   │  └───────┬───────┘  │
   │          ↓          │
   │   ┌─┐┌─┐┌─┐┌─┐      │
   │   │●││●││●││●│      │  ──► LEDs (out, sel[0], sel[1], NOT)
   │   └─┘└─┘└─┘└─┘      │
   └─────────────────────┘
```

## Instructions

### 1. Aller dans le répertoire de l'exercice

```bash
cd /path/to/nandland
```

### 2. Simuler (TDD)

```bash
make -C 002_multiplexer sim
```

Vérifie que tous les tests (7 tests) passent :
- 4 tests des combinaisons du multiplexeur
- 2 tests de vérification des échos
- 1 test de l'inversion

### 3. Construire le bitstream

```bash
make -C 002_multiplexer build
```

### 4. Programmer la Go Board

```bash
make -C 002_multiplexer flash
```

### 5. Tester sur la board

| Switches          | LED 1 (sortie) | LED 2 (sel[0]) | LED 3 (sel[1]) | LED 4 (NOT) |
|-------------------|----------------|----------------|----------------|-------------|
| Tous OFF (sel=00) | OFF (data[0])  | OFF            | OFF            | **ON**      |
| Sw1 ON (sel=01)   | **ON** (data[1])| **ON**        | OFF            | OFF         |
| Sw2 ON (sel=10)   | OFF (data[2])  | OFF            | **ON**         | **ON**      |
| Tous ON (sel=11)  | **ON** (data[3])| **ON**        | **ON**         | OFF         |

**Pattern attendu** : Avec le pattern de données `1010`, vous devriez voir LED 1 suivre la séquence OFF-ON-OFF-ON quand vous passez de sel=00 à sel=11.

## Nettoyage

```bash
make -C 002_multiplexer clean
```

## Notes techniques

- **Multiplexeur** : Circuit qui sélectionne une entrée parmi plusieurs selon un signal de contrôle
- **Case statement** : Structure Verilog pour décrire des choix multiples (similaire au switch en C)
- **Always @(*)** : Bloc combinatoire sensible à tous les signaux d'entrée
- **Pattern de test** : `4'b1010` permet de vérifier facilement chaque sélection (alternance 0/1)
- **Sélecteur 2 bits** : Peut adresser 2² = 4 entrées différentes

## Exercices bonus

1. **Modifier le pattern** : Changer `4'b1010` en `4'b0110` et observer la différence
2. **Ajouter un 5e choix** : Ajouter une valeur par défaut dans le `default` du case
3. **Multiplexeur 8→1** : Utiliser 3 switches (3 bits) pour sélectionner parmi 8 entrées

## Prochaine étape

Exercice 003 : Implémenter un décodeur binaire 2→4 (inverse du multiplexeur).
