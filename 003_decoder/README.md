# Exercice 003 : Decoder (Décodeur binaire 2→4)

## Objectif

Implémenter un décodeur binaire 2→4 qui active une sortie parmi 4 selon un code binaire de 2 bits (inverse du multiplexeur).

**Concepts abordés** :
- Décodeur binaire (démultiplexeur)
- Comparaison binaire (`==`)
- One-hot encoding (une seule sortie active)
- Logique combinatoire avec comparateurs
- Relation multiplexeur ↔ décodeur

## Comportement attendu

Utilise 2 switches pour coder un nombre binaire de 0 à 3, et active la LED correspondante :

- **Switches 1-2** : Code binaire `code[1:0]`
  - Switch 1 = `code[0]` (bit de poids faible)
  - Switch 2 = `code[1]` (bit de poids fort)

- **Sorties LEDs** : Une seule LED allumée à la fois (one-hot)
  - **LED 1** : Active si `code = 00` (décimal 0)
  - **LED 2** : Active si `code = 01` (décimal 1)
  - **LED 3** : Active si `code = 10` (décimal 2)
  - **LED 4** : Active si `code = 11` (décimal 3)

### Table de vérité

| Switch 2 (code[1]) | Switch 1 (code[0]) | Code | Valeur | LED 1 | LED 2 | LED 3 | LED 4 | Pattern |
|--------------------|-----------------------|------|--------|-------|-------|-------|-------|---------|
| 0                  | 0                     | `00` | 0      | **1** | 0     | 0     | 0     | `0001`  |
| 0                  | 1                     | `01` | 1      | 0     | **1** | 0     | 0     | `0010`  |
| 1                  | 0                     | `10` | 2      | 0     | 0     | **1** | 0     | `0100`  |
| 1                  | 1                     | `11` | 3      | 0     | 0     | 0     | **1** | `1000`  |

## Architecture

```
   Go Board
   ┌─────────────────────┐
   │  Switches           │
   │  ┌─┐┌─┐             │
   │  │1││2│  code[1:0]  │  ──► Code binaire (2 bits)
   │  └─┘└─┘             │
   │         ↓           │
   │  Décodeur 2→4       │
   │  ┌───────────────┐  │
   │  │  00 → LED_1   │  │
   │  │  01 → LED_2   │  │  ──► Une seule sortie active
   │  │  10 → LED_3   │  │
   │  │  11 → LED_4   │  │
   │  └───────────────┘  │
   │                     │
   │   ┌─┐┌─┐┌─┐┌─┐      │
   │   │●││ ││ ││ │      │  ──► Une seule LED ON (exemple: code=00)
   │   └─┘└─┘└─┘└─┘      │
   └─────────────────────┘
```

## Différence Multiplexeur vs Décodeur

| Aspect          | Multiplexeur 4→1        | Décodeur 2→4            |
|-----------------|-------------------------|-------------------------|
| **Entrées**     | 4 données + 2 sélection | 2 code binaire          |
| **Sorties**     | 1 sortie                | 4 sorties               |
| **Fonction**    | Sélectionne UNE entrée  | Active UNE sortie       |
| **Direction**   | Plusieurs → Une         | Une → Plusieurs         |
| **Exemple**     | `data[sel] → out`       | `code → one_hot[code]`  |

Le décodeur est **l'inverse** du multiplexeur : il prend un code et le "décode" vers une sortie unique.

## Instructions

### 1. Aller dans le répertoire de l'exercice

```bash
cd /path/to/nandland
```

### 2. Simuler (TDD)

```bash
make -C 003_decoder sim
```

Vérifie que tous les tests (9 tests) passent :
- 4 tests de décodage de base
- 4 tests de validation (une seule LED active)
- 1 test de parcours complet

### 3. Construire le bitstream

```bash
make -C 003_decoder build
```

### 4. Programmer la Go Board

```bash
make -C 003_decoder flash
```

### 5. Tester sur la board

| Switches          | LED active | Observation                        |
|-------------------|------------|------------------------------------|
| Tous OFF (code=00)| **LED 1**  | Seule LED 1 allumée                |
| Sw1 ON (code=01)  | **LED 2**  | LED se déplace vers LED 2          |
| Sw2 ON (code=10)  | **LED 3**  | LED se déplace vers LED 3          |
| Tous ON (code=11) | **LED 4**  | LED se déplace vers LED 4          |

**Effet visuel attendu** : Quand vous variez les switches de 00 à 11, vous devriez voir **une seule LED se déplacer** de gauche à droite (LED 1 → 2 → 3 → 4).

## Nettoyage

```bash
make -C 003_decoder clean
```

## Notes techniques

- **Décodeur** : Convertit un code binaire en signal one-hot (une seule sortie active)
- **One-hot encoding** : Représentation où exactement un bit est à 1
- **Comparaison** : Utilise l'opérateur `==` pour comparer le code binaire
- **Applications** :
  - Sélection de mémoire (chip select)
  - Démultiplexage de signaux
  - Contrôle d'afficheurs (sélection de digit)
- **Logique simple** : `o_LED_1 = (w_Code == 2'b00)` génère un comparateur en hardware

## Exercices bonus

1. **Décodeur 3→8** : Utiliser 3 switches pour décoder 8 sorties (nécessite plus de LEDs ou utiliser les afficheurs 7 segments)
2. **Décodeur avec enable** : Ajouter un switch d'activation (toutes les LEDs OFF si enable=0)
3. **Décodeur BCD** : Décoder 4 bits en 10 sorties (0-9) pour affichage décimal

## Cas d'usage réels

- **Sélection de mémoire** : Activer une puce mémoire parmi plusieurs selon une adresse
- **Démultiplexage** : Router un signal vers une destination parmi plusieurs
- **Contrôle d'affichage** : Sélectionner quel digit afficher sur un afficheur multiplexé
- **Interface bus** : Décoder une adresse pour activer un périphérique

## Prochaine étape

Exercice 004 : Implémenter un afficheur hexadécimal sur 7 segments (décodeur 4→7).
