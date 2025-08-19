#!/bin/bash

# Mini Linux System Management Tool
# Ana script - Organize modül yönetimi ve menü sistemi

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script dizini ve modül yolları
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/sysmgmt.conf"
THEME_FILE="$SCRIPT_DIR/themes/default.sh"

# Modül dizinleri
SYSTEM_MODULES="$SCRIPT_DIR/modules/system"
USER_MODULES="$SCRIPT_DIR/modules/users"
SERVICE_MODULES="$SCRIPT_DIR/modules/services"
PACKAGE_MODULES="$SCRIPT_DIR/modules/packages"
FILE_MODULES="$SCRIPT_DIR/modules/files"
NETWORK_MODULES="$SCRIPT_DIR/modules/network"
LOG_MODULES="$SCRIPT_DIR/modules/logs"
BACKUP_MODULES="$SCRIPT_DIR/modules/backup"
TOOL_MODULES="$SCRIPT_DIR/modules/tools"

# Tema yükleme
load_theme() {
    if [[ -f "$THEME_FILE" ]]; then
        source "$THEME_FILE"
    fi
}

# Ana menü fonksiyonu
show_main_menu() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                MINI LINUX SYSTEM MANAGEMENT TOOL            ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}📊 SİSTEM YÖNETİMİ${NC}"
    echo "  1. Sistem Durumu"
    echo "  2. Donanım Bilgileri"
    echo "  3. Disk Kullanımı"
    echo "  4. Performans İzleme"
    echo
    echo -e "${PURPLE}👥 KULLANICI YÖNETİMİ${NC}"
    echo "  5. Kullanıcı Listesi"
    echo "  6. Kullanıcı Ekle"
    echo "  7. Kullanıcı Sil"
    echo "  8. Grup Yönetimi"
    echo "  9. İzin Yönetimi"
    echo
    echo -e "${YELLOW}🔧 SERVİS YÖNETİMİ${NC}"
    echo "  10. Servis Durumu"
    echo "  11. Servis Kontrolü"
    echo "  12. Servis Yapılandırması"
    echo "  13. Servis Logları"
    echo
    echo -e "${GREEN}📦 PAKET YÖNETİMİ${NC}"
    echo "  14. Paket Kur"
    echo "  15. Paket Güncelle"
    echo "  16. Paket Sil"
    echo "  17. Sistem Güncelleme"
    echo
    echo -e "${BLUE}📁 DOSYA YÖNETİMİ${NC}"
    echo "  18. Dosya İzinleri"
    echo "  19. Disk Temizleme"
    echo "  20. Dosya Arama"
    echo "  21. Dosya Yedekleme"
    echo
    echo -e "${CYAN}🌐 AĞ YÖNETİMİ${NC}"
    echo "  22. Ağ Durumu"
    echo "  23. Port Durumu"
    echo "  24. Firewall Durumu"
    echo "  25. Ağ İzleme"
    echo
    echo -e "${PURPLE}📋 LOG YÖNETİMİ${NC}"
    echo "  26. Sistem Logları"
    echo "  27. Güvenlik Logları"
    echo "  28. Servis Logları"
    echo "  29. Log Analizi"
    echo
    echo -e "${GREEN}💾 YEDEKLEME${NC}"
    echo "  30. Sistem Yedekleme"
    echo "  31. Dosya Yedekleme"
    echo "  32. Geri Yükleme"
    echo
    echo -e "${YELLOW}⚙️  ARAÇLAR${NC}"
    echo "  33. Konfigürasyon"
    echo "  34. Güncelleme Kontrolü"
    echo "  35. Sistem Tanılama"
    echo
    echo -e "${RED}  0. Çıkış${NC}"
    echo
    echo -e "${BLUE}══════════════════════════════════════════════════════════════${NC}"
}

# Modül çalıştırma fonksiyonu
run_module() {
    local module_path="$1"
    local module_name="$2"
    
    if [[ -f "$module_path" ]]; then
        echo -e "${BLUE}🔄 '$module_name' modülü çalıştırılıyor...${NC}"
        echo
        bash "$module_path"
    else
        echo -e "${RED}❌ Modül bulunamadı: $module_path${NC}"
        echo -e "${YELLOW}💡 Bu modül henüz oluşturulmadı.${NC}"
        read -p "Devam etmek için Enter'a basın..."
    fi
}

