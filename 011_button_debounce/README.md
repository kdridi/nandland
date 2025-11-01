# Exercice 011 : Anti-rebond de Bouton (Button Debounce)

## 🎯 Objectif

Implémenter un circuit d'anti-rebond pour filtrer les rebonds mécaniques des boutons et générer une impulsion propre à chaque appui.

## 📚 Concepts

- **Rebond mécanique** : Les contacts mécaniques génèrent des oscillations parasites (~5-20 ms)
- **Filtrage temporel** : Ignorer les changements pendant une fenêtre de temps
- **Détection de front** : Générer une impulsion sur front montant/descendant
- **Synchronisation** : Éviter les problèmes de métastabilité

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz
- `i_Switch_1` : Bouton/Switch à filtrer

### Sorties
- `o_Switch` : Signal filtré (état stable)

### Paramètres
- `DEBOUNCE_TIME` : Temps d'anti-rebond en cycles d'horloge
  - Simulation : 50 cycles (2 μs)
  - Matériel : 250_000 cycles (10 ms @ 25 MHz)

### Comportement

**Problème sans anti-rebond :**
```
Signal physique:  ___┌┐┌┐┌──────  (rebonds pendant ~10 ms)
Sans filtrage:    ___┌┐┌┐┌──────  (plusieurs impulsions parasites)
Compteur:         001234567────  (incrémente plusieurs fois!)
```

**Avec anti-rebond :**
```
Signal physique:  ___┌┐┌┐┌──────
Avec filtrage:    _______┌──────  (une seule transition propre)
Compteur:         0000001──────  (incrémente une seule fois)
```

### Algorithme

1. **Synchronisation** : Double registre pour éviter métastabilité
2. **Temporisation** : Compteur qui attend DEBOUNCE_TIME
3. **Validation** : Le signal doit rester stable pendant toute la période
4. **Mise à jour** : Mise à jour du signal de sortie seulement après stabilisation

## 💡 Implémentation

### Logique d'anti-rebond

```verilog
// Synchronisation double pour éviter métastabilité
reg r_Sync_1 = 0;
reg r_Sync_2 = 0;

always @(posedge i_Clk) begin
    r_Sync_1 <= i_Switch_1;
    r_Sync_2 <= r_Sync_1;
end

// Compteur d'anti-rebond
reg [17:0] r_Debounce_Count = 0;
reg r_Switch_State = 0;

always @(posedge i_Clk) begin
    if (r_Sync_2 != r_Switch_State) begin
        // Signal a changé, commencer à compter
        r_Debounce_Count <= r_Debounce_Count + 1;

        if (r_Debounce_Count >= DEBOUNCE_TIME) begin
            // Signal stable assez longtemps, valider le changement
            r_Switch_State <= r_Sync_2;
            r_Debounce_Count <= 0;
        end
    end else begin
        // Signal identique, reset le compteur
        r_Debounce_Count <= 0;
    end
end
```

## 🧪 Tests

Le testbench vérifie :
1. ✅ Synchronisation (évite métastabilité)
2. ✅ Filtrage des rebonds courts (< DEBOUNCE_TIME)
3. ✅ Passage des transitions longues (> DEBOUNCE_TIME)
4. ✅ Multiple appuis avec rebonds
5. ✅ Stabilité de l'état entre les transitions

## 📊 Ressources utilisées

- **Registres** : ~22 (sync 2-bit + compteur 18-bit + état 1-bit)
- **LUTs** : ~30 (comparateur + additionneur + logique)
- **Fréquence max** : 25 MHz
- **Latence** : 10 ms (250_000 cycles @ 25 MHz)

## 🎓 Points d'apprentissage

1. **Métastabilité** : Toujours synchroniser les signaux externes asynchrones
2. **Filtrage temporel** : Solution pratique pour les problèmes mécaniques
3. **Paramétrage** : Adapter la constante selon l'application (bouton vs. contact)
4. **Design robuste** : Nécessaire pour toute interface utilisateur réelle

## 🔗 Utilisation future

Ce module sera réutilisé dans tous les exercices suivants utilisant des boutons :
- Compteurs up/down avec boutons
- Chronomètre start/stop
- Jeux interactifs
- Interfaces utilisateur

## 🌟 Amélioration possible

Pour détecter les **fronts** (utile pour compteurs) :
```verilog
reg r_Switch_Prev = 0;
wire w_Rising_Edge = r_Switch_State && !r_Switch_Prev;

always @(posedge i_Clk) begin
    r_Switch_Prev <= r_Switch_State;
end
```
