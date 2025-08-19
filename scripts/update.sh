#!/bin/bash

# Mini Linux System Management Tool - Güncelleme Scripti
# Bu script aracı günceller

echo "🔄 Mini Linux System Management Tool güncelleniyor..."
echo

# Git repo kontrolü
if [ -d ".git" ]; then
    echo "📥 Güncellemeler kontrol ediliyor..."
    git fetch origin
    
    # Güncelleme var mı kontrol et
    if [ "$(git rev-list HEAD...origin/main --count)" != "0" ]; then
        echo "🆕 Güncelleme bulundu! Uygulanıyor..."
        git pull origin main
        
        echo "📁 Dizin yapısı güncelleniyor..."
        chmod +x mini-sysmgmt.sh
        chmod +x scripts/*.sh
        
        echo "✅ Güncelleme tamamlandı!"
    else
        echo "✅ Aracı zaten güncel!"
    fi
else
    echo "❌ Git repository bulunamadı!"
    echo "💡 Manuel güncelleme gerekli."
fi
