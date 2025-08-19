#!/bin/bash

# Backup Geri Yükleme Modülü
# Bu modül yedekleri geri yükler

# Tema dosyasını yükle
source "$(dirname "$0")/../../themes/default.sh"

# Root kontrolü
check_root() {
    if [[ $EUID -ne 0 ]]; then
        draw_error_box "Bu işlem için root yetkisi gereklidir!"
        echo "Lütfen 'sudo' ile çalıştırın."
        read -p "Ana menüye dönmek için Enter'a basın..."
        return 1
    fi
    return 0
}

# Ana fonksiyon
main() {
    draw_header "🔄 Yedek Geri Yükleme Modülü"
    
    if ! check_root; then
        return
    fi
    
    while true; do
        echo
        draw_subheader "Geri Yükleme Seçenekleri:"
        echo "1. 📁 Dizin Yedeği Geri Yükle"
        echo "2. ⚙️  Konfigürasyon Yedeği Geri Yükle"
        echo "3. 🔄 Tam Sistem Yedeği Geri Yükle"
        echo "4. 📋 Mevcut Yedekleri Listele"
        echo "5. 🗑️  Eski Yedekleri Temizle"
        echo "0. 🔙 Ana Menüye Dön"
        
        read -p "Seçiminizi yapın (0-5): " choice
        
        case $choice in
            1) restore_directory_backup ;;
            2) restore_config_backup ;;
            3) restore_full_backup ;;
            4) list_available_backups ;;
            5) clean_old_backups ;;
            0) break ;;
            *) echo "❌ Geçersiz seçim!" ;;
        esac
        
        if [[ $choice != 0 ]]; then
            echo
            read -p "Devam etmek için Enter'a basın..."
        fi
    done
}

# Dizin yedeği geri yükle
restore_directory_backup() {
    draw_subheader "📁 Dizin Yedeği Geri Yükle"
    
    backup_dir="/backup"
    if [[ ! -d "$backup_dir" ]]; then
        draw_error_box "Yedek dizini bulunamadı: $backup_dir"
        return
    fi
    
    echo "📋 Mevcut dizin yedekleri:"
    find "$backup_dir" -name "dir_backup_*.tar.gz" -type f | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
    
    echo
    read -p "Geri yüklenecek yedek dosyası: " backup_file
    
    if [[ ! -f "$backup_file" ]]; then
        if [[ ! -f "$backup_dir/$backup_file" ]]; then
            draw_error_box "Yedek dosyası bulunamadı!"
            return
        fi
        backup_file="$backup_dir/$backup_file"
    fi
    
    read -p "Geri yüklenecek hedef dizin: " target_dir
    
    if [[ -z "$target_dir" ]]; then
        draw_error_box "Hedef dizin belirtilmedi!"
        return
    fi
    
    draw_warning_box "Bu işlem hedef dizindeki mevcut dosyaları üzerine yazacak!"
    read -p "Devam etmek istiyor musunuz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ İşlem iptal edildi."
        return
    fi
    
    echo "📋 Yedek geri yükleniyor: $backup_file -> $target_dir"
    
    if tar -xzf "$backup_file" -C "$target_dir"; then
        draw_success_box "Dizin yedeği başarıyla geri yüklendi!"
        echo "📁 Hedef: $target_dir"
    else
        draw_error_box "Geri yükleme sırasında hata oluştu!"
    fi
}

