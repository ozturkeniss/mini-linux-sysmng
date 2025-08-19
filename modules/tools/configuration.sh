#!/bin/bash

# Konfigürasyon Modülü
# Tema ayarları, kısayol ayarları ve genel konfigürasyon yönetimi

# Script dizini
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$SCRIPT_DIR/../../themes/default.sh"
CONFIG_FILE="$SCRIPT_DIR/../../config/sysmgmt.conf"

# Tema yükle
if [[ -f "$THEME_FILE" ]]; then
    source "$THEME_FILE"
else
    # Varsayılan renkler (tema bulunamadığında)
    THEME_PRIMARY='\033[0;34m'
    THEME_SECONDARY='\033[0;36m'
    THEME_SUCCESS='\033[0;32m'
    THEME_WARNING='\033[1;33m'
    THEME_DANGER='\033[0;31m'
    THEME_INFO='\033[0;35m'
    THEME_LIGHT='\033[0;37m'
    THEME_RESET='\033[0m'
fi

# Konfigürasyon dosyası oluştur
create_config_file() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << 'EOF'
# Mini Linux System Management Tool Konfigürasyon Dosyası

# Tema ayarları
THEME_NAME="Varsayılan Tema"
THEME_FILE="themes/default.sh"

# Arayüz ayarları
SHOW_THEME_INFO=true
SHOW_EMOJIS=true
SHOW_COLORS=true

# Kısayol ayarları
ENABLE_SHORTCUTS=true
SHORTCUT_KEY_1="1"
SHORTCUT_KEY_2="6"
SHORTCUT_KEY_3="10"

# Güvenlik ayarları
REQUIRE_ROOT_FOR_ADMIN=false
LOG_ACTIONS=true
BACKUP_CONFIG=true

# Performans ayarları
CACHE_ENABLED=true
CACHE_TIMEOUT=300
MAX_LOG_LINES=100
EOF
        echo -e "${THEME_SUCCESS}✅ Konfigürasyon dosyası oluşturuldu: $CONFIG_FILE${THEME_RESET}"
    fi
}

