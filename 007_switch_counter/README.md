# Exercice 007 : Compteur Contrôlable par Switches

## 🎯 Objectif

Créer un compteur binaire 4-bit contrôlable par les switches de la Go Board (enable/disable et reset).

## 📚 Concepts

- **Entrées utilisateur** : Lecture des switches
- **Logique de contrôle** : Enable et reset conditionnels
- **Combinaison** : Compteur + diviseur + contrôles

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz
- `i_Switch_1` : Enable comptage (1=compte, 0=pause)
- `i_Switch_2` : Reset (1=reset à 0, 0=normal)

### Sorties
- `o_LED_1` : Bit 3 (MSB)
- `o_LED_2` : Bit 2
- `o_LED_3` : Bit 1
- `o_LED_4` : Bit 0 (LSB)

### Comportement

**Switch 1 (Enable) :**
- Position ON (1) : Le compteur incrémente toutes les 0.5s
- Position OFF (0) : Le compteur est en pause (garde sa valeur)

**Switch 2 (Reset) :**
- Position ON (1) : Le compteur est forcé à 0
- Position OFF (0) : Fonctionnement normal

**Priorité :** Reset a priorité sur Enable
- Si Switch_2 = 1 → compteur à 0 (même si Switch_1 = 1)
- Si Switch_2 = 0 et Switch_1 = 1 → compteur incrémente
- Si Switch_2 = 0 et Switch_1 = 0 → compteur en pause

### Exemples de séquence

```
Switch_1  Switch_2  | Compteur | Comportement
----------|----------|----------|--------------
   0         0      |    0     | Pause à 0
   1         0      |  0→1→2   | Compte normalement
   0         0      |    2     | Pause à 2
   1         0      |  2→3→4   | Continue à compter
   X         1      |    0     | Reset (peu importe Switch_1)
   1         0      |  0→1→2   | Repart de 0
```

## 💡 Implémentation

### Logique de contrôle
```verilog
always @(posedge i_Clk) begin
    if (i_Switch_2) begin
        // Reset a priorité
        r_Counter <= 0;
    end else if (r_Enable && i_Switch_1) begin
        // Compte seulement si enable ET switch_1
        r_Counter <= r_Counter + 1;
    end
    // Sinon : garde la valeur (pause)
end
```

### Diviseur de fréquence
- Identique aux exercices 005 et 006
- Génère signal `r_Enable` toutes les 0.5s
- Incrément conditionné par `i_Switch_1`

## 🧪 Tests

Le testbench vérifie :
1. ✅ Reset force le compteur à 0
2. ✅ Compteur incrémente quand Switch_1=1 et Switch_2=0
3. ✅ Compteur en pause quand Switch_1=0
4. ✅ Reset a priorité sur enable
5. ✅ Reprise du comptage après pause

## 📊 Ressources utilisées

- **Registres** : ~30 (diviseur 24-bit + compteur 4-bit + enable)
- **LUTs** : ~60 (comparateur + additionneur + logique de contrôle)
- **Fréquence max** : 25 MHz

## 🎓 Points d'apprentissage

1. **Entrées utilisateur** : Lecture synchrone des switches
2. **Logique de contrôle** : Priorités entre signaux
3. **Machine à états simple** : Pause/Run/Reset
4. **Interaction hardware** : Feedback immédiat utilisateur
