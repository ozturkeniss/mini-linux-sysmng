#!/bin/bash

# Mini Linux System Management Tool - Kaldırma Scripti
# Bu script aracı ve tüm bileşenlerini kaldırır

echo "🗑️  Mini Linux System Management Tool kaldırılıyor..."
echo

# Onay sorusu
read -p "❓ Bu işlem geri alınamaz! Devam etmek istiyor musunuz? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Kaldırma işlemi iptal edildi."
    exit 1
fi

echo "📁 Dosyalar kaldırılıyor..."
rm -rf modules/
rm -rf config/
rm -rf themes/
rm -rf docs/
rm -rf scripts/
rm -f mini-sysmgmt.sh

echo "✅ Kaldırma tamamlandı!"
echo "👋 Mini Linux System Management Tool kaldırıldı."
