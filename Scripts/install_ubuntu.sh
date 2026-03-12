#!/usr/bin/env bash
set -e

echo "[*] Mise à jour des paquets..."
sudo apt update

echo "[*] Installation des dépendances build + réseau..."
sudo apt install -y \
  gcc gfortran binutils make \
  libssl-dev openssl \
  libcurl4-openssl-dev

echo "[*] Création du dossier build/ si nécessaire..."
mkdir -p build

echo "[*] Compilation du projet (fortran/Makefile)..."
cd fortran
make

echo "[*] Terminé. Binaire disponible dans ../build/demo_sqlitecloud"
