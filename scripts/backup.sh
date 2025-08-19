#!/bin/bash

# Mini Linux System Management Tool - Yedekleme Scripti
# Bu script aracın yedeğini oluşturur

echo "💾 Mini Linux System Management Tool yedekleniyor..."
echo

# Yedek dizini oluştur
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Yedek dizini oluşturuldu: $BACKUP_DIR"

# Dosyaları yedekle
echo "📋 Dosyalar yedekleniyor..."
cp -r modules/ "$BACKUP_DIR/"
cp -r config/ "$BACKUP_DIR/"
cp -r themes/ "$BACKUP_DIR/"
cp -r docs/ "$BACKUP_DIR/"
cp -r scripts/ "$BACKUP_DIR/"
cp mini-sysmgmt.sh "$BACKUP_DIR/"

# Yedek bilgileri
echo "📊 Yedek bilgileri:"
echo "   📅 Tarih: $(date)"
echo "   📁 Konum: $BACKUP_DIR"
echo "   📏 Boyut: $(du -sh "$BACKUP_DIR" | cut -f1)"

echo "✅ Yedekleme tamamlandı!"
echo "💾 Yedek: $BACKUP_DIR"
