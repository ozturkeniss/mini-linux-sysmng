#!/bin/bash

# Paket Kurma Modülü
# Farklı paket yöneticileri ile paket kurma

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

# Paket yöneticisi tespiti
detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v emerge &> /dev/null; then
        echo "emerge"
    else
        echo "unknown"
    fi
}

# Paket yöneticisi bilgilerini göster
show_package_manager_info() {
    local pkg_mgr=$(detect_package_manager)
    
    case $pkg_mgr in
        "apt")
            if command -v show_status &> /dev/null; then
                show_status "success" "Debian/Ubuntu paket yöneticisi (apt)"
            else
                echo -e "${THEME_SUCCESS}✅ Debian/Ubuntu paket yöneticisi (apt)${THEME_RESET}"
            fi
            echo -e "   Güncelleme: ${THEME_INFO}sudo apt update${THEME_RESET}"
            echo -e "   Kurma: ${THEME_INFO}sudo apt install paket_adı${THEME_RESET}"
            echo -e "   Kaldırma: ${THEME_INFO}sudo apt remove paket_adı${THEME_RESET}"
            ;;
        "dnf")
            if command -v show_status &> /dev/null; then
                show_status "success" "Fedora paket yöneticisi (dnf)"
            else
                echo -e "${THEME_SUCCESS}✅ Fedora paket yöneticisi (dnf)${THEME_RESET}"
            fi
            echo -e "   Güncelleme: ${THEME_INFO}sudo dnf update${THEME_RESET}"
            echo -e "   Kurma: ${THEME_INFO}sudo dnf install paket_adı${THEME_RESET}"
            echo -e "   Kaldırma: ${THEME_INFO}sudo dnf remove paket_adı${THEME_RESET}"
            ;;
        "yum")
            if command -v show_status &> /dev/null; then
                show_status "success" "RHEL/CentOS paket yöneticisi (yum)"
            else
                echo -e "${THEME_SUCCESS}✅ RHEL/CentOS paket yöneticisi (yum)${THEME_RESET}"
            fi
            echo -e "   Güncelleme: ${THEME_INFO}sudo yum update${THEME_RESET}"
            echo -e "   Kurma: ${THEME_INFO}sudo yum install paket_adı${THEME_RESET}"
            echo -e "   Kaldırma: ${THEME_INFO}sudo yum remove paket_adı${THEME_RESET}"
            ;;
        "pacman")
            if command -v show_status &> /dev/null; then
                show_status "success" "Arch Linux paket yöneticisi (pacman)"
            else
                echo -e "${THEME_SUCCESS}✅ Arch Linux paket yöneticisi (pacman)${THEME_RESET}"
            fi
            echo -e "   Güncelleme: ${THEME_INFO}sudo pacman -Syu${THEME_RESET}"
            echo -e "   Kurma: ${THEME_INFO}sudo pacman -S paket_adı${THEME_RESET}"
            echo -e "   Kaldırma: ${THEME_INFO}sudo pacman -R paket_adı${THEME_RESET}"
            ;;
        "zypper")
            if command -v show_status &> /dev/null; then
                show_status "success" "openSUSE paket yöneticisi (zypper)"
            else
                echo -e "${THEME_SUCCESS}✅ openSUSE paket yöneticisi (zypper)${THEME_RESET}"
            fi
            echo -e "   Güncelleme: ${THEME_INFO}sudo zypper update${THEME_RESET}"
            echo -e "   Kurma: ${THEME_INFO}sudo zypper install paket_adı${THEME_RESET}"
            echo -e "   Kaldırma: ${THEME_INFO}sudo zypper remove paket_adı${THEME_RESET}"
            ;;
        "emerge")
            if command -v show_status &> /dev/null; then
                show_status "success" "Gentoo paket yöneticisi (emerge)"
            else
                echo -e "${THEME_SUCCESS}✅ Gentoo paket yöneticisi (emerge)${THEME_RESET}"
            fi
            echo -e "   Güncelleme: ${THEME_INFO}sudo emerge --sync${THEME_RESET}"
            echo -e "   Kurma: ${THEME_INFO}sudo emerge paket_adı${THEME_RESET}"
            echo -e "   Kaldırma: ${THEME_INFO}sudo emerge --unmerge paket_adı${THEME_RESET}"
            ;;
        *)
            if command -v show_status &> /dev/null; then
                show_status "error" "Bilinen paket yöneticisi bulunamadı!"
            else
                echo -e "${THEME_DANGER}❌ Bilinen paket yöneticisi bulunamadı!${THEME_RESET}"
            fi
            return 1
            ;;
    esac
    
    PKG_MANAGER=$pkg_mgr
}

