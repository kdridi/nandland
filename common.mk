# Makefile commun pour tous les exercices Nandland Go Board
# Inclure ce fichier depuis le Makefile de chaque exercice avec : include ../common.mk

# Vérifier que MODULE est défini
ifndef MODULE
$(error MODULE non défini. Définissez MODULE dans votre Makefile avant d'inclure common.mk)
endif

# Configuration Go Board
DEVICE = hx1k
PACKAGE = vq100
PCF = ../go_board.pcf

# Fichiers sources (défaut, peuvent être surchargés)
SOURCES ?= $(MODULE).v
TESTBENCH ?= $(MODULE)_tb.v

# Répertoire de build
BUILD_DIR = build

# Fichiers de sortie (dans build/)
JSON = $(BUILD_DIR)/$(MODULE).json
ASC = $(BUILD_DIR)/$(MODULE).asc
BIN = $(BUILD_DIR)/$(MODULE).bin
SIM_OUT = $(BUILD_DIR)/sim.out
VCD = $(BUILD_DIR)/$(MODULE).vcd

# Chemin absolu vers la racine du projet (où se trouve common.mk)
PROJECT_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))
PROJECT_ROOT := $(abspath $(PROJECT_ROOT))

# Chemin absolu vers les outils
TOOLS_BIN = $(PROJECT_ROOT)/tools/oss-cad-suite/bin

# Outils avec chemins absolus
YOSYS = $(TOOLS_BIN)/yosys
NEXTPNR = $(TOOLS_BIN)/nextpnr-ice40
ICEPACK = $(TOOLS_BIN)/icepack
ICEPROG = $(TOOLS_BIN)/iceprog
IVERILOG = $(TOOLS_BIN)/iverilog
VVP = $(TOOLS_BIN)/vvp

# Couleurs pour l'affichage
GREEN = \033[0;32m
BLUE = \033[0;34m
NC = \033[0m

# Targets
.PHONY: all sim build flash clean help

# Target par défaut
all: build

# Aide
help:
	@echo "$(BLUE)=== Makefile pour $(MODULE) ===$(NC)"
	@echo ""
	@echo "Targets disponibles :"
	@echo "  make sim    - Simuler avec iverilog"
	@echo "  make build  - Synthèse + Place & Route + Bitstream"
	@echo "  make flash  - Programmer la Go Board"
	@echo "  make clean  - Nettoyer les fichiers générés"
	@echo "  make all    - Équivalent à 'make build'"

# Simulation avec iverilog
sim: $(SOURCES) $(TESTBENCH)
	@mkdir -p $(BUILD_DIR)
	@echo "$(BLUE)=== Simulation de $(MODULE) ===$(NC)"
	$(IVERILOG) -o $(SIM_OUT) $(SOURCES) $(TESTBENCH)
	cd $(BUILD_DIR) && $(VVP) sim.out
	@echo "$(GREEN)✓ Simulation terminée$(NC)"

# Build complet : synthèse + place & route + bitstream
build: $(BIN)
	@echo "$(GREEN)✓ Build terminé : $(BIN)$(NC)"

# Synthèse avec Yosys
$(JSON): $(SOURCES)
	@mkdir -p $(BUILD_DIR)
	@echo "$(BLUE)=== Synthèse avec Yosys ===$(NC)"
	$(YOSYS) -q -p "synth_ice40 -top $(MODULE) -json $(JSON)" $(SOURCES)

# Place & Route avec nextpnr
$(ASC): $(JSON) $(PCF)
	@echo "$(BLUE)=== Place & Route avec nextpnr ===$(NC)"
	$(NEXTPNR) --quiet --$(DEVICE) --package $(PACKAGE) --json $(JSON) --pcf $(PCF) --asc $(ASC)

# Génération du bitstream
$(BIN): $(ASC)
	@echo "$(BLUE)=== Génération du bitstream ===$(NC)"
	$(ICEPACK) $(ASC) $(BIN)

# Programmation de la Go Board
flash: $(BIN)
	@echo "$(BLUE)=== Programmation de la Go Board ===$(NC)"
	$(ICEPROG) $(BIN)
	@echo "$(GREEN)✓ Programmation terminée$(NC)"

# Nettoyage
clean:
	@echo "$(BLUE)=== Nettoyage ===$(NC)"
	rm -rf $(BUILD_DIR)
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"
