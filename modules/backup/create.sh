#!/bin/bash

# Backup Oluşturma Modülü
# Bu modül sistem yedeği oluşturur

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
    draw_header "💾 Yedek Oluşturma Modülü"
    
    if ! check_root; then
        return
    fi
    
    while true; do
        echo
        draw_subheader "Yedek Seçenekleri:"
        echo "1. 📁 Dizin Yedeği"
        echo "2. 🗄️  Veritabanı Yedeği"
        echo "3. ⚙️  Konfigürasyon Yedeği"
        echo "4. 🔄 Tam Sistem Yedeği"
        echo "5. 📊 Yedek Durumu"
        echo "0. 🔙 Ana Menüye Dön"
        
        read -p "Seçiminizi yapın (0-5): " choice
        
        case $choice in
            1) create_directory_backup ;;
            2) create_database_backup ;;
            3) create_config_backup ;;
            4) create_full_backup ;;
            5) show_backup_status ;;
            0) break ;;
            *) echo "❌ Geçersiz seçim!" ;;
        esac
        
        if [[ $choice != 0 ]]; then
            echo
            read -p "Devam etmek için Enter'a basın..."
        fi
    done
}

# Dizin yedeği oluştur
create_directory_backup() {
    draw_subheader "📁 Dizin Yedeği Oluştur"
    
    read -p "Yedeklenecek dizin yolu: " source_dir
    if [[ ! -d "$source_dir" ]]; then
        draw_error_box "Dizin bulunamadı: $source_dir"
        return
    fi
    
    backup_name="dir_backup_$(date +%Y%m%d_%H%M%S)"
    backup_path="/backup/$backup_name"
    
    echo "📋 Yedek oluşturuluyor: $source_dir -> $backup_path"
    
    if tar -czf "$backup_path.tar.gz" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"; then
        draw_success_box "Dizin yedeği başarıyla oluşturuldu!"
        echo "📁 Yedek: $backup_path.tar.gz"
        echo "📏 Boyut: $(du -sh "$backup_path.tar.gz" | cut -f1)"
    else
        draw_error_box "Yedek oluşturulurken hata oluştu!"
    fi
}

# Veritabanı yedeği oluştur
create_database_backup() {
    draw_subheader "🗄️  Veritabanı Yedeği Oluştur"
    
    echo "📋 Mevcut veritabanları:"
    if command -v mysql &> /dev/null; then
        echo "   🟢 MySQL/MariaDB bulundu"
    fi
    if command -v psql &> /dev/null; then
        echo "   🟢 PostgreSQL bulundu"
    fi
    if command -v sqlite3 &> /dev/null; then
        echo "   🟢 SQLite bulundu"
    fi
    
    echo
    echo "💡 Veritabanı yedeği için ilgili komutları kullanın:"
    echo "   MySQL: mysqldump -u root -p database_name > backup.sql"
    echo "   PostgreSQL: pg_dump database_name > backup.sql"
    echo "   SQLite: sqlite3 database.db .dump > backup.sql"
}

# Konfigürasyon yedeği oluştur
create_config_backup() {
    draw_subheader "⚙️  Konfigürasyon Yedeği Oluştur"
    
    backup_name="config_backup_$(date +%Y%m%d_%H%M%S)"
    backup_path="/backup/$backup_name"
    
    echo "📋 Önemli konfigürasyon dosyaları yedekleniyor..."
    
    # Önemli konfigürasyon dizinleri
    config_dirs=("/etc/ssh" "/etc/nginx" "/etc/apache2" "/etc/mysql" "/etc/postgresql")
    
    mkdir -p "$backup_path"
    
    for dir in "${config_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            echo "   📁 $dir yedekleniyor..."
            cp -r "$dir" "$backup_path/"
        fi
    done
    
    # Önemli dosyalar
    important_files=("/etc/hosts" "/etc/fstab" "/etc/resolv.conf")
    for file in "${important_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "   📄 $file yedekleniyor..."
            cp "$file" "$backup_path/"
        fi
    done
    
    if tar -czf "$backup_path.tar.gz" -C "$(dirname "$backup_path")" "$(basename "$backup_path")"; then
        draw_success_box "Konfigürasyon yedeği başarıyla oluşturuldu!"
        echo "📁 Yedek: $backup_path.tar.gz"
        rm -rf "$backup_path"
    else
        draw_error_box "Yedek oluşturulurken hata oluştu!"
    fi
}

# Tam sistem yedeği oluştur
create_full_backup() {
    draw_subheader "🔄 Tam Sistem Yedeği Oluştur"
    
    draw_warning_box "Bu işlem çok zaman alabilir ve büyük disk alanı gerektirir!"
    
    read -p "Devam etmek istiyor musunuz? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ İşlem iptal edildi."
        return
    fi
    
    backup_name="full_system_backup_$(date +%Y%m%d_%H%M%S)"
    backup_path="/backup/$backup_name"
    
    echo "📋 Tam sistem yedeği oluşturuluyor..."
    echo "⏱️  Bu işlem uzun sürebilir..."
    
    # /etc, /home, /var/www gibi önemli dizinleri yedekle
    if tar -czf "$backup_path.tar.gz" --exclude=/proc --exclude=/sys --exclude=/tmp --exclude=/backup /etc /home /var/www /root; then
        draw_success_box "Tam sistem yedeği başarıyla oluşturuldu!"
        echo "📁 Yedek: $backup_path.tar.gz"
        echo "📏 Boyut: $(du -sh "$backup_path.tar.gz" | cut -f1)"
    else
        draw_error_box "Yedek oluşturulurken hata oluştu!"
    fi
}

# Yedek durumunu göster
show_backup_status() {
    draw_subheader "📊 Yedek Durumu"
    
    backup_dir="/backup"
    if [[ ! -d "$backup_dir" ]]; then
        echo "❌ Yedek dizini bulunamadı: $backup_dir"
        return
    fi
    
    echo "📁 Yedek dizini: $backup_dir"
    echo "📊 Toplam yedek sayısı: $(find "$backup_dir" -name "*.tar.gz" | wc -l)"
    echo "📏 Toplam yedek boyutu: $(du -sh "$backup_dir" | cut -f1)"
    
    echo
    echo "📋 Son yedekler:"
    find "$backup_dir" -name "*.tar.gz" -type f -printf "%T@ %p\n" | sort -nr | head -5 | while read timestamp file; do
        date_str=$(date -d "@$timestamp" "+%d/%m/%Y %H:%M")
        size=$(du -sh "$file" | cut -f1)
        echo "   📅 $date_str - $(basename "$file") ($size)"
    done
}

# Script çalıştır
main
