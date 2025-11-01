# Exercice 008 : Compteur sur Afficheur 7 Segments

## 🎯 Objectif

Créer un compteur décimal (0-9) qui s'affiche sur un afficheur 7 segments de la Go Board.

## 📚 Concepts

- **Compteur décimal** : Comptage 0-9 avec wrap-around
- **Décodeur 7 segments** : Réutilisation de l'exercice 004
- **Composition de modules** : Compteur + décodeur

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz

### Sorties
- `o_Segment1_A` à `o_Segment1_G` : Segments de l'afficheur 1

### Comportement

Le compteur doit :
1. Incrémenter toutes les 0.5 secondes
2. Compter de 0 à 9
3. Revenir à 0 après 9 (wrap décimal, pas binaire)
4. Afficher le chiffre courant sur l'afficheur 7 segments

### Séquence d'affichage

```
Temps  | Valeur | Afficheur
-------|--------|----------
0.0s   |   0    |    0
0.5s   |   1    |    1
1.0s   |   2    |    2
...
4.0s   |   8    |    8
4.5s   |   9    |    9
5.0s   |   0    |    0  (wrap)
```

## 💡 Implémentation

### Architecture

Le design combine deux blocs :

1. **Compteur décimal** : Compte 0-9 avec wrap
2. **Décodeur 7 segments** : Convertit 4-bit → 7 segments

```verilog
// Compteur décimal
always @(posedge i_Clk) begin
    if (r_Enable) begin
        if (r_Counter == 9)
            r_Counter <= 0;  // Wrap à 0 après 9
        else
            r_Counter <= r_Counter + 1;
    end
end

// Décodeur (réutilisé de l'exercice 004)
case (r_Counter)
    4'd0: segments = 7'b0111111;  // 0
    4'd1: segments = 7'b0000110;  // 1
    ...
    4'd9: segments = 7'b1101111;  // 9
    default: segments = 7'b0000000;
endcase
```

### Diviseur de fréquence

Identique aux exercices précédents :
- Génère `r_Enable` toutes les 0.5s
- HALF_SECOND = 12 500 000 cycles

## 🧪 Tests

Le testbench vérifie :
1. ✅ Compteur incrémente de 0 à 9
2. ✅ Wrap 9 → 0
3. ✅ Timing correct (0.5s par incrément)
4. ✅ Segments corrects pour chaque chiffre
5. ✅ Continuité après wrap

## 📊 Ressources utilisées

- **Registres** : ~29 (diviseur 24-bit + compteur 4-bit + enable)
- **LUTs** : ~70 (comparateur + additionneur + décodeur 7 segments)
- **Fréquence max** : 25 MHz

## 🎓 Points d'apprentissage

1. **Wrap décimal** : Différent du wrap binaire (9→0 vs 15→0)
2. **Composition** : Réutilisation de modules existants
3. **Affichage visuel** : Feedback humain sur 7 segments
4. **Modularité** : Compteur et décodeur séparables
