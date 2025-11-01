# Exercice 009 : Compteur 2 Chiffres (00-99)

## 🎯 Objectif

Créer un compteur décimal de 00 à 99 affiché sur les deux afficheurs 7 segments de la Go Board.

## 📚 Concepts

- **Compteur 2 chiffres** : Comptage 0-99 avec wrap-around
- **Division décimale** : Extraction dizaines/unités
- **Double affichage** : Utilisation simultanée des 2 afficheurs
- **Composition** : Réutilisation du décodeur 7 segments

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz

### Sorties
- `o_Segment1_A` à `o_Segment1_G` : Chiffre des **unités** (droite)
- `o_Segment2_A` à `o_Segment2_G` : Chiffre des **dizaines** (gauche)

### Comportement

Le compteur doit :
1. Incrémenter toutes les 0.5 secondes
2. Compter de 00 à 99
3. Revenir à 00 après 99 (wrap)
4. Afficher les dizaines sur Segment2 (gauche)
5. Afficher les unités sur Segment1 (droite)

### Séquence d'affichage

```
Temps   | Valeur | Seg2 (dizaines) | Seg1 (unités)
--------|--------|-----------------|---------------
0.0s    |   00   |       0         |       0
0.5s    |   01   |       0         |       1
...
4.5s    |   09   |       0         |       9
5.0s    |   10   |       1         |       0
...
49.5s   |   99   |       9         |       9
50.0s   |   00   |       0         |       0  (wrap)
```

## 💡 Implémentation

### Architecture

```verilog
// Compteur 0-99
reg [6:0] r_Counter;  // 7 bits suffisent pour 99

always @(posedge i_Clk) begin
    if (r_Enable) begin
        if (r_Counter == 99)
            r_Counter <= 0;
        else
            r_Counter <= r_Counter + 1;
    end
end

// Extraction dizaines et unités
wire [3:0] w_Tens   = r_Counter / 10;  // Division
wire [3:0] w_Units  = r_Counter % 10;  // Modulo

// Deux décodeurs 7 segments
// - Un pour les dizaines (Segment2)
// - Un pour les unités (Segment1)
```

### Division et Modulo

La synthèse reconnaît les opérateurs `/` et `%` pour des valeurs constantes :
- `r_Counter / 10` → Dizaines (0-9)
- `r_Counter % 10` → Unités (0-9)

## 🧪 Tests

Le testbench vérifie :
1. ✅ Compteur incrémente de 00 à 99
2. ✅ Wrap 99 → 00
3. ✅ Dizaines correctes (0-9)
4. ✅ Unités correctes (0-9)
5. ✅ Segments corrects pour chaque chiffre
6. ✅ Valeurs clés : 09→10, 19→20, 98→99→00

## 📊 Ressources utilisées

- **Registres** : ~32 (diviseur 24-bit + compteur 7-bit + enable)
- **LUTs** : ~140 (comparateur + additionneur + 2 décodeurs 7 segments + division)
- **Fréquence max** : 25 MHz

## 🎓 Points d'apprentissage

1. **Compteur multi-chiffres** : Gestion 00-99 vs 0-9
2. **Division décimale** : Extraction dizaines/unités en hardware
3. **Multi-afficheurs** : Deux décodeurs indépendants
4. **Opérateurs arithmétiques** : `/` et `%` en Verilog
