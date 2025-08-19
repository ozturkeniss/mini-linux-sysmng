#!/bin/bash

# Servis Durumu Modülü
# Sistemdeki servislerin durumunu gösterir

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

# Servis durumu gösterme fonksiyonu
show_service_status() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "🔧 SERVİS DURUMU"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                  🔧 SERVİS DURUMU                          ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Sistem servis yöneticisi kontrolü
    if command -v systemctl &> /dev/null; then
        if command -v show_status &> /dev/null; then
            show_status "success" "systemd kullanılıyor"
        else
            echo -e "${THEME_SUCCESS}✅ systemd kullanılıyor${THEME_RESET}"
        fi
        SERVICE_MANAGER="systemctl"
    elif command -v service &> /dev/null; then
        if command -v show_status &> /dev/null; then
            show_status "warning" "SysV init kullanılıyor"
        else
            echo -e "${THEME_WARNING}⚠️  SysV init kullanılıyor${THEME_RESET}"
        fi
        SERVICE_MANAGER="service"
    else
        if command -v show_status &> /dev/null; then
            show_status "error" "Servis yöneticisi bulunamadı!"
        else
            echo -e "${THEME_DANGER}❌ Servis yöneticisi bulunamadı!${THEME_RESET}"
        fi
        return 1
    fi
    
    echo
    
    # Yaygın servislerin durumu
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📋 YAYGIN SERVİSLERİN DURUMU"
    else
        echo -e "${THEME_SECONDARY}📋 📋 YAYGIN SERVİSLERİN DURUMU:${THEME_RESET}"
    fi
    echo
    
    local common_services=(
        "sshd"
        "cron"
        "rsyslog"
        "ufw"
        "apache2"
        "nginx"
        "mysql"
        "postgresql"
        "docker"
        "snapd"
        "NetworkManager"
        "systemd-resolved"
        "avahi-daemon"
        "cups"
        "bluetooth"
    )
    
    for service in "${common_services[@]}"; do
        if [[ "$SERVICE_MANAGER" == "systemctl" ]]; then
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                status="${THEME_SUCCESS}● AKTİF${THEME_RESET}"
            elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
                status="${THEME_WARNING}○ ETKİN${THEME_RESET}"
            else
                status="${THEME_DANGER}✗ DEVRE DIŞI${THEME_RESET}"
            fi
        else
            if service "$service" status &>/dev/null; then
                status="${THEME_SUCCESS}● AKTİF${THEME_RESET}"
            else
                status="${THEME_DANGER}✗ DEVRE DIŞI${THEME_RESET}"
            fi
        fi
        
        printf "   %-20s %s\n" "$service:" "$status"
    done
    
    echo
    
    # Tüm aktif servisler
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔄 AKTİF SERVİSLER (son 20)"
    else
        echo -e "${THEME_SECONDARY}📋 🔄 AKTİF SERVİSLER (son 20):${THEME_RESET}"
    fi
    
    if [[ "$SERVICE_MANAGER" == "systemctl" ]]; then
        systemctl list-units --type=service --state=running --no-pager --no-legend | head -20 | while read line; do
            service=$(echo "$line" | awk '{print $1}')
            description=$(echo "$line" | awk '{for(i=2;i<=NF;i++) printf $i" "; print ""}')
            echo -e "   ${THEME_SUCCESS}●${THEME_RESET} $service - $description"
        done
    else
        service --status-all 2>/dev/null | grep "\[ + \]" | head -20 | while read line; do
            service=$(echo "$line" | awk '{print $4}')
            echo -e "   ${THEME_SUCCESS}●${THEME_RESET} $service"
        done
    fi
    
    echo
    
    # Servis sayıları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📊 SERVİS İSTATİSTİKLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 📊 SERVİS İSTATİSTİKLERİ:${THEME_RESET}"
    fi
    
    if [[ "$SERVICE_MANAGER" == "systemctl" ]]; then
        total_services=$(systemctl list-units --type=service --all --no-pager --no-legend | wc -l)
        active_services=$(systemctl list-units --type=service --state=running --no-pager --no-legend | wc -l)
        enabled_services=$(systemctl list-units --type=service --state=enabled --no-pager --no-legend | wc -l)
        failed_services=$(systemctl list-units --type=service --state=failed --no-pager --no-legend | wc -l)
        
        echo -e "   Toplam servis: ${THEME_SUCCESS}$total_services${THEME_RESET}"
        echo -e "   Aktif servis: ${THEME_SUCCESS}$active_services${THEME_RESET}"
        echo -e "   Etkin servis: ${THEME_SUCCESS}$enabled_services${THEME_RESET}"
        echo -e "   Başarısız servis: ${THEME_DANGER}$failed_services${THEME_RESET}"
    fi
    
    echo
    
    # Başarısız servisler
    if [[ "$SERVICE_MANAGER" == "systemctl" ]] && [[ $failed_services -gt 0 ]]; then
        if command -v draw_subheader &> /dev/null; then
            draw_subheader "❌ BAŞARISIZ SERVİSLER"
        else
            echo -e "${THEME_SECONDARY}📋 ❌ BAŞARISIZ SERVİSLER:${THEME_RESET}"
        fi
        
        systemctl list-units --type=service --state=failed --no-pager --no-legend | while read line; do
            service=$(echo "$line" | awk '{print $1}')
            description=$(echo "$line" | awk '{for(i=2;i<=NF;i++) printf $i" "; print ""}')
            echo -e "   ${THEME_DANGER}✗${THEME_RESET} $service - $description"
        done
        echo
    fi
    
    # Servis arama
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 SERVİS ARA"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 SERVİS ARA:${THEME_RESET}"
    fi
    
    echo -n "Servis adı (boş bırakın): "
    read -r search_service
    
    if [[ -n "$search_service" ]]; then
        echo
        if [[ "$SERVICE_MANAGER" == "systemctl" ]]; then
            if systemctl list-unit-files "$search_service*" --no-pager --no-legend 2>/dev/null | grep -q "$search_service"; then
                if command -v show_status &> /dev/null; then
                    show_status "success" "Servis bulundu:"
                else
                    echo -e "${THEME_SUCCESS}✅ Servis bulundu:${THEME_RESET}"
                fi
                systemctl list-unit-files "$search_service*" --no-pager --no-legend
                echo
                if command -v draw_subheader &> /dev/null; then
                    draw_subheader "📋 Detaylı durum"
                else
                    echo -e "${THEME_SECONDARY}📋 📋 Detaylı durum:${THEME_RESET}"
                fi
                systemctl status "$search_service" --no-pager --lines=10
            else
                if command -v show_status &> /dev/null; then
                    show_status "error" "Servis bulunamadı: $search_service"
                else
                    echo -e "${THEME_DANGER}❌ Servis bulunamadı: $search_service${THEME_RESET}"
                fi
            fi
        else
            if service --status-all 2>/dev/null | grep -q "$search_service"; then
                if command -v show_status &> /dev/null; then
                    show_status "success" "Servis bulundu:"
                else
                    echo -e "${THEME_SUCCESS}✅ Servis bulundu:${THEME_RESET}"
                fi
                service "$search_service" status
            else
                if command -v show_status &> /dev/null; then
                    show_status "error" "Servis bulunamadı: $search_service"
                else
                    echo -e "${THEME_DANGER}❌ Servis bulunamadı: $search_service${THEME_RESET}"
                fi
            fi
        fi
    fi
    
    echo
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Servis durumunu sürekli izlemek için 'journalctl -f' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Servis durumunu sürekli izlemek için 'journalctl -f' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_service_status
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
