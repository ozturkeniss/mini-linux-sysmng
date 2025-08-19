#!/bin/bash

# Mini Linux System Management Tool - Kurulum Scripti
# Bu script gerekli paketleri kurar ve aracı hazırlar

echo "🚀 Mini Linux System Management Tool kuruluyor..."
echo

# Root kontrolü
if [[ $EUID -ne 0 ]]; then
   echo "❌ Bu script root yetkisi gerektirir!"
   echo "💡 'sudo' ile çalıştırın: sudo ./scripts/install.sh"
   exit 1
fi

echo "📦 Sistem paketleri güncelleniyor..."
apt update

echo "🔧 Gerekli paketler kuruluyor..."
apt install -y htop tree curl wget git net-tools

echo "📁 Dizin yapısı kontrol ediliyor..."
chmod +x mini-sysmgmt.sh
chmod +x scripts/*.sh

echo "✅ Kurulum tamamlandı!"
echo "🎯 Aracı çalıştırmak için: ./mini-sysmgmt.sh"