# Konfigürasyon gösterme fonksiyonu
show_configuration() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "⚙️  KONFİGÜRASYON"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                   ⚙️  KONFİGÜRASYON                         ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Konfigürasyon dosyası durumu
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📁 KONFİGÜRASYON DOSYASI"
    else
        echo -e "${THEME_SECONDARY}📋 📁 KONFİGÜRASYON DOSYASI:${THEME_RESET}"
    fi
    
    if [[ -f "$CONFIG_FILE" ]]; then
        if command -v show_status &> /dev/null; then
            show_status "success" "Konfigürasyon dosyası mevcut"
        else
            echo -e "${THEME_SUCCESS}✅ Konfigürasyon dosyası mevcut${THEME_RESET}"
        fi
        
        echo -e "   Dosya: ${THEME_INFO}$CONFIG_FILE${THEME_RESET}"
        echo -e "   Boyut: ${THEME_INFO}$(du -h "$CONFIG_FILE" | cut -f1)${THEME_RESET}"
        echo -e "   Son değişim: ${THEME_INFO}$(stat -c %y "$CONFIG_FILE" | cut -d' ' -f1,2 | cut -d'.' -f1)${THEME_RESET}"
        
        echo
        if command -v draw_subheader &> /dev/null; then
            draw_subheader "📋 KONFİGÜRASYON İÇERİĞİ"
        else
            echo -e "${THEME_SECONDARY}📋 📋 KONFİGÜRASYON İÇERİĞİ:${THEME_RESET}"
        fi
        
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────${THEME_RESET}"
        cat "$CONFIG_FILE" | while read line; do
            if [[ $line == \#* ]]; then
                echo -e "${THEME_INFO}$line${THEME_RESET}"
            elif [[ $line == *"="* ]]; then
                key=$(echo "$line" | cut -d'=' -f1)
                value=$(echo "$line" | cut -d'=' -f2-)
                echo -e "${THEME_SUCCESS}$key${THEME_RESET}=${THEME_LIGHT}$value${THEME_RESET}"
            else
                echo -e "${THEME_LIGHT}$line${THEME_RESET}"
            fi
        done
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────${THEME_RESET}"
        
    else
        if command -v show_status &> /dev/null; then
            show_status "warning" "Konfigürasyon dosyası bulunamadı"
        else
            echo -e "${THEME_WARNING}⚠️  Konfigürasyon dosyası bulunamadı${THEME_RESET}"
        fi
        
        echo -e "   ${THEME_INFO}Konfigürasyon dosyası oluşturulacak${THEME_RESET}"
        create_config_file
    fi
    
    echo
    
    # Tema ayarları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🎨 TEMA AYARLARI"
    else
        echo -e "${THEME_SECONDARY}📋 🎨 TEMA AYARLARI:${THEME_RESET}"
    fi
    
    # Mevcut temaları listele
    themes_dir="$SCRIPT_DIR/../../themes"
    if [[ -d "$themes_dir" ]]; then
        echo -e "   ${THEME_INFO}Mevcut temalar:${THEME_RESET}"
        for theme_file in "$themes_dir"/*.sh; do
            if [[ -f "$theme_file" ]]; then
                theme_name=$(basename "$theme_file" .sh)
                if [[ "$theme_name" == "default" ]]; then
                    echo -e "      ${THEME_SUCCESS}● $theme_name (varsayılan)${THEME_RESET}"
                else
                    echo -e "      ${THEME_LIGHT}○ $theme_name${THEME_RESET}"
                fi
            fi
        done
    else
        echo -e "   ${THEME_DANGER}Temalar dizini bulunamadı${THEME_RESET}"
    fi
    
    echo
    
    # Sistem bilgileri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🖥️  SİSTEM BİLGİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🖥️  SİSTEM BİLGİLERİ:${THEME_RESET}"
    fi
    
    echo -e "   İşletim Sistemi: ${THEME_SUCCESS}$(lsb_release -d | cut -f2 2>/dev/null || echo "Bilinmiyor")${THEME_RESET}"
    echo -e "   Kernel: ${THEME_SUCCESS}$(uname -r)${THEME_RESET}"
    echo -e "   Mimari: ${THEME_SUCCESS}$(uname -m)${THEME_RESET}"
    echo -e "   Bash Sürümü: ${THEME_SUCCESS}$(bash --version | head -1 | awk '{print $4}')${THEME_RESET}"
    
    echo
    
    # Konfigürasyon düzenleme
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "✏️  KONFİGÜRASYON DÜZENLEME"
    else
        echo -e "${THEME_SECONDARY}📋 ✏️  KONFİGÜRASYON DÜZENLEME:${THEME_RESET}"
    fi
    
    echo -e "   ${THEME_INFO}Ne yapmak istiyorsunuz?${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}1. Konfigürasyon dosyasını düzenle${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}2. Konfigürasyon dosyasını yeniden oluştur${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}3. Konfigürasyon yedekle${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}4. Tema değiştir${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}5. Çıkış${THEME_RESET}"
    echo
    
    echo -n "Seçiminiz (1-5): "
    read -r config_choice
    
    case $config_choice in
        1)
            if command -v nano &> /dev/null; then
                nano "$CONFIG_FILE"
            elif command -v vim &> /dev/null; then
                vim "$CONFIG_FILE"
            else
                echo -e "${THEME_WARNING}Metin editörü bulunamadı${THEME_RESET}"
                echo -e "${THEME_INFO}Konfigürasyon dosyası: $CONFIG_FILE${THEME_RESET}"
            fi
            ;;
        2)
            echo -e "${THEME_WARNING}⚠️  Mevcut konfigürasyon dosyası silinecek!${THEME_RESET}"
            echo -n "Devam etmek istiyor musunuz? (y/n): "
            read -r confirm
            if [[ "$confirm" == "y" ]]; then
                rm -f "$CONFIG_FILE"
                create_config_file
            fi
            ;;
        3)
            backup_file="$CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$CONFIG_FILE" "$backup_file"
            if command -v show_status &> /dev/null; then
                show_status "success" "Konfigürasyon yedeklendi: $backup_file"
            else
                echo -e "${THEME_SUCCESS}✅ Konfigürasyon yedeklendi: $backup_file${THEME_RESET}"
            fi
            ;;
        4)
            echo -e "${THEME_INFO}Tema değiştirme özelliği henüz geliştirilmedi${THEME_RESET}"
            ;;
        5)
            return
            ;;
        *)
            echo -e "${THEME_WARNING}Geçersiz seçim!${THEME_RESET}"
            ;;
    esac
    
    echo
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Konfigürasyon değişikliklerinin etkili olması için script'i yeniden başlatın"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Konfigürasyon değişikliklerinin etkili olması için script'i yeniden başlatın"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_configuration
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
