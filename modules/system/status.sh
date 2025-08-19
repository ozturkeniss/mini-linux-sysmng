#!/bin/bash

# Sistem Durumu Modülü
# CPU, RAM, disk, uptime, ağ bağlantıları bilgilerini gösterir

# Script dizini
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$SCRIPT_DIR/../../themes/default.sh"

# Tema yükle
if [[ -f "$THEME_FILE" ]]; then
    source "$THEME_FILE"
else
    # Varsayılan renkler (tema bulunamazsa)
    THEME_PRIMARY='\033[0;34m'
    THEME_SECONDARY='\033[0;36m'
    THEME_SUCCESS='\033[0;32m'
    THEME_WARNING='\033[1;33m'
    THEME_DANGER='\033[0;31m'
    THEME_INFO='\033[0;35m'
    THEME_LIGHT='\033[0;37m'
    THEME_RESET='\033[0m'
fi

# Sistem durumu gösterme fonksiyonu
show_system_status() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "📊 SİSTEM DURUMU"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                    📊 SİSTEM DURUMU                        ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Sistem bilgileri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🖥️  SİSTEM BİLGİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🖥️  SİSTEM BİLGİLERİ:${THEME_RESET}"
    fi
    
    # Hostname
    local hostname=$(hostname)
    echo -e "   Hostname: ${THEME_SUCCESS}$hostname${THEME_RESET}"
    
    # İşletim sistemi
    if command -v lsb_release &> /dev/null; then
        local os_info=$(lsb_release -d | cut -f2)
        echo -e "   İşletim Sistemi: ${THEME_SUCCESS}$os_info${THEME_RESET}"
    else
        local os_info=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d'"' -f2)
        echo -e "   İşletim Sistemi: ${THEME_SUCCESS}$os_info${THEME_RESET}"
    fi
    
    # Kernel
    local kernel=$(uname -r)
    echo -e "   Kernel: ${THEME_SUCCESS}$kernel${THEME_RESET}"
    
    # Mimari
    local arch=$(uname -m)
    echo -e "   Mimari: ${THEME_SUCCESS}$arch${THEME_RESET}"
    
    echo
    
    # Uptime
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "⏰ UPTIME"
    else
        echo -e "${THEME_SECONDARY}📋 ⏰ UPTIME:${THEME_RESET}"
    fi
    
    local uptime_info=$(uptime | sed 's/up/Çalışma süresi:/' | sed 's/load average/Yük ortalaması:/')
    echo -e "   $uptime_info"
    echo
    
    # CPU bilgileri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔲 CPU BİLGİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🔲 CPU BİLGİLERİ:${THEME_RESET}"
    fi
    
    # CPU modeli
    if [[ -f /proc/cpuinfo ]]; then
        local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        echo -e "   Model: ${THEME_SUCCESS}$cpu_model${THEME_RESET}"
    fi
    
    # Çekirdek sayısı
    if command -v nproc &> /dev/null; then
        local cores=$(nproc)
        echo -e "   Çekirdek sayısı: ${THEME_SUCCESS}$cores${THEME_RESET}"
    fi
    
    # CPU kullanımı
    if command -v top &> /dev/null; then
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
        echo -e "   CPU kullanımı: ${THEME_SUCCESS}${cpu_usage}%${THEME_RESET}"
    fi
    
    echo
    
    # RAM bilgileri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "💾 RAM BİLGİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 💾 RAM BİLGİLERİ:${THEME_RESET}"
    fi
    
    if command -v free &> /dev/null; then
        free -h | grep -E "Mem|Swap" | while read line; do
            if [[ $line == *"Mem"* ]]; then
                echo -e "   RAM: ${THEME_SUCCESS}$line${THEME_RESET}"
            else
                echo -e "   Swap: ${THEME_SUCCESS}$line${THEME_RESET}"
            fi
        done
    fi
    echo
    
    # Disk kullanımı
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "💿 DISK KULLANIMI"
    else
        echo -e "${THEME_SECONDARY}📋 💿 DISK KULLANIMI:${THEME_RESET}"
    fi
    
    if command -v df &> /dev/null; then
        df -h | grep -E "^/dev/" | head -5 | while read line; do
            local filesystem=$(echo $line | awk '{print $1}')
            local size=$(echo $line | awk '{print $2}')
            local used=$(echo $line | awk '{print $3}')
            local available=$(echo $line | awk '{print $4}')
            local use_percent=$(echo $line | awk '{print $5}')
            local mount_point=$(echo $line | awk '{print $6}')
            
            # Kullanım yüzdesine göre renk
            local color
            if [[ ${use_percent%\%} -gt 90 ]]; then
                color=$THEME_DANGER
            elif [[ ${use_percent%\%} -gt 70 ]]; then
                color=$THEME_WARNING
            else
                color=$THEME_SUCCESS
            fi
            
            echo -e "   $mount_point: ${color}$use_percent${THEME_RESET} kullanılıyor ($used/$size)"
        done
    fi
    echo
    
    # Ağ bağlantıları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🌐 AĞ BAĞLANTILARI"
    else
        echo -e "${THEME_SECONDARY}📋 🌐 AĞ BAĞLANTILARI:${THEME_RESET}"
    fi
    
    if command -v ip &> /dev/null; then
        ip -4 addr show | grep "inet " | head -3 | while read line; do
            local interface=$(echo $line | awk '{print $NF}')
            local ip=$(echo $line | awk '{print $2}' | cut -d'/' -f1)
            echo -e "   $interface: ${THEME_SUCCESS}$ip${THEME_RESET}"
        done
    fi
    echo
    
    # Son giriş yapan kullanıcılar
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "👤 SON GİRİŞ YAPAN KULLANICILAR"
    else
        echo -e "${THEME_SECONDARY}📋 👤 SON GİRİŞ YAPAN KULLANICILAR:${THEME_RESET}"
    fi
    
    if command -v who &> /dev/null; then
        who | head -5 | while read line; do
            local user=$(echo $line | awk '{print $1}')
            local terminal=$(echo $line | awk '{print $2}')
            local time=$(echo $line | awk '{print $3" "$4}')
            echo -e "   $user ($terminal) - $time"
        done
    fi
    echo
    
    # Sistem yükü
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📈 SİSTEM YÜKÜ (son 1, 5, 15 dakika)"
    else
        echo -e "${THEME_SECONDARY}📋 📈 SİSTEM YÜKÜ (son 1, 5, 15 dakika):${THEME_RESET}"
    fi
    
    local load=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    echo -e "   ${THEME_SUCCESS}$load${THEME_RESET}"
    echo
    
    # Alt bilgi
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Sistem durumunu sürekli izlemek için 'htop' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Sistem durumunu sürekli izlemek için 'htop' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_system_status
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
