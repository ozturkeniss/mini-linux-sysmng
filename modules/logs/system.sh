#!/bin/bash

# Sistem Logları Modülü
# journalctl ve /var/log dosyalarını gösterir

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

# Sistem logları gösterme fonksiyonu
show_system_logs() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "📋 SİSTEM LOGLARI"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                    📋 SİSTEM LOGLARI                        ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Log dosyaları genel durumu
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📁 LOG DOSYALARI GENEL DURUMU"
    else
        echo -e "${THEME_SECONDARY}📋 📁 LOG DOSYALARI GENEL DURUMU:${THEME_RESET}"
    fi
    
    if [[ -d /var/log ]]; then
        if command -v draw_table_header &> /dev/null; then
            draw_table_header "Log Dosyası" "Boyut" "Son Değişim" "Durum"
        else
            echo -e "${THEME_INFO}Log Dosyası\t\tBoyut\t\tSon Değişim\t\tDurum${THEME_RESET}"
            echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────────────${THEME_RESET}"
        fi
        
        local log_files=(
            "/var/log/syslog"
            "/var/log/auth.log"
            "/var/log/kern.log"
            "/var/log/dmesg"
            "/var/log/boot.log"
            "/var/log/daemon.log"
            "/var/log/messages"
            "/var/log/Xorg.0.log"
        )
        
        for log_file in "${log_files[@]}"; do
            if [[ -f "$log_file" ]]; then
                size=$(du -h "$log_file" 2>/dev/null | cut -f1)
                last_modified=$(stat -c %y "$log_file" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
                
                # Dosya boyutuna göre durum
                if [[ -n "$size" ]]; then
                    size_num=$(du "$log_file" 2>/dev/null | cut -f1)
                    if [[ $size_num -gt 1048576 ]]; then  # 1GB
                        status="${THEME_DANGER}⚠️  BÜYÜK${THEME_RESET}"
                    elif [[ $size_num -gt 104857 ]]; then  # 100MB
                        status="${THEME_WARNING}⚠️  ORTA${THEME_RESET}"
                    else
                        status="${THEME_SUCCESS}● NORMAL${THEME_RESET}"
                    fi
                else
                    status="${THEME_DANGER}✗ HATA${THEME_RESET}"
                fi
                
                if command -v draw_table_row &> /dev/null; then
                    draw_table_row "$(basename "$log_file")" "$size" "$last_modified" "$status"
                else
                    printf "%-20s %-10s %-20s %s\n" "$(basename "$log_file")" "$size" "$last_modified" "$status"
                fi
            fi
        done
        
        if command -v draw_table_footer &> /dev/null; then
            draw_table_footer "Log Dosyası" "Boyut" "Son Değişim" "Durum"
        else
            echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────────────${THEME_RESET}"
        fi
    fi
    
    echo
    
    # Journalctl logları
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📰 JOURNALCTL LOGLARI"
    else
        echo -e "${THEME_SECONDARY}📋 📰 JOURNALCTL LOGLARI:${THEME_RESET}"
    fi
    
    if command -v journalctl &> /dev/null; then
        echo -e "   ${THEME_INFO}Son sistem logları (son 20):${THEME_RESET}"
        echo
        
        # Son sistem logları
        journalctl --no-pager --lines=20 --priority=3..0 | while read line; do
            # Log seviyesine göre renk
            if [[ $line == *"emerg"* ]] || [[ $line == *"alert"* ]]; then
                color=$THEME_DANGER
                icon="🚨"
            elif [[ $line == *"crit"* ]] || [[ $line == *"err"* ]]; then
                color=$THEME_DANGER
                icon="❌"
            elif [[ $line == *"warning"* ]] || [[ $line == *"warn"* ]]; then
                color=$THEME_WARNING
                icon="⚠️"
            elif [[ $line == *"notice"* ]] || [[ $line == *"info"* ]]; then
                color=$THEME_INFO
                icon="ℹ️"
            else
                color=$THEME_LIGHT
                icon="•"
            fi
            
            echo -e "   $icon ${color}$line${THEME_RESET}"
        done
    else
        echo -e "   ${THEME_DANGER}journalctl komutu bulunamadı${THEME_RESET}"
    fi
    
    echo
    
    # Log dosyası içeriği
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 LOG DOSYASI İÇERİĞİ"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 LOG DOSYASI İÇERİĞİ:${THEME_RESET}"
    fi
    
    echo -e "   ${THEME_INFO}Hangi log dosyasını görüntülemek istiyorsunuz?${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}1. syslog (Genel sistem logları)${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}2. auth.log (Kimlik doğrulama logları)${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}3. kern.log (Kernel logları)${THEME_RESET}"
    echo -e "   ${THEME_LIGHT}4. Özel dosya${THEME_RESET}"
    echo
    
    echo -n "Seçiminiz (1-4): "
    read -r log_choice
    
    case $log_choice in
        1)
            log_file="/var/log/syslog"
            ;;
        2)
            log_file="/var/log/auth.log"
            ;;
        3)
            log_file="/var/log/kern.log"
            ;;
        4)
            echo -n "Log dosyası yolu: "
            read -r log_file
            ;;
        *)
            echo -e "${THEME_WARNING}Geçersiz seçim!${THEME_RESET}"
            return
            ;;
    esac
    
    if [[ -f "$log_file" ]]; then
        echo
        if command -v draw_subheader &> /dev/null; then
            draw_subheader "📄 $log_file (son 20 satır)"
        else
            echo -e "${THEME_SECONDARY}📋 📄 $log_file (son 20 satır):${THEME_RESET}"
        fi
        
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────${THEME_RESET}"
        
        # Log dosyasının son 20 satırını göster
        tail -20 "$log_file" | while read line; do
            # Hata mesajlarına göre renk
            if [[ $line == *"ERROR"* ]] || [[ $line == *"FAIL"* ]] || [[ $line == *"CRITICAL"* ]]; then
                color=$THEME_DANGER
            elif [[ $line == *"WARNING"* ]] || [[ $line == *"WARN"* ]]; then
                color=$THEME_WARNING
            elif [[ $line == *"INFO"* ]] || [[ $line == *"DEBUG"* ]]; then
                color=$THEME_INFO
            else
                color=$THEME_LIGHT
            fi
            
            echo -e "${color}$line${THEME_RESET}"
        done
        
        echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────${THEME_RESET}"
        
        echo
        echo -e "${THEME_INFO}📊 Dosya boyutu: $(du -h "$log_file" | cut -f1)${THEME_RESET}"
        echo -e "${THEME_INFO}📅 Son değişim: $(stat -c %y "$log_file" | cut -d' ' -f1,2 | cut -d'.' -f1)${THEME_RESET}"
        
    else
        if command -v show_status &> /dev/null; then
            show_status "error" "Log dosyası bulunamadı: $log_file"
        else
            echo -e "${THEME_DANGER}❌ Log dosyası bulunamadı: $log_file${THEME_RESET}"
        fi
    fi
    
    echo
    
    # Log temizleme önerileri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🧹 LOG TEMİZLEME ÖNERİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🧹 LOG TEMİZLEME ÖNERİLERİ:${THEME_RESET}"
    fi
    
    echo -e "   ${THEME_INFO}Journal logları:${THEME_RESET}"
    echo -e "      ${THEME_SUCCESS}sudo journalctl --vacuum-time=7d${THEME_RESET} (7 günden eski logları temizle)"
    echo -e "      ${THEME_SUCCESS}sudo journalctl --vacuum-size=100M${THEME_RESET} (100MB'dan fazla logları temizle)"
    
    echo
    echo -e "   ${THEME_INFO}Log dosyaları:${THEME_RESET}"
    echo -e "      ${THEME_SUCCESS}sudo truncate -s 0 /var/log/syslog${THEME_RESET} (syslog'u temizle)"
    echo -e "      ${THEME_SUCCESS}sudo truncate -s 0 /var/log/auth.log${THEME_RESET} (auth.log'u temizle)"
    
    echo
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Logları gerçek zamanlı izlemek için 'tail -f /var/log/syslog' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Logları gerçek zamanlı izlemek için 'tail -f /var/log/syslog' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_system_logs
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
