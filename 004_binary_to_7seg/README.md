# Exercice 004 : Binary to 7-Segment (Affichage hexadécimal)

## Objectif

Implémenter un décodeur binaire 4 bits vers afficheur 7 segments pour afficher les chiffres hexadécimaux 0-F.

**Concepts abordés** :
- Afficheur 7 segments
- Décodage binaire → 7 segments
- Logique combinatoire complexe
- Tables de vérité étendues
- Représentation hexadécimale
- Logique négative (actif bas)

## Comportement attendu

Utilise 4 switches pour représenter un nombre binaire de 0 à 15 (0x0-0xF), et affiche le chiffre hexadécimal correspondant sur l'afficheur 7 segments.

- **Switches 1-4** : Code binaire 4 bits
  - Switch 1 = bit[0] (LSB - poids le plus faible)
  - Switch 2 = bit[1]
  - Switch 3 = bit[2]
  - Switch 4 = bit[3] (MSB - poids le plus fort)

- **Afficheur 7 segments** : Affiche le chiffre hexadécimal (0, 1, 2, ..., 9, A, b, C, d, E, F)

### Disposition des segments

```
    AAA
   F   B
    GGG
   E   C
    DDD
```

Chaque segment (A à G) peut être allumé ou éteint pour former un chiffre.

### Table de conversion hexadécimale

| Valeur | Hex | Affichage | Segments actifs     | Pattern (GFEDCBA) |
|--------|-----|-----------|---------------------|-------------------|
| 0      | 0x0 | `0`       | A,B,C,D,E,F         | `0111111`         |
| 1      | 0x1 | `1`       | B,C                 | `0000110`         |
| 2      | 0x2 | `2`       | A,B,D,E,G           | `1011011`         |
| 3      | 0x3 | `3`       | A,B,C,D,G           | `1001111`         |
| 4      | 0x4 | `4`       | B,C,F,G             | `1100110`         |
| 5      | 0x5 | `5`       | A,C,D,F,G           | `1101101`         |
| 6      | 0x6 | `6`       | A,C,D,E,F,G         | `1111101`         |
| 7      | 0x7 | `7`       | A,B,C               | `0000111`         |
| 8      | 0x8 | `8`       | A,B,C,D,E,F,G       | `1111111`         |
| 9      | 0x9 | `9`       | A,B,C,D,F,G         | `1101111`         |
| 10     | 0xA | `A`       | A,B,C,E,F,G         | `1110111`         |
| 11     | 0xB | `b`       | C,D,E,F,G           | `1111100`         |
| 12     | 0xC | `C`       | A,D,E,F             | `0111001`         |
| 13     | 0xD | `d`       | B,C,D,E,G           | `1011110`         |
| 14     | 0xE | `E`       | A,D,E,F,G           | `1111001`         |
| 15     | 0xF | `F`       | A,E,F,G             | `1110001`         |

## Architecture

```
   Go Board
   ┌─────────────────────────┐
   │  Switches               │
   │  ┌─┐┌─┐┌─┐┌─┐           │
   │  │1││2││3││4│ [3:0]     │  ──► Code binaire 4 bits
   │  └─┘└─┘└─┘└─┘           │
   │         ↓               │
   │  Décodeur 7-seg         │
   │  ┌─────────────────┐    │
   │  │  0x0 → '0'      │    │
   │  │  0x1 → '1'      │    │
   │  │  ...            │    │  ──► 16 combinaisons
   │  │  0xF → 'F'      │    │
   │  └────────┬────────┘    │
   │           ↓             │
   │    ┌──────────┐         │
   │    │  ░█░░█░  │         │  ──► Afficheur 7-seg
   │    │  █    █  │         │       (exemple: '8')
   │    │  ░█████  │         │
   │    │  █    █  │         │
   │    │  ░█████  │         │
   │    └──────────┘         │
   └─────────────────────────┘
```

## Instructions

### 1. Aller dans le répertoire de l'exercice

```bash
cd /path/to/nandland
```

### 2. Simuler (TDD)

```bash
make -C 004_binary_to_7seg sim
```

Vérifie que tous les tests (16 tests pour 0x0-0xF) passent.

### 3. Construire le bitstream

```bash
make -C 004_binary_to_7seg build
```

### 4. Programmer la Go Board

```bash
make -C 004_binary_to_7seg flash
```

### 5. Tester sur la board

Variez les 4 switches pour compter de 0 à 15 en binaire, et observez l'affichage hexadécimal :

| Switches (4321) | Binaire | Hex | Affichage |
|-----------------|---------|-----|-----------|
| `0000`          | 0000    | 0x0 | `0`       |
| `0001`          | 0001    | 0x1 | `1`       |
| `0010`          | 0010    | 0x2 | `2`       |
| ...             | ...     | ... | ...       |
| `1001`          | 1001    | 0x9 | `9`       |
| `1010`          | 1010    | 0xA | `A`       |
| `1011`          | 1011    | 0xB | `b`       |
| `1100`          | 1100    | 0xC | `C`       |
| `1101`          | 1101    | 0xD | `d`       |
| `1110`          | 1110    | 0xE | `E`       |
| `1111`          | 1111    | 0xF | `F`       |

**Expérience recommandée** : Comptez manuellement de 0 à 15 en binaire avec les switches et vérifiez que l'affichage correspond bien au chiffre hexadécimal attendu.

## Nettoyage

```bash
make -C 004_binary_to_7seg clean
```

## Notes techniques

- **Afficheur 7 segments** : Composé de 7 LEDs en forme de segments nommés A-G
- **Logique négative (active low)** : Sur la Go Board, les segments s'allument quand le signal est à 0
  - Dans le code, on génère la logique positive puis on inverse avec `~`
- **Case statement** : Idéal pour les décodeurs avec de nombreux cas
- **Représentation hexadécimale** :
  - Chiffres 0-9 : formes classiques
  - Lettres A-F : formes adaptées à 7 segments (minuscules pour b et d)
- **Pattern binaire** : `{G,F,E,D,C,B,A}` où 1 = segment allumé

## Défi supplémentaire

Une fois que vous maîtrisez cet exercice :

1. **Compter rapidement** : Actionnez rapidement les switches pour compter de 0 à 15
2. **Mémoriser** : Essayez de mémoriser quels segments sont actifs pour chaque chiffre
3. **Vérifier** : Comparez avec une calculatrice hexadécimale

## Applications réelles

- **Affichage de données** : Température, compteur, horloge
- **Debug hardware** : Visualiser l'état d'un bus de données
- **Calculatrices** : Affichage des résultats
- **Instruments de mesure** : Multimètres, fréquencemètres

## Prochaine étape

Exercice 005 : LED clignotante - Début du Niveau 2 (logique séquentielle avec horloge).

Vous passerez de la logique combinatoire pure (réponse instantanée) à la logique séquentielle (gestion du temps et de l'horloge).
