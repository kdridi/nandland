# Exercice 012 : Compteur avec Boutons

## 🎯 Objectif

Créer un compteur 0-9 contrôlé par deux boutons (increment/decrement) avec anti-rebond et détection de fronts, affiché sur un afficheur 7 segments.

## 📚 Concepts

- **Anti-rebond** : Réutilisation du module de l'exercice 011
- **Détection de front** : Détecter le moment précis de l'appui (front montant)
- **Compteur bidirectionnel** : Increment (↑) et decrement (↓)
- **Modularité** : Composition de modules existants

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz
- `i_Switch_1` : Bouton increment (+)
- `i_Switch_2` : Bouton decrement (-)

### Sorties
- `o_Segment1_A` à `o_Segment1_G` : Afficheur 7 segments (affiche 0-9)

### Comportement

**Boutons :**
- **Switch_1** : Appui = incrément de 1 (0→1, 1→2, ..., 9→0)
- **Switch_2** : Appui = décrément de 1 (9→8, 8→7, ..., 0→9)
- **Simultané** : Si les deux boutons appuyés, priorité à l'increment

**Un seul incrément par appui :**
```
Appui physique: ____┌──────────┐_____  (maintenu 0.5s)
Signal filtré:  ____┌──────────┐_____  (après anti-rebond)
Front montant:  ____┌┐_______________  (pulse 1 cycle)
Compteur:       0000011111111111111  (incrémente UNE fois)
```

### Architecture

Le design combine plusieurs concepts :

1. **Anti-rebond** (2×) : Un pour chaque bouton
2. **Détection de front** (2×) : Un pour chaque signal filtré
3. **Logique de compteur** : Increment/decrement avec wrap
4. **Décodeur 7 segments** : Affichage du compteur

## 💡 Implémentation

### Détection de front montant

```verilog
// Mémoriser l'état précédent
reg r_Switch_Prev = 0;

always @(posedge i_Clk) begin
    r_Switch_Prev <= w_Switch_Stable;
end

// Front montant = transition 0→1
wire w_Rising_Edge = w_Switch_Stable && !r_Switch_Prev;
```

### Logique du compteur

```verilog
always @(posedge i_Clk) begin
    if (w_Inc_Edge && w_Dec_Edge) begin
        // Les deux : priorité à l'increment
        if (r_Counter == 9)
            r_Counter <= 0;
        else
            r_Counter <= r_Counter + 1;
    end else if (w_Inc_Edge) begin
        // Increment seul
        if (r_Counter == 9)
            r_Counter <= 0;
        else
            r_Counter <= r_Counter + 1;
    end else if (w_Dec_Edge) begin
        // Decrement seul
        if (r_Counter == 0)
            r_Counter <= 9;
        else
            r_Counter <= r_Counter - 1;
    end
    // Sinon : garde la valeur
end
```

## 🧪 Tests

Le testbench vérifie :
1. ✅ État initial à 0
2. ✅ Increment avec rebonds (0→1→2→3)
3. ✅ Decrement avec rebonds (3→2→1→0)
4. ✅ Wrap increment (9→0)
5. ✅ Wrap decrement (0→9)
6. ✅ Un seul incrément par appui (même si maintenu)
7. ✅ Rebonds correctement filtrés
8. ✅ Appuis simultanés (priorité increment)

## 📊 Ressources utilisées

- **Registres** : ~50 (2× anti-rebond + 2× edge detect + compteur 4-bit)
- **LUTs** : ~200 (2× debounce + edge detect + compteur + décodeur)
- **Fréquence max** : 25 MHz
- **Modules instanciés** : Aucun (logique intégrée)

## 🎓 Points d'apprentissage

1. **Composition de concepts** : Anti-rebond + détection de fronts + compteur
2. **Edge detection** : Technique fondamentale pour interfaces utilisateur
3. **Un événement = une action** : Éviter les incréments multiples
4. **Priorité** : Gestion de boutons simultanés
5. **Réutilisation** : Pattern d'anti-rebond utilisable partout

## 🔗 Évolution

Ce pattern sera réutilisé dans :
- Chronomètre (start/stop/reset)
- Jeux interactifs (contrôles utilisateur)
- Menus et sélection
- Toute interface utilisateur avec boutons

## 💡 Note sur l'anti-rebond

Dans cet exercice, nous **intégrons** la logique d'anti-rebond directement dans le module plutôt que d'instancier le module `button_debounce`. Cela simplifie le design et montre comment réutiliser le **pattern** d'anti-rebond.

Pour un design plus modulaire, on pourrait instancier 2× le module `button_debounce.v` de l'exercice 011.
