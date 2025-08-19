#!/bin/bash

# Ağ Durumu Modülü
# Ağ bağlantıları, IP adresleri ve ağ servislerini gösterir

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

# Ağ durumu gösterme fonksiyonu
show_network_status() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "🌐 AĞ DURUMU"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                    🌐 AĞ DURUMU                            ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Ağ arayüzleri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔌 AĞ ARAYÜZLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🔌 AĞ ARAYÜZLERİ:${THEME_RESET}"
    fi
    echo
    
    # ip komutu ile arayüz bilgileri
    if command -v ip &> /dev/null; then
        ip -4 addr show | grep -E "^[0-9]+:" | while read line; do
            interface=$(echo "$line" | awk '{print $2}' | sed 's/://')
            state=$(echo "$line" | awk '{print $9}')
            
            if [[ "$state" == "UP" ]]; then
                status="${THEME_SUCCESS}● AKTİF${THEME_RESET}"
            else
                status="${THEME_DANGER}✗ PASİF${THEME_RESET}"
            fi
            
            echo -e "   ${THEME_INFO}$interface${THEME_RESET}: $status"
            
            # IP adresleri
            ip -4 addr show "$interface" | grep "inet " | while read ip_line; do
                ip=$(echo "$ip_line" | awk '{print $2}')
                echo -e "      IP: ${THEME_SUCCESS}$ip${THEME_RESET}"
            done
            
            # MAC adresi
            mac=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
            if [[ -n "$mac" ]]; then
                echo -e "      MAC: ${THEME_WARNING}$mac${THEME_RESET}"
            fi
            
            echo
        done
    else
        echo -e "${THEME_DANGER}❌ 'ip' komutu bulunamadı${THEME_RESET}"
    fi
    
    # Ağ bağlantıları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🌍 AĞ BAĞLANTILARI"
    else
        echo -e "${THEME_SECONDARY}📋 🌍 AĞ BAĞLANTILARI:${THEME_RESET}"
    fi
    echo
    
    # Varsayılan gateway
    if command -v ip &> /dev/null; then
        default_gateway=$(ip route | grep default | awk '{print $3}' | head -1)
        if [[ -n "$default_gateway" ]]; then
            echo -e "   Varsayılan Gateway: ${THEME_SUCCESS}$default_gateway${THEME_RESET}"
            
            # Gateway'e ping testi
            if ping -c 1 -W 2 "$default_gateway" &>/dev/null; then
                if command -v show_status &> /dev/null; then
                    show_status "success" "Gateway erişilebilir"
                else
                    echo -e "   Gateway Durumu: ${THEME_SUCCESS}● ERİŞİLEBİLİR${THEME_RESET}"
                fi
            else
                if command -v show_status &> /dev/null; then
                    show_status "error" "Gateway erişilemez"
                else
                    echo -e "   Gateway Durumu: ${THEME_DANGER}✗ ERİŞİLEMEZ${THEME_RESET}"
                fi
            fi
        else
            if command -v show_status &> /dev/null; then
                show_status "error" "Varsayılan gateway bulunamadı"
            else
                echo -e "   Varsayılan Gateway: ${THEME_DANGER}✗ BULUNAMADI${THEME_RESET}"
            fi
        fi
    fi
    
    echo
    
    # DNS sunucuları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 DNS SUNUCULARI"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 DNS SUNUCULARI:${THEME_RESET}"
    fi
    
    if [[ -f /etc/resolv.conf ]]; then
        cat /etc/resolv.conf | grep "nameserver" | while read line; do
            dns=$(echo "$line" | awk '{print $2}')
            echo -e "   ${THEME_SUCCESS}$dns${THEME_RESET}"
        done
    fi
    echo
    
    # Açık portlar
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🚪 AÇIK PORTLAR"
    else
        echo -e "${THEME_SECONDARY}📋 🚪 AÇIK PORTLAR:${THEME_RESET}"
    fi
    
    echo -e "   (Sadece dinleyen portlar gösteriliyor...)"
    echo
    
    # netstat veya ss komutu ile port bilgileri
    if command -v ss &> /dev/null; then
        ss -tuln | grep LISTEN | head -10 | while read line; do
            protocol=$(echo "$line" | awk '{print $1}')
            local_address=$(echo "$line" | awk '{print $4}')
            state=$(echo "$line" | awk '{print $5}')
            
            # Port numarasını ayıkla
            port=$(echo "$local_address" | awk -F: '{print $NF}')
            
            # Servis adını bul
            service_name=$(grep ":$port/" /etc/services 2>/dev/null | head -1 | awk '{print $1}' || echo "bilinmeyen")
            
            echo -e "   ${THEME_INFO}$protocol${THEME_RESET} - ${THEME_SUCCESS}$local_address${THEME_RESET} ($service_name)"
        done
    elif command -v netstat &> /dev/null; then
        netstat -tuln | grep LISTEN | head -10 | while read line; do
            protocol=$(echo "$line" | awk '{print $1}')
            local_address=$(echo "$line" | awk '{print $4}')
            
            # Port numarasını ayıkla
            port=$(echo "$local_address" | awk -F: '{print $NF}')
            
            # Servis adını bul
            service_name=$(grep ":$port/" /etc/services 2>/dev/null | head -1 | awk '{print $1}' || echo "bilinmeyen")
            
            echo -e "   ${THEME_INFO}$protocol${THEME_RESET} - ${THEME_SUCCESS}$local_address${THEME_RESET} ($service_name)"
        done
    else
        echo -e "   ${THEME_DANGER}netstat veya ss komutu bulunamadı${THEME_RESET}"
    fi
    
    echo
    
    # Ağ hızı testi (basit)
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "⚡ AĞ HIZI TESTİ"
    else
        echo -e "${THEME_SECONDARY}📋 ⚡ AĞ HIZI TESTİ:${THEME_RESET}"
    fi
    
    echo -e "   (Basit ping testi yapılıyor...)"
    
    # Google DNS'e ping testi
    if ping -c 3 -W 2 8.8.8.8 &>/dev/null; then
        ping_result=$(ping -c 3 -W 2 8.8.8.8 | tail -1 | awk -F'/' '{print $5}')
        echo -e "   Google DNS (8.8.8.8): ${THEME_SUCCESS}${ping_result}ms${THEME_RESET}"
    else
        echo -e "   Google DNS (8.8.8.8): ${THEME_DANGER}✗ ERİŞİLEMEZ${THEME_RESET}"
    fi
    
    # Cloudflare DNS'e ping testi
    if ping -c 3 -W 2 1.1.1.1 &>/dev/null; then
        ping_result=$(ping -c 3 -W 2 1.1.1.1 | tail -1 | awk -F'/' '{print $5}')
        echo -e "   Cloudflare DNS (1.1.1.1): ${THEME_SUCCESS}${ping_result}ms${THEME_RESET}"
    else
        echo -e "   Cloudflare DNS (1.1.1.1): ${THEME_DANGER}✗ ERİŞİLEMEZ${THEME_RESET}"
    fi
    
    echo
    
    # Ağ trafiği (basit)
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📊 AĞ TRAFİĞİ"
    else
        echo -e "${THEME_SECONDARY}📋 📊 AĞ TRAFİĞİ:${THEME_RESET}"
    fi
    
    echo -e "   (Son 1 dakika için yaklaşık değerler...)"
    echo
    
    # /proc/net/dev'den basit trafik bilgisi
    if [[ -f /proc/net/dev ]]; then
        cat /proc/net/dev | grep -E "^(eth|wlan|en|wl)" | head -3 | while read line; do
            interface=$(echo "$line" | awk '{print $1}' | sed 's/://')
            rx_bytes=$(echo "$line" | awk '{print $2}')
            tx_bytes=$(echo "$line" | awk '{print $10}')
            
            # Byte'ları MB'a çevir
            rx_mb=$((rx_bytes / 1024 / 1024))
            tx_mb=$((tx_bytes / 1024 / 1024))
            
            echo -e "   ${THEME_INFO}$interface${THEME_RESET}:"
            echo -e "      Gelen: ${THEME_SUCCESS}${rx_mb} MB${THEME_RESET}"
            echo -e "      Giden: ${THEME_SUCCESS}${tx_mb} MB${THEME_RESET}"
        done
    fi
    
    echo
    
    # Ağ servisleri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔧 AĞ SERVİSLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🔧 AĞ SERVİSLERİ:${THEME_RESET}"
    fi
    
    local network_services=(
        "NetworkManager"
        "systemd-networkd"
        "systemd-resolved"
        "ufw"
        "iptables"
        "firewalld"
        "sshd"
        "apache2"
        "nginx"
    )
    
    for service in "${network_services[@]}"; do
        if command -v systemctl &> /dev/null; then
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
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Detaylı ağ bilgileri için 'ip addr show' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Detaylı ağ bilgileri için 'ip addr show' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_network_status
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
