Write-Host "[*] Installation des paquets MSYS2 (à lancer dans MinGW64)..."

pacman -S --needed --noconfirm `
  mingw-w64-x86_64-gcc `
  mingw-w64-x86_64-gcc-fortran `
  mingw-w64-x86_64-openssl `
  mingw-w64-x86_64-curl `
  make

Write-Host "[*] Création du dossier build/ si nécessaire..."
mkdir -Force ../build | Out-Null

Write-Host "[*] Compilation du projet (fortran/Makefile)..."
cd fortran
make

Write-Host "[*] Terminé. Binaire dans ../build/demo_sqlitecloud"
