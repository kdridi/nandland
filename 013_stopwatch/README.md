# Exercice 013 : Chronomètre Simple

## 🎯 Objectif

Créer un chronomètre simple 00-99 centièmes de seconde avec contrôles Start/Stop et Reset, affiché sur deux afficheurs 7 segments.

## 📚 Concepts

- **Machine à états** : IDLE / RUNNING / STOPPED
- **Diviseur de fréquence** : 25 MHz → 100 Hz (centièmes de seconde)
- **Anti-rebond** : Sur les deux boutons de contrôle
- **Détection de fronts** : Toggle Start/Stop sur appui
- **Affichage double** : Dizaines et unités sur 7 segments

## 🔧 Spécifications

### Entrées
- `i_Clk` : Horloge 25 MHz
- `i_Switch_1` : Start/Stop (toggle)
- `i_Switch_2` : Reset

### Sorties
- `o_Segments1[6:0]` : Dizaines (gauche)
- `o_Segments2[6:0]` : Unités (droite)

### Comportement

**Boutons :**
- **Switch_1 (Start/Stop)** :
  - Si arrêté → démarre le chrono
  - Si en marche → met en pause
  - Appui = toggle (bascule entre running/stopped)
- **Switch_2 (Reset)** :
  - Remet le compteur à 00
  - Arrête le chronomètre

**États :**
```
IDLE (00, arrêté)
  ↓ Switch_1
RUNNING (compte 00→01→02...)
  ↓ Switch_1
STOPPED (pause, garde la valeur)
  ↓ Switch_1
RUNNING (continue)

Switch_2 → IDLE (depuis n'importe quel état)
```

**Timing :**
- Compte de 00 à 99 centièmes de seconde
- Incrément toutes les 0.01s (10 ms)
- Wrap automatique : 99 → 00

### Exemples de séquence

```
État      Switch_1  Switch_2  | Affichage | Description
----------|----------|----------|-----------|------------------
IDLE      0         0         |    00     | Attente
RUNNING   1         0         | 00→01→02  | Chrono démarre
STOPPED   1         0         |    02     | Pause
RUNNING   1         0         | 02→03→04  | Continue
IDLE      X         1         |    00     | Reset
```

## 💡 Implémentation

### Machine à états

```verilog
// États
localparam IDLE    = 2'b00;
localparam RUNNING = 2'b01;
localparam STOPPED = 2'b10;

reg [1:0] r_State = IDLE;

// Transition d'états
always @(posedge i_Clk) begin
    if (w_Reset_Edge) begin
        r_State <= IDLE;
        r_Counter <= 0;
    end else begin
        case (r_State)
            IDLE: begin
                if (w_StartStop_Edge)
                    r_State <= RUNNING;
            end
            RUNNING: begin
                if (w_StartStop_Edge)
                    r_State <= STOPPED;
                else if (r_Enable)
                    // Incrémenter le compteur
                    r_Counter <= (r_Counter == 99) ? 0 : r_Counter + 1;
            end
            STOPPED: begin
                if (w_StartStop_Edge)
                    r_State <= RUNNING;
            end
        endcase
    end
end
```

### Diviseur de fréquence

```verilog
// 25 MHz → 100 Hz (0.01s)
// Période = 250_000 cycles
localparam CENTISECOND = 250_000;

always @(posedge i_Clk) begin
    if (r_Clk_Count == CENTISECOND - 1) begin
        r_Clk_Count <= 0;
        r_Enable <= 1;
    end else begin
        r_Clk_Count <= r_Clk_Count + 1;
        r_Enable <= 0;
    end
end
```

## 🧪 Tests

Le testbench vérifie :
1. ✅ État initial IDLE à 00
2. ✅ Start démarre le comptage
3. ✅ Stop met en pause
4. ✅ Resume continue depuis la pause
5. ✅ Reset remet à 00 et arrête
6. ✅ Wrap 99→00
7. ✅ Séquence complète Start→Stop→Resume→Reset

## 📊 Ressources utilisées

- **Registres** : ~65 (2× anti-rebond + diviseur 18-bit + compteur 7-bit + états)
- **LUTs** : ~220 (debounce + FSM + compteur + 2× décodeurs)
- **Fréquence max** : 25 MHz
- **Précision** : ±1 centième de seconde

## 🎓 Points d'apprentissage

1. **Machine à états finis** : Contrôle de flux avec états IDLE/RUNNING/STOPPED
2. **Toggle avec front** : Start/Stop bascule à chaque appui
3. **Diviseur précis** : 100 Hz pour mesure de temps
4. **Composition** : Combine anti-rebond + FSM + compteur + affichage
5. **Interface utilisateur** : Expérience fluide avec pause/resume

## 🔗 Utilisation future

Ce pattern de chronomètre sera réutilisé dans :
- Jeux avec timer
- Mesure de temps de réaction
- Interfaces de menu temporisées
- Animations chronométrées

## 💡 Évolutions possibles

1. **Minutes:Secondes** : 4 afficheurs pour MM:SS
2. **Mode compte à rebours** : Timer avec alarme
3. **Lap time** : Mémoriser temps intermédiaires
4. **Précision milliseconde** : 1000 Hz au lieu de 100 Hz
