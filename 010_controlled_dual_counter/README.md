# Exercice 010 : Compteur 00-99 Contrôlable

## 🎯 Objectif

Créer un compteur décimal 00-99 avec contrôles utilisateur (enable/pause et reset) affiché sur deux afficheurs 7 segments.

## 📚 Concepts

- **Synthèse des exercices** : Combinaison 007 (contrôles) + 009 (double afficheur)
- **Logique de contrôle** : Enable, pause et reset sur compteur multi-chiffres
- **Interaction complète** : Switches + afficheurs 7 segments

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz
- `i_Switch_1` : Enable comptage (1=compte, 0=pause)
- `i_Switch_2` : Reset (1=reset à 00, 0=normal)

### Sorties
- `o_Segment1_A` à `o_Segment1_G` : Dizaines (gauche)
- `o_Segment2_A` à `o_Segment2_G` : Unités (droite)

### Comportement

**Switch 1 (Enable) :**
- ON (1) : Le compteur incrémente toutes les 0.5s
- OFF (0) : Le compteur est en pause (garde sa valeur)

**Switch 2 (Reset) :**
- ON (1) : Le compteur est forcé à 00
- OFF (0) : Fonctionnement normal

**Priorité :** Reset > Enable > Pause
- Si Switch_2 = 1 → compteur à 00
- Si Switch_2 = 0 et Switch_1 = 1 → compteur incrémente
- Si Switch_2 = 0 et Switch_1 = 0 → compteur en pause

### Exemples de séquence

```
Switch_1  Switch_2  | Affichage | Comportement
----------|----------|-----------|---------------
   0         0      |    00     | Pause à 00
   1         0      | 00→01→02  | Compte normalement
   0         0      |    02     | Pause à 02
   1         0      | 02→03→04  | Continue à compter
   X         1      |    00     | Reset immédiat
   1         0      | 00→01→02  | Repart de 00
```

## 💡 Implémentation

### Logique de contrôle

```verilog
// Compteur 0-99
reg [6:0] r_Counter;

always @(posedge i_Clk) begin
    if (i_Switch_2) begin
        // Reset a priorité
        r_Counter <= 0;
    end else if (r_Enable && i_Switch_1) begin
        // Compte seulement si enable pulse ET switch_1
        if (r_Counter == 99)
            r_Counter <= 0;
        else
            r_Counter <= r_Counter + 1;
    end
    // Sinon : garde la valeur (pause)
end
```

### Division et affichage

- Identique à l'exercice 009
- Division/modulo pour dizaines/unités
- Deux décodeurs 7 segments

## 🧪 Tests

Le testbench vérifie :
1. ✅ Reset force le compteur à 00
2. ✅ Compteur incrémente avec Switch_1=1
3. ✅ Compteur en pause avec Switch_1=0
4. ✅ Reset a priorité sur enable
5. ✅ Reprise du comptage après pause
6. ✅ Wrap 99→00
7. ✅ Affichage correct dizaines/unités

## 📊 Ressources utilisées

- **Registres** : ~34 (diviseur 24-bit + compteur 7-bit + enable)
- **LUTs** : ~160 (comparateur + additionneur + 2 décodeurs + logique contrôle)
- **Fréquence max** : 25 MHz

## 🎓 Points d'apprentissage

1. **Composition avancée** : Combinaison de plusieurs exercices
2. **Logique de contrôle complexe** : Priorités multiples
3. **Design modulaire** : Réutilisation et extension
4. **Interaction complète** : Entrées (switches) + Sorties (afficheurs)
