#!/bin/bash
# Script pour sourcer l'environnement des outils FPGA
# Usage: source ./env.sh

# Déterminer le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSS_CAD_SUITE_ENV="${SCRIPT_DIR}/tools/oss-cad-suite/environment"

if [ ! -f "${OSS_CAD_SUITE_ENV}" ]; then
    echo "❌ Erreur : Les outils ne sont pas installés"
    echo ""
    echo "Lancez d'abord le script d'installation :"
    echo "  ./install_tools.sh"
    return 1
fi

# Sourcer l'environnement OSS CAD Suite
source "${OSS_CAD_SUITE_ENV}"

echo "✓ Environnement FPGA chargé"
echo ""
echo "Outils disponibles :"
echo "  yosys -V"
echo "  nextpnr-ice40 --version"
echo "  iceprog"
echo "  icepack"
