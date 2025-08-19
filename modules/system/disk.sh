#!/bin/bash

# Disk Kullanımı Modülü
# Disk alanı, inode kullanımı ve disk analizi

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

# Disk kullanımı gösterme fonksiyonu
show_disk_usage() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "💿 DISK KULLANIMI"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                    💿 DISK KULLANIMI                        ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Disk alanı genel durumu
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📊 DISK ALANI GENEL DURUMU"
    else
        echo -e "${THEME_SECONDARY}📋 📊 DISK ALANI GENEL DURUMU:${THEME_RESET}"
    fi
    
    if command -v df &> /dev/null; then
        if command -v draw_table_header &> /dev/null; then
            draw_table_header "Dosya Sistemi" "Boyut" "Kullanılan" "Boş" "Kullanım %" "Bağlama Noktası"
        else
            echo -e "${THEME_INFO}Dosya Sistemi\tBoyut\tKullanılan\tBoş\tKullanım %\tBağlama Noktası${THEME_RESET}"
            echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────────────────────${THEME_RESET}"
        fi
        
        df -h | grep -E "^/dev/" | while read line; do
            filesystem=$(echo "$line" | awk '{print $1}')
            size=$(echo "$line" | awk '{print $2}')
            used=$(echo "$line" | awk '{print $3}')
            available=$(echo "$line" | awk '{print $4}')
            use_percent=$(echo "$line" | awk '{print $5}')
            mount_point=$(echo "$line" | awk '{print $6}')
            
            # Kullanım yüzdesine göre renk
            local color
            if [[ ${use_percent%\%} -gt 90 ]]; then
                color=$THEME_DANGER
            elif [[ ${use_percent%\%} -gt 70 ]]; then
                color=$THEME_WARNING
            else
                color=$THEME_SUCCESS
            fi
            
            if command -v draw_table_row &> /dev/null; then
                draw_table_row "$filesystem" "$size" "$used" "$available" "${color}${use_percent}${THEME_RESET}" "$mount_point"
            else
                printf "%-20s %-8s %-10s %-8s %-12s %s\n" "$filesystem" "$size" "$used" "$available" "${color}${use_percent}${THEME_RESET}" "$mount_point"
            fi
        done
        
        if command -v draw_table_footer &> /dev/null; then
            draw_table_footer "Dosya Sistemi" "Boyut" "Kullanılan" "Boş" "Kullanım %" "Bağlama Noktası"
        else
            echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────────────────────${THEME_RESET}"
        fi
    fi
    
    echo
    
    # Inode kullanımı
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔗 INODE KULLANIMI"
    else
        echo -e "${THEME_SECONDARY}📋 🔗 INODE KULLANIMI:${THEME_RESET}"
    fi
    
    if command -v df &> /dev/null; then
        if command -v draw_table_header &> /dev/null; then
            draw_table_header "Dosya Sistemi" "Inode" "Kullanılan" "Boş" "Kullanım %" "Bağlama Noktası"
        else
            echo -e "${THEME_INFO}Dosya Sistemi\tInode\tKullanılan\tBoş\tKullanım %\tBağlama Noktası${THEME_RESET}"
            echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────────────────${THEME_RESET}"
        fi
        
        df -i | grep -E "^/dev/" | while read line; do
            filesystem=$(echo "$line" | awk '{print $1}')
            inodes=$(echo "$line" | awk '{print $2}')
            iused=$(echo "$line" | awk '{print $3}')
            ifree=$(echo "$line" | awk '{print $4}')
            iuse_percent=$(echo "$line" | awk '{print $5}')
            mount_point=$(echo "$line" | awk '{print $6}')
            
            # Inode kullanım yüzdesine göre renk
            local color
            if [[ ${iuse_percent%\%} -gt 90 ]]; then
                color=$THEME_DANGER
            elif [[ ${iuse_percent%\%} -gt 70 ]]; then
                color=$THEME_WARNING
            else
                color=$THEME_SUCCESS
            fi
            
            if command -v draw_table_row &> /dev/null; then
                draw_table_row "$filesystem" "$inodes" "$iused" "$ifree" "${color}${iuse_percent}${THEME_RESET}" "$mount_point"
            else
                printf "%-20s %-8s %-10s %-8s %-12s %s\n" "$filesystem" "$inodes" "$iused" "$ifree" "${color}${iuse_percent}${THEME_RESET}" "$mount_point"
            fi
        done
        
        if command -v draw_table_footer &> /dev/null; then
            draw_table_footer "Dosya Sistemi" "Inode" "Kullanılan" "Boş" "Kullanım %" "Bağlama Noktası"
        else
            echo -e "${THEME_BORDER}─────────────────────────────────────────────────────────────────────────────${THEME_RESET}"
        fi
    fi
    
    echo
    
    # En büyük dizinler
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📁 EN BÜYÜK DİZİNLER (/)"
    else
        echo -e "${THEME_SECONDARY}📋 📁 EN BÜYÜK DİZİNLER (/):${THEME_RESET}"
    fi
    
    if command -v du &> /dev/null; then
        echo -e "   (Analiz ediliyor, lütfen bekleyin...)"
        
        if command -v draw_table_header &> /dev/null; then
            draw_table_header "Boyut" "Dizin"
        else
            echo -e "${THEME_INFO}Boyut\tDizin${THEME_RESET}"
            echo -e "${THEME_BORDER}─────────────────────────${THEME_RESET}"
        fi
        
        sudo du -h --max-depth=1 / 2>/dev/null | sort -hr | head -11 | while read line; do
            size=$(echo "$line" | awk '{print $1}')
            dir=$(echo "$line" | awk '{print $2}')
            
            if [[ "$dir" == "/" ]]; then
                dir_name="ROOT (/)"
            else
                dir_name=$(basename "$dir")
            fi
            
            if command -v draw_table_row &> /dev/null; then
                draw_table_row "$size" "$dir_name"
            else
                printf "%-10s %s\n" "$size" "$dir_name"
            fi
        done
        
        if command -v draw_table_footer &> /dev/null; then
            draw_table_footer "Boyut" "Dizin"
        else
            echo -e "${THEME_BORDER}─────────────────────────${THEME_RESET}"
        fi
    fi
    
    echo
    
    # Disk I/O istatistikleri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "⚡ DISK I/O İSTATİSTİKLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 ⚡ DISK I/O İSTATİSTİKLERİ:${THEME_RESET}"
    fi
    
    if [[ -f /proc/diskstats ]]; then
        echo -e "   Disk\t\tOkuma\t\tYazma\t\tToplam"
        echo -e "   ──────────────────────────────────────────────────────────"
        
        cat /proc/diskstats | grep -E "^(sd|nvme|hd)" | head -5 | while read line; do
            disk=$(echo "$line" | awk '{print $3}')
            reads=$(echo "$line" | awk '{print $4}')
            read_sectors=$(echo "$line" | awk '{print $6}')
            read_time=$(echo "$line" | awk '{print $7}')
            writes=$(echo "$line" | awk '{print $8}')
            write_sectors=$(echo "$line" | awk '{print $10}')
            write_time=$(echo "$line" | awk '{print $11}')
            
            read_mb=$((read_sectors * 512 / 1024 / 1024))
            write_mb=$((write_sectors * 512 / 1024 / 1024))
            
            printf "   %-12s %8d (%4dMB)\t%8d (%4dMB)\t%8d\n" "$disk" "$reads" "$read_mb" "$writes" "$write_mb" "$((reads + writes))"
        done
    else
        echo -e "   ${THEME_DANGER}/proc/diskstats dosyası bulunamadı${THEME_RESET}"
    fi
    
    echo
    
    # Disk sağlığı (S.M.A.R.T)
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 DISK SAĞLIĞI (S.M.A.R.T)"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 DISK SAĞLIĞI (S.M.A.R.T):${THEME_RESET}"
    fi
    
    if command -v smartctl &> /dev/null; then
        echo -e "   (S.M.A.R.T bilgileri alınıyor...)"
        
        # Ana diskleri bul
        lsblk -d -n -o NAME | grep -E "^(sd|nvme|hd)" | head -3 | while read disk; do
            echo -e "   ${THEME_INFO}Disk: /dev/$disk${THEME_RESET}"
            
            if sudo smartctl -H "/dev/$disk" &>/dev/null; then
                health=$(sudo smartctl -H "/dev/$disk" | grep "SMART overall-health" | awk '{print $6}')
                if [[ "$health" == "PASSED" ]]; then
                    echo -e "      Durum: ${THEME_SUCCESS}● SAĞLIKLI${THEME_RESET}"
                else
                    echo -e "      Durum: ${THEME_DANGER}✗ SORUNLU${THEME_RESET}"
                fi
            else
                echo -e "      Durum: ${THEME_WARNING}⚠️  BİLGİ ALINAMADI${THEME_RESET}"
            fi
            echo
        done
    else
        echo -e "   ${THEME_WARNING}smartctl komutu bulunamadı${THEME_RESET}"
        echo -e "   ${THEME_INFO}Kurulum: sudo apt install smartmontools${THEME_RESET}"
    fi
    
    echo
    
    # Disk temizleme önerileri
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🧹 DISK TEMİZLEME ÖNERİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 🧹 DISK TEMİZLEME ÖNERİLERİ:${THEME_RESET}"
    fi
    
    # APT cache temizleme
    if command -v apt &> /dev/null; then
        apt_cache_size=$(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1)
        echo -e "   APT Cache: ${THEME_INFO}$apt_cache_size${THEME_RESET}"
        echo -e "      Temizleme: ${THEME_SUCCESS}sudo apt clean${THEME_RESET}"
    fi
    
    # Snap cache temizleme
    if command -v snap &> /dev/null; then
        snap_cache_size=$(du -sh /var/lib/snapd/cache 2>/dev/null | cut -f1)
        echo -e "   Snap Cache: ${THEME_INFO}$snap_cache_size${THEME_RESET}"
        echo -e "      Temizleme: ${THEME_SUCCESS}sudo snap set system refresh.retain=2${THEME_RESET}"
    fi
    
    # Log dosyaları
    log_size=$(du -sh /var/log 2>/dev/null | cut -f1)
    echo -e "   Log Dosyaları: ${THEME_INFO}$log_size${THEME_RESET}"
    echo -e "      Temizleme: ${THEME_SUCCESS}sudo journalctl --vacuum-time=7d${THEME_RESET}"
    
    echo
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Disk kullanımını sürekli izlemek için 'iotop' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Disk kullanımını sürekli izlemek için 'iotop' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_disk_usage
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
