#!/bin/bash
# Script d'installation des outils FPGA open-source pour macOS
# Ce script télécharge et installe OSS CAD Suite dans le répertoire du projet

set -e  # Arrêter en cas d'erreur

# Couleurs pour l'affichage
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Installation des outils FPGA pour Nandland Go Board ===${NC}"
echo ""

# Déterminer le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${SCRIPT_DIR}/tools"
OSS_CAD_SUITE_DIR="${TOOLS_DIR}/oss-cad-suite"

# Vérifier si déjà installé
if [ -d "${OSS_CAD_SUITE_DIR}" ]; then
    echo -e "${GREEN}Les outils sont déjà installés dans ${OSS_CAD_SUITE_DIR}${NC}"
    echo "Pour réinstaller, supprimez d'abord le répertoire tools/ :"
    echo "  rm -rf tools/"
    exit 0
fi

# Détecter l'architecture
ARCH=$(uname -m)
OS=$(uname -s)

if [ "$OS" != "Darwin" ]; then
    echo -e "${RED}Erreur : Ce script est conçu pour macOS uniquement${NC}"
    exit 1
fi

if [ "$ARCH" != "arm64" ]; then
    echo -e "${RED}Erreur : Ce script est conçu pour macOS Apple Silicon (ARM64)${NC}"
    echo "Pour macOS Intel, consultez : https://github.com/YosysHQ/oss-cad-suite-build/releases"
    exit 1
fi

# URL de la dernière version (mise à jour : 2025-11-01)
VERSION="20251101"
DOWNLOAD_URL="https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2025-11-01/oss-cad-suite-darwin-arm64-${VERSION}.tgz"
ARCHIVE_NAME="oss-cad-suite-darwin-arm64-${VERSION}.tgz"

echo -e "${BLUE}Architecture détectée :${NC} macOS ARM64 (Apple Silicon)"
echo -e "${BLUE}Version à installer :${NC} ${VERSION}"
echo ""

# Créer le répertoire tools
mkdir -p "${TOOLS_DIR}"
cd "${TOOLS_DIR}"

# Télécharger OSS CAD Suite
echo -e "${BLUE}Téléchargement de OSS CAD Suite...${NC}"
echo "URL : ${DOWNLOAD_URL}"
echo "Taille : ~504 MB (cela peut prendre quelques minutes)"
echo ""

if command -v wget > /dev/null; then
    wget --show-progress -O "${ARCHIVE_NAME}" "${DOWNLOAD_URL}"
elif command -v curl > /dev/null; then
    curl -L --progress-bar -o "${ARCHIVE_NAME}" "${DOWNLOAD_URL}"
else
    echo -e "${RED}Erreur : wget ou curl requis pour le téléchargement${NC}"
    exit 1
fi

# Extraire l'archive
echo ""
echo -e "${BLUE}Extraction de l'archive...${NC}"
tar -xzf "${ARCHIVE_NAME}"

# Nettoyer l'archive
echo -e "${BLUE}Nettoyage...${NC}"
rm "${ARCHIVE_NAME}"

# Vérification de l'installation
if [ -f "${OSS_CAD_SUITE_DIR}/environment" ]; then
    echo ""
    echo -e "${GREEN}✓ Installation réussie !${NC}"
    echo ""
    echo -e "${BLUE}Pour utiliser les outils, sourcez l'environnement :${NC}"
    echo "  source ./env.sh"
    echo ""
    echo -e "${BLUE}Ou directement :${NC}"
    echo "  source tools/oss-cad-suite/environment"
    echo ""
    echo -e "${BLUE}Outils inclus :${NC}"
    echo "  - yosys          (synthèse)"
    echo "  - nextpnr-ice40  (place & route)"
    echo "  - iceprog        (programmation FPGA)"
    echo "  - icepack        (génération bitstream)"
    echo "  - et bien d'autres..."
else
    echo -e "${RED}Erreur : L'installation a échoué${NC}"
    exit 1
fi