# Ana döngü
main() {
    # Root kontrolü
    if [[ $EUID -eq 0 ]]; then
        echo -e "${YELLOW}⚠️  Root olarak çalıştırılıyor${NC}"
        sleep 2
    fi
    
    # Tema yükle
    load_theme
    
    # Modül dizinlerini kontrol et
    local missing_dirs=()
    [[ ! -d "$SYSTEM_MODULES" ]] && missing_dirs+=("Sistem")
    [[ ! -d "$USER_MODULES" ]] && missing_dirs+=("Kullanıcı")
    [[ ! -d "$SERVICE_MODULES" ]] && missing_dirs+=("Servis")
    [[ ! -d "$PACKAGE_MODULES" ]] && missing_dirs+=("Paket")
    [[ ! -d "$FILE_MODULES" ]] && missing_dirs+=("Dosya")
    [[ ! -d "$NETWORK_MODULES" ]] && missing_dirs+=("Ağ")
    [[ ! -d "$LOG_MODULES" ]] && missing_dirs+=("Log")
    [[ ! -d "$BACKUP_MODULES" ]] && missing_dirs+=("Yedekleme")
    [[ ! -d "$TOOL_MODULES" ]] && missing_dirs+=("Araçlar")
    
    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Eksik modül dizinleri:${NC}"
        printf "   %s\n" "${missing_dirs[@]}"
        echo "Lütfen eksik dizinleri oluşturun."
        exit 1
    fi
    
    while true; do
        show_main_menu
        echo -n "Seçiminizi yapın (0-35): "
        read -r choice
        
        case $choice in
            0)  echo -e "${GREEN}👋 Güle güle!${NC}"; exit 0 ;;
            
            # Sistem Yönetimi
            1)  run_module "$SYSTEM_MODULES/status.sh" "Sistem Durumu" ;;
            2)  run_module "$SYSTEM_MODULES/hardware.sh" "Donanım Bilgileri" ;;
            3)  run_module "$SYSTEM_MODULES/disk.sh" "Disk Kullanımı" ;;
            4)  run_module "$SYSTEM_MODULES/performance.sh" "Performans İzleme" ;;
            
            # Kullanıcı Yönetimi
            5)  run_module "$USER_MODULES/list.sh" "Kullanıcı Listesi" ;;
            6)  run_module "$USER_MODULES/add.sh" "Kullanıcı Ekle" ;;
            7)  run_module "$USER_MODULES/delete.sh" "Kullanıcı Sil" ;;
            8)  run_module "$USER_MODULES/groups.sh" "Grup Yönetimi" ;;
            9)  run_module "$USER_MODULES/permissions.sh" "İzin Yönetimi" ;;
            
            # Servis Yönetimi
            10) run_module "$SERVICE_MODULES/status.sh" "Servis Durumu" ;;
            11) run_module "$SERVICE_MODULES/control.sh" "Servis Kontrolü" ;;
            12) run_module "$SERVICE_MODULES/config.sh" "Servis Yapılandırması" ;;
            13) run_module "$SERVICE_MODULES/logs.sh" "Servis Logları" ;;
            
            # Paket Yönetimi
            14) run_module "$PACKAGE_MODULES/install.sh" "Paket Kur" ;;
            15) run_module "$PACKAGE_MODULES/update.sh" "Paket Güncelle" ;;
            16) run_module "$PACKAGE_MODULES/remove.sh" "Paket Sil" ;;
            17) run_module "$PACKAGE_MODULES/system-update.sh" "Sistem Güncelleme" ;;
            
            # Dosya Yönetimi
            18) run_module "$FILE_MODULES/permissions.sh" "Dosya İzinleri" ;;
            19) run_module "$FILE_MODULES/cleanup.sh" "Disk Temizleme" ;;
            20) run_module "$FILE_MODULES/search.sh" "Dosya Arama" ;;
            21) run_module "$FILE_MODULES/backup.sh" "Dosya Yedekleme" ;;
            
            # Ağ Yönetimi
            22) run_module "$NETWORK_MODULES/status.sh" "Ağ Durumu" ;;
            23) run_module "$NETWORK_MODULES/ports.sh" "Port Durumu" ;;
            24) run_module "$NETWORK_MODULES/firewall.sh" "Firewall Durumu" ;;
            25) run_module "$NETWORK_MODULES/monitoring.sh" "Ağ İzleme" ;;
            
            # Log Yönetimi
            26) run_module "$LOG_MODULES/system.sh" "Sistem Logları" ;;
            27) run_module "$LOG_MODULES/security.sh" "Güvenlik Logları" ;;
            28) run_module "$LOG_MODULES/services.sh" "Servis Logları" ;;
            29) run_module "$LOG_MODULES/analysis.sh" "Log Analizi" ;;
            
            # Yedekleme
            30) run_module "$BACKUP_MODULES/system.sh" "Sistem Yedekleme" ;;
            31) run_module "$BACKUP_MODULES/files.sh" "Dosya Yedekleme" ;;
            32) run_module "$BACKUP_MODULES/restore.sh" "Geri Yükleme" ;;
            
            # Araçlar
            33) run_module "$TOOL_MODULES/configuration.sh" "Konfigürasyon" ;;
            34) run_module "$TOOL_MODULES/update-check.sh" "Güncelleme Kontrolü" ;;
            35) run_module "$TOOL_MODULES/diagnostics.sh" "Sistem Tanılama" ;;
            
            *)  echo -e "${RED}❌ Geçersiz seçim!${NC}"; sleep 2 ;;
        esac
        
        echo
        echo -e "${BLUE}Ana menüye dönmek için Enter'a basın...${NC}"
        read -r
    done
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
