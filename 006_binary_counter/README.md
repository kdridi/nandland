# Exercice 006 : Compteur Binaire 4-bit

## 🎯 Objectif

Créer un compteur binaire 4-bit qui s'incrémente périodiquement et affiche sa valeur sur les 4 LEDs de la Go Board.

## 📚 Concepts

- **Compteur binaire** : Séquence 0000 → 1111 → 0000 (wrap-around)
- **Diviseur de fréquence** : Rendre le comptage visible à l'œil humain
- **Affichage LED** : Représentation binaire sur hardware

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz

### Sorties
- `o_LED_1` : Bit 0 (LSB) - LED la plus rapide
- `o_LED_2` : Bit 1
- `o_LED_3` : Bit 2
- `o_LED_4` : Bit 3 (MSB) - LED la plus lente

### Comportement

Le compteur doit :
1. Incrémenter toutes les 0.5 secondes (fréquence visible)
2. Afficher la valeur binaire sur les 4 LEDs
3. Compter de 0 (0000) à 15 (1111)
4. Revenir à 0 après 15 (wrap-around automatique)

### Exemples de séquence

```
Temps  | Valeur | LED_4 LED_3 LED_2 LED_1
-------|--------|------------------------
0.0s   |   0    |   0     0     0     0
0.5s   |   1    |   0     0     0     1
1.0s   |   2    |   0     0     1     0
1.5s   |   3    |   0     0     1     1
...
7.0s   |  14    |   1     1     1     0
7.5s   |  15    |   1     1     1     1
8.0s   |   0    |   0     0     0     0  (wrap)
```

### Calcul du diviseur

```
Fréquence horloge = 25 MHz = 25 000 000 Hz
Période souhaitée = 0.5s par incrément

Cycles pour 0.5s = 25 000 000 / 2 = 12 500 000 cycles
```

## 💡 Implémentation

### Diviseur de fréquence
```verilog
reg [23:0] r_Clk_Count;
reg r_Enable;

always @(posedge i_Clk) begin
    if (r_Clk_Count == 12_500_000 - 1) begin
        r_Clk_Count <= 0;
        r_Enable <= 1;
    end else begin
        r_Clk_Count <= r_Clk_Count + 1;
        r_Enable <= 0;
    end
end
```

### Compteur 4-bit
```verilog
reg [3:0] r_Counter;

always @(posedge i_Clk) begin
    if (r_Enable)
        r_Counter <= r_Counter + 1;  // Wrap automatique sur 4 bits
end
```

## 🧪 Tests

Le testbench vérifie :
1. ✅ Diviseur génère pulse toutes les N cycles
2. ✅ Compteur incrémente uniquement sur pulse
3. ✅ Compteur wrap de 15 → 0
4. ✅ Séquence complète 0-15

## 📊 Ressources utilisées

- **Registres** : ~29 (diviseur 24-bit + compteur 4-bit + enable)
- **LUTs** : ~55 (comparateur + additionneur + logique)
- **Fréquence max** : 25 MHz (pas de chemin critique)

## 🎓 Points d'apprentissage

1. **Compteur modulaire** : Wrap automatique avec largeur de registre
2. **Enable signal** : Contrôle d'incrémentation conditionnelle
3. **Réutilisation** : Diviseur similaire à l'exercice blink_led
4. **Observation visuelle** : Validation hardware par observation directe
