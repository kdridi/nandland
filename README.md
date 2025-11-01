# Nandland Go Board - Exercices CLI

Exercices d'apprentissage FPGA pour la Go Board de Nandland, utilisant uniquement des outils en ligne de commande.

## Installation des outils (macOS ARM64)

### Installation rapide

```bash
# 1. Cloner le dépôt
git clone <url-du-depot>
cd nandland

# 2. Installer les outils FPGA (télécharge ~504 MB)
./install_tools.sh

# 3. Charger l'environnement
source ./env.sh
```

Les outils seront installés dans `./tools/` (exclu de Git).

### Utilisation des outils

Dans chaque session terminal, depuis la racine du projet :

```bash
source ./env.sh
```

Cela chargera automatiquement :
- **yosys** - Synthèse
- **nextpnr-ice40** - Place & Route
- **iceprog** - Programmation FPGA
- **icepack** - Génération bitstream
- Et bien d'autres outils

### Outils supplémentaires (optionnels)

Pour la simulation Verilog, installer via Homebrew :

```bash
brew install icarus-verilog  # Simulateur Verilog
brew install gtkwave         # Visualiseur de formes d'onde
```

### Notes

- Les outils sont installés localement dans `./tools/` (pas dans le home)
- Chaque projet peut avoir sa propre version des outils
- Le répertoire `tools/` est ignoré par Git (voir `.gitignore`)
- Pour Intel Mac, modifier l'URL dans `install_tools.sh`

## Structure des exercices

Chaque exercice est dans un répertoire numéroté :
```
000_premier_exercice/
001_deuxieme_exercice/
...
```

Voir `CLAUDE.md` pour plus de détails sur l'organisation et le workflow de développement.