# Konfigürasyon yedeği geri yükle
restore_config_backup() {
    draw_subheader "⚙️  Konfigürasyon Yedeği Geri Yükle"
    
    backup_dir="/backup"
    if [[ ! -d "$backup_dir" ]]; then
        draw_error_box "Yedek dizini bulunamadı: $backup_dir"
        return
    fi
    
    echo "📋 Mevcut konfigürasyon yedekleri:"
    find "$backup_dir" -name "config_backup_*.tar.gz" -type f | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
    
    echo
    read -p "Geri yüklenecek yedek dosyası: " backup_file
    
    if [[ ! -f "$backup_file" ]]; then
        if [[ ! -f "$backup_dir/$backup_file" ]]; then
            draw_error_box "Yedek dosyası bulunamadı!"
            return
        fi
        backup_file="$backup_dir/$backup_file"
    fi
    
    draw_warning_box "Bu işlem sistem konfigürasyonunu değiştirecek!"
    read -p "Devam etmek istiyor musunuz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ İşlem iptal edildi."
        return
    fi
    
    echo "📋 Konfigürasyon yedeği geri yükleniyor..."
    
    # Geçici dizine çıkar
    temp_dir="/tmp/config_restore_$$"
    mkdir -p "$temp_dir"
    
    if tar -xzf "$backup_file" -C "$temp_dir"; then
        echo "📋 Konfigürasyon dosyaları geri yükleniyor..."
        
        # Dosyaları uygun yerlere kopyala
        for item in "$temp_dir"/*; do
            if [[ -d "$item" ]]; then
                # Dizin ise
                dir_name=$(basename "$item")
                if [[ -d "/etc/$dir_name" ]]; then
                    echo "   📁 /etc/$dir_name güncelleniyor..."
                    cp -r "$item"/* "/etc/$dir_name/"
                fi
            elif [[ -f "$item" ]]; then
                # Dosya ise
                file_name=$(basename "$item")
                if [[ -f "/etc/$file_name" ]]; then
                    echo "   📄 /etc/$file_name güncelleniyor..."
                    cp "$item" "/etc/$file_name"
                fi
            fi
        done
        
        rm -rf "$temp_dir"
        draw_success_box "Konfigürasyon yedeği başarıyla geri yüklendi!"
    else
        draw_error_box "Geri yükleme sırasında hata oluştu!"
        rm -rf "$temp_dir"
    fi
}

# Tam sistem yedeği geri yükle
restore_full_backup() {
    draw_subheader "🔄 Tam Sistem Yedeği Geri Yükle"
    
    draw_error_box "⚠️  DİKKAT: Bu işlem tehlikeli olabilir!"
    echo "💡 Sadece aynı sistem mimarisinde ve sürümünde kullanın!"
    echo "💡 Önce test ortamında deneyin!"
    
    read -p "Devam etmek istiyor musunuz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ İşlem iptal edildi."
        return
    fi
    
    backup_dir="/backup"
    if [[ ! -d "$backup_dir" ]]; then
        draw_error_box "Yedek dizini bulunamadı: $backup_dir"
        return
    fi
    
    echo "📋 Mevcut tam sistem yedekleri:"
    find "$backup_dir" -name "full_system_backup_*.tar.gz" -type f | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
    
    echo
    read -p "Geri yüklenecek yedek dosyası: " backup_file
    
    if [[ ! -f "$backup_file" ]]; then
        if [[ ! -f "$backup_dir/$backup_file" ]]; then
            draw_error_box "Yedek dosyası bulunamadı!"
            return
        fi
        backup_file="$backup_dir/$backup_file"
    fi
    
    draw_warning_box "Bu işlem sistem dosyalarını değiştirecek!"
    read -p "Devam etmek istiyor musunuz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ İşlem iptal edildi."
        return
    fi
    
    echo "📋 Tam sistem yedeği geri yükleniyor..."
    echo "⏱️  Bu işlem uzun sürebilir..."
    
    if tar -xzf "$backup_file" -C /; then
        draw_success_box "Tam sistem yedeği başarıyla geri yüklendi!"
        echo "🔄 Sistemi yeniden başlatmanız önerilir."
    else
        draw_error_box "Geri yükleme sırasında hata oluştu!"
    fi
}

# Mevcut yedekleri listele
list_available_backups() {
    draw_subheader "📋 Mevcut Yedekler"
    
    backup_dir="/backup"
    if [[ ! -d "$backup_dir" ]]; then
        draw_error_box "Yedek dizini bulunamadı: $backup_dir"
        return
    fi
    
    echo "📁 Yedek dizini: $backup_dir"
    echo
    
    # Yedek türlerine göre grupla
    echo "📁 Dizin Yedekleri:"
    find "$backup_dir" -name "dir_backup_*.tar.gz" -type f | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
    
    echo
    echo "⚙️  Konfigürasyon Yedekleri:"
    find "$backup_dir" -name "config_backup_*.tar.gz" -type f | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
    
    echo
    echo "🔄 Tam Sistem Yedekleri:"
    find "$backup_dir" -name "full_system_backup_*.tar.gz" -type f | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
}

# Eski yedekleri temizle
clean_old_backups() {
    draw_subheader "🗑️  Eski Yedekleri Temizle"
    
    backup_dir="/backup"
    if [[ ! -d "$backup_dir" ]]; then
        draw_error_box "Yedek dizini bulunamadı: $backup_dir"
        return
    fi
    
    echo "📋 Eski yedekler temizleniyor..."
    
    # 30 günden eski yedekleri bul
    old_backups=$(find "$backup_dir" -name "*.tar.gz" -type f -mtime +30)
    
    if [[ -z "$old_backups" ]]; then
        echo "✅ Eski yedek bulunamadı (30 günden eski)."
        return
    fi
    
    echo "📋 30 günden eski yedekler:"
    echo "$old_backups" | while read -r backup; do
        size=$(du -sh "$backup" | cut -f1)
        date_str=$(stat -c %y "$backup" | cut -d' ' -f1)
        echo "   📅 $date_str - $(basename "$backup") ($size)"
    done
    
    echo
    read -p "Bu yedekleri silmek istiyor musunuz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Temizleme iptal edildi."
        return
    fi
    
    freed_space=0
    deleted_count=0
    
    echo "$old_backups" | while read -r backup; do
        size=$(du -sk "$backup" | cut -f1)
        freed_space=$((freed_space + size))
        deleted_count=$((deleted_count + 1))
        
        echo "🗑️  $(basename "$backup") siliniyor..."
        rm -f "$backup"
    done
    
    freed_space_mb=$((freed_space / 1024))
    draw_success_box "Eski yedekler temizlendi!"
    echo "🗑️  Silinen yedek sayısı: $deleted_count"
    echo "💾 Boşalan alan: ${freed_space_mb}MB"
}

# Script çalıştır
main