# Paket kurma fonksiyonu
install_package() {
    local package_name="$1"
    
    if [[ -z "$package_name" ]]; then
        if command -v show_status &> /dev/null; then
            show_status "error" "Paket adı belirtilmedi!"
        else
            echo -e "${THEME_DANGER}❌ Paket adı belirtilmedi!${THEME_RESET}"
        fi
        return 1
    fi
    
    if command -v show_status &> /dev/null; then
        show_status "loading" "'$package_name' paketi kuruluyor..."
    else
        echo -e "${THEME_SECONDARY}🔄 '$package_name' paketi kuruluyor...${THEME_RESET}"
    fi
    
    case $PKG_MANAGER in
        "apt")
            sudo apt update && sudo apt install -y "$package_name"
            ;;
        "dnf")
            sudo dnf install -y "$package_name"
            ;;
        "yum")
            sudo yum install -y "$package_name"
            ;;
        "pacman")
            sudo pacman -S --noconfirm "$package_name"
            ;;
        "zypper")
            sudo zypper install -y "$package_name"
            ;;
        "emerge")
            sudo emerge "$package_name"
            ;;
        *)
            if command -v show_status &> /dev/null; then
                show_status "error" "Paket yöneticisi desteklenmiyor!"
            else
                echo -e "${THEME_DANGER}❌ Paket yöneticisi desteklenmiyor!${THEME_RESET}"
            fi
            return 1
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        if command -v show_status &> /dev/null; then
            show_status "success" "'$package_name' paketi başarıyla kuruldu!"
        else
            echo -e "${THEME_SUCCESS}✅ '$package_name' paketi başarıyla kuruldu!${THEME_RESET}"
        fi
    else
        if command -v show_status &> /dev/null; then
            show_status "error" "'$package_name' paketi kurulurken hata oluştu!"
        else
            echo -e "${THEME_DANGER}❌ '$package_name' paketi kurulurken hata oluştu!${THEME_RESET}"
        fi
    fi
}

# Paket arama fonksiyonu
search_package() {
    local search_term="$1"
    
    if [[ -z "$search_term" ]]; then
        if command -v show_status &> /dev/null; then
            show_status "error" "Arama terimi belirtilmedi!"
        else
            echo -e "${THEME_DANGER}❌ Arama terimi belirtilmedi!${THEME_RESET}"
        fi
        return 1
    fi
    
    if command -v show_status &> /dev/null; then
        show_status "loading" "'$search_term' için paket aranıyor..."
    else
        echo -e "${THEME_SECONDARY}🔍 '$search_term' için paket aranıyor...${THEME_RESET}"
    fi
    
    case $PKG_MANAGER in
        "apt")
            apt search "$search_term" | head -20
            ;;
        "dnf")
            dnf search "$search_term" | head -20
            ;;
        "yum")
            yum search "$search_term" | head -20
            ;;
        "pacman")
            pacman -Ss "$search_term" | head -20
            ;;
        "zypper")
            zypper search "$search_term" | head -20
            ;;
        "emerge")
            emerge --search "$search_term" | head -20
            ;;
        *)
            if command -v show_status &> /dev/null; then
                show_status "error" "Paket yöneticisi desteklenmiyor!"
            else
                echo -e "${THEME_DANGER}❌ Paket yöneticisi desteklenmiyor!${THEME_RESET}"
            fi
            return 1
            ;;
    esac
}

# Popüler paketler listesi
show_popular_packages() {
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📦 POPÜLER PAKETLER"
    else
        echo -e "${THEME_SECONDARY}📋 📦 POPÜLER PAKETLER:${THEME_RESET}"
    fi
    echo
    
    local packages=(
        "htop:Terminal tabanlı sistem monitörü"
        "neofetch:Sistem bilgilerini gösteren araç"
        "tree:Dizin yapısını ağaç şeklinde gösterir"
        "curl:HTTP istekleri için komut satırı aracı"
        "wget:Web'den dosya indirme aracı"
        "git:Versiyon kontrol sistemi"
        "vim:Gelişmiş metin editörü"
        "nano:Basit metin editörü"
        "unzip:ZIP dosyalarını açma aracı"
        "htop:Gelişmiş sistem monitörü"
    )
    
    for package in "${packages[@]}"; do
        name=$(echo "$package" | cut -d: -f1)
        description=$(echo "$package" | cut -d: -f2)
        echo -e "   ${THEME_SUCCESS}$name${THEME_RESET} - $description"
    done
    echo
}

# Ana menü
show_install_menu() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "📦 PAKET KURMA"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                   📦 PAKET KURMA                           ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    show_package_manager_info
    echo
    
    show_popular_packages
    
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 PAKET ARA VE KUR"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 PAKET ARA VE KUR:${THEME_RESET}"
    fi
    
    echo -n "Paket adı: "
    read -r package_name
    
    if [[ -n "$package_name" ]]; then
        echo
        install_package "$package_name"
    fi
    
    echo
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "🔍 PAKET ARA"
    else
        echo -e "${THEME_SECONDARY}📋 🔍 PAKET ARA:${THEME_RESET}"
    fi
    
    echo -n "Arama terimi: "
    read -r search_term
    
    if [[ -n "$search_term" ]]; then
        echo
        search_package "$search_term"
    fi
    
    echo
    if command -v draw_info_box &> /dev/null; then
        draw_info_box "💡 İpucu" "Paket bilgilerini görmek için 'apt show paket_adı' komutunu kullanabilirsiniz"
    else
        echo -e "${THEME_INFO}╔─ 💡 İpucu${THEME_RESET}"
        echo -e "${THEME_INFO}│${THEME_RESET} Paket bilgilerini görmek için 'apt show paket_adı' komutunu kullanabilirsiniz"
        echo -e "${THEME_INFO}╚${THEME_RESET}"
    fi
    echo
}

# Ana fonksiyon
main() {
    show_install_menu
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
