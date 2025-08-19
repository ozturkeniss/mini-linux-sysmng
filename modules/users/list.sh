#!/bin/bash

# Kullanıcı Listesi Modülü
# Sistemdeki kullanıcıları listeler ve detay bilgilerini gösterir

# Script dizini
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$SCRIPT_DIR/../../themes/default.sh"

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

# Kullanıcı listesi gösterme fonksiyonu
show_user_list() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "👥 KULLANICI LİSTESİ"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                   👥 KULLANICI LİSTESİ                      ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Toplam kullanıcı sayısı
    local total_users=$(getent passwd | wc -l)
    local system_users=$(getent passwd | awk -F: '$3 < 1000 {print}' | wc -l)
    local regular_users=$(getent passwd | awk -F: '$3 >= 1000 {print}' | wc -l)
    
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📊 KULLANICI İSTATİSTİKLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 📊 KULLANICI İSTATİSTİKLERİ:${THEME_RESET}"
    fi
    
    echo -e "   Toplam kullanıcı: ${THEME_SUCCESS}$total_users${THEME_RESET}"
    echo -e "   Sistem kullanıcıları: ${THEME_INFO}$system_users${THEME_RESET}"
    echo -e "   Normal kullanıcılar: ${THEME_SUCCESS}$regular_users${THEME_RESET}"
    echo
    
    # Normal kullanıcılar (UID >= 1000)
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "👤 NORMAL KULLANICILAR (UID >= 1000)"
    else
        echo -e "${THEME_SECONDARY}📋 👤 NORMAL KULLANICILAR (UID >= 1000):${THEME_RESET}"
    fi
    
    if command -v draw_table_header &> /dev/null; then
        draw_table_header "Kullanıcı" "UID" "GID" "Tam Ad" "Shell" "Home"
    else
        echo -e "${THEME_INFO}Kullanıcı\tUID\tGID\tTam Ad\t\tShell\t\tHome${THEME_RESET}"
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────${THEME_RESET}"
    fi
    
    getent passwd | awk -F: '$3 >= 1000 {print $1, $3, $4, $5, $7, $6}' | while read username uid gid fullname shell home; do
        if command -v draw_table_row &> /dev/null; then
            draw_table_row "$username" "$uid" "$gid" "${fullname:0:15}" "${shell##*/}" "${home##*/}"
        else
            printf "%-15s %-8s %-8s %-15s %-12s %s\n" "$username" "$uid" "$gid" "${fullname:0:15}" "${shell##*/}" "${home##*/}"
        fi
    done
    
    if command -v draw_table_footer &> /dev/null; then
        draw_table_footer "Kullanıcı" "UID" "GID" "Tam Ad" "Shell" "Home"
    else
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────${THEME_RESET}"
    fi
    
    echo
    
    # Sistem kullanıcıları (UID < 1000)
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "⚙️  SİSTEM KULLANICILARI (UID < 1000)"
    else
        echo -e "${THEME_SECONDARY}📋 ⚙️  SİSTEM KULLANICILARI (UID < 1000):${THEME_RESET}"
    fi
    
    if command -v draw_table_header &> /dev/null; then
        draw_table_header "Kullanıcı" "UID" "GID" "Açıklama" "Shell"
    else
        echo -e "${THEME_INFO}Kullanıcı\tUID\tGID\tAçıklama\t\tShell${THEME_RESET}"
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────${THEME_RESET}"
    fi
    
    getent passwd | awk -F: '$3 < 1000 {print $1, $3, $4, $5, $7}' | head -10 | while read username uid gid fullname shell; do
        if command -v draw_table_row &> /dev/null; then
            draw_table_row "$username" "$uid" "$gid" "${fullname:0:20}" "${shell##*/}"
        else
            printf "%-15s %-8s %-8s %-20s %s\n" "$username" "$uid" "$gid" "${fullname:0:20}" "${shell##*/}"
        fi
    done
    
    if command -v draw_table_footer &> /dev/null; then
        draw_table_footer "Kullanıcı" "UID" "GID" "Açıklama" "Shell"
    else
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────${THEME_RESET}"
    fi
    
    echo
    
    # Son giriş yapan kullanıcılar
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🕐 SON GİRİŞ YAPAN KULLANICILAR"
    else
        echo -e "${THEME_SECONDARY}📋 🕐 SON GİRİŞ YAPAN KULLANICILAR:${THEME_RESET}"
    fi
    
    if command -v who &> /dev/null; then
        who | while read line; do
            user=$(echo "$line" | awk '{print $1}')
            terminal=$(echo "$line" | awk '{print $2}')
            time=$(echo "$line" | awk '{print $3" "$4}')
            echo -e "   ${THEME_SUCCESS}$user${THEME_RESET} ($terminal) - $time"
        done
    else
        echo -e "   ${THEME_DANGER}who komutu bulunamadı${THEME_RESET}"
    fi
    
    echo
    
    # Kullanıcı detayları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 KULLANICI DETAYLARI"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 KULLANICI DETAYLARI:${THEME_RESET}"
    fi
    
    echo -n "Kullanıcı adı (boş bırakın): "
    read -r search_user
    
    if [[ -n "$search_user" ]]; then
        echo
        if id "$search_user" &>/dev/null; then
            if command -v show_status &> /dev/null; then
                show_status "success" "Kullanıcı bulundu:"
            else
                echo -e "${THEME_SUCCESS}✅ Kullanıcı bulundu:${THEME_RESET}"
            fi
            
            echo
            echo -e "${THEME_INFO}📋 KULLANICI BİLGİLERİ:${THEME_RESET}"
            id "$search_user"
            
            echo
            echo -e "${THEME_INFO}📁 HOME DİZİNİ:${THEME_RESET}"
            home_dir=$(eval echo ~$search_user)
            echo -e "   $home_dir"
            
            if [[ -d "$home_dir" ]]; then
                echo -e "   ${THEME_SUCCESS}● Dizin mevcut${THEME_RESET}"
                echo -e "   Boyut: $(du -sh "$home_dir" 2>/dev/null | cut -f1)"
            else
                echo -e "   ${THEME_DANGER}✗ Dizin mevcut değil${THEME_RESET}"
            fi
            
            echo
            echo -e "${THEME_INFO}🔐 ŞİFRE DURUMU:${THEME_RESET}"
            if sudo passwd -S "$search_user" 2>/dev/null; then
                echo -e "   ${THEME_SUCCESS}✅ Şifre bilgileri alındı${THEME_RESET}"
            else
                echo -e "   ${THEME_WARNING}⚠️  Şifre bilgileri alınamadı${THEME_RESET}"
            fi
            
            echo
            echo -e "${THEME_INFO}👥 GRUP ÜYELİKLERİ:${THEME_RESET}"
            groups "$search_user"
            
        else
            if command -v show_status &> /dev/null; then
                show_status "error" "Kullanıcı bulunamadı: $search_user"
            else
                echo -e "${THEME_DANGER}❌ Kullanıcı bulunamadı: $search_user${THEME_RESET}"
            fi
        fi
    fi
    
    echo
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Kullanıcı bilgilerini düzenlemek için 'usermod' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Kullanıcı bilgilerini düzenlemek için 'usermod' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_user_list
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
