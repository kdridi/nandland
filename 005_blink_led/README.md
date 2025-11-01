# Exercice 005 : LED Clignotante

## 🎯 Objectif

Faire clignoter une LED à 1 Hz en utilisant l'horloge 25 MHz de la Go Board.

## 📚 Concepts

- **Diviseur de fréquence** : Réduire 25 MHz à 1 Hz
- **Compteur** : Compter les cycles d'horloge
- **Toggle** : Inverser l'état de la LED périodiquement

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz

### Sorties
- `o_LED_1` : LED qui clignote à 1 Hz (ON 0.5s, OFF 0.5s)

### Comportement

La LED doit :
1. S'allumer pendant 0.5 seconde
2. S'éteindre pendant 0.5 seconde
3. Répéter indéfiniment

### Calcul du diviseur

```
Fréquence horloge = 25 MHz = 25 000 000 Hz
Période souhaitée = 1 Hz (toggle toutes les 0.5s)

Cycles pour 0.5s = 25 000 000 / 2 = 12 500 000 cycles
```

## 💡 Implémentation

### Compteur
```verilog
reg [23:0] r_Counter;  // 24 bits suffisent pour 12 500 000

always @(posedge i_Clk) begin
    if (r_Counter == 12_500_000 - 1)
        r_Counter <= 0;
    else
        r_Counter <= r_Counter + 1;
end
```

### Toggle LED
```verilog
reg r_LED;

always @(posedge i_Clk) begin
    if (r_Counter == 12_500_000 - 1)
        r_LED <= ~r_LED;  // Inverser
end
```

## 🧪 Tests

Le testbench vérifie :
1. ✅ Compteur s'incrémente correctement
2. ✅ Compteur revient à 0 après 12 500 000 cycles
3. ✅ LED toggle toutes les 0.5 secondes
4. ✅ Période totale = 1 seconde

## 📊 Ressources utilisées

- **Registres** : ~25 (compteur 24-bit + LED)
- **LUTs** : ~50 (comparateur + logique de comptage)
- **Fréquence max** : 25 MHz (largement suffisant sur iCE40)

## 🎓 Points d'apprentissage

1. **Diviseur de fréquence** : Technique fondamentale en FPGA
2. **Compteur wrap-around** : Reset automatique
3. **Optimisation taille** : Choisir la bonne largeur de compteur
4. **Calcul temporel** : Convertir Hz en cycles d'horloge
