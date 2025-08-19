#!/bin/bash

# Kullanıcı Ekleme Modülü
# Yeni kullanıcı ekleme, şifre belirleme ve grup atama

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

# Root kontrolü
check_root() {
    if [[ $EUID -ne 0 ]]; then
        if command -v draw_error_box &> /dev/null; then
            draw_error_box "Bu işlem için root yetkisi gereklidir!"
        else
            echo -e "${THEME_DANGER}❌ Bu işlem için root yetkisi gereklidir!${THEME_RESET}"
        fi
        echo "Lütfen 'sudo' ile çalıştırın."
        exit 1
    fi
}

# Kullanıcı ekleme fonksiyonu
add_user() {
    clear
    
    # Tema bilgilerini göster
    if command -v show_theme_info &> /dev/null; then
        show_theme_info
        echo
    fi
    
    # Ana başlık
    if command -v draw_header &> /dev/null; then
        draw_header "👤 KULLANICI EKLEME"
    else
        echo -e "${THEME_PRIMARY}╔══════════════════════════════════════════════════════════════╗${THEME_RESET}"
        echo -e "${THEME_PRIMARY}║                   👤 KULLANICI EKLEME                      ║${THEME_RESET}"
        echo -e "${THEME_PRIMARY}╚══════════════════════════════════════════════════════════════╝${THEME_RESET}"
    fi
    echo
    
    # Kullanıcı adı alma
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📝 KULLANICI BİLGİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 📝 KULLANICI BİLGİLERİ:${THEME_RESET}"
    fi
    
    while true; do
        echo -n "Kullanıcı adı: "
        read -r username
        
        if [[ -z "$username" ]]; then
            if command -v show_status &> /dev/null; then
                show_status "error" "Kullanıcı adı boş olamaz!"
            else
                echo -e "${THEME_DANGER}❌ Kullanıcı adı boş olamaz!${THEME_RESET}"
            fi
            continue
        fi
        
        if id "$username" &>/dev/null; then
            if command -v show_status &> /dev/null; then
                show_status "error" "'$username' kullanıcısı zaten mevcut!"
            else
                echo -e "${THEME_DANGER}❌ '$username' kullanıcısı zaten mevcut!${THEME_RESET}"
            fi
            continue
        fi
        
        # Kullanıcı adı format kontrolü
        if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            if command -v show_status &> /dev/null; then
                show_status "error" "Geçersiz kullanıcı adı formatı!"
            else
                echo -e "${THEME_DANGER}❌ Geçersiz kullanıcı adı formatı!${THEME_RESET}"
            fi
            echo "   Sadece küçük harf, rakam, alt çizgi ve tire kullanabilirsiniz."
            echo "   İlk karakter harf veya alt çizgi olmalıdır."
            continue
        fi
        
        break
    done
    
    echo
    
    # Tam ad alma
    echo -n "Tam ad (opsiyonel): "
    read -r fullname
    
    echo
    
    # Ana grup seçimi
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "👥 GRUP SEÇİMİ"
    else
        echo -e "${THEME_SECONDARY}📋 👥 GRUP SEÇİMİ:${THEME_RESET}"
    fi
    
    echo -e "${THEME_INFO}Mevcut gruplar:${THEME_RESET}"
    getent group | grep -E "^(users|sudo|admin|wheel)" | cut -d: -f1 | while read group; do
        echo -e "   - ${THEME_SUCCESS}$group${THEME_RESET}"
    done
    echo
    
    echo -n "Ana grup (varsayılan: users): "
    read -r primary_group
    primary_group=${primary_group:-users}
    
    # Grubun var olup olmadığını kontrol et
    if ! getent group "$primary_group" &>/dev/null; then
        if command -v show_status &> /dev/null; then
            show_status "warning" "'$primary_group' grubu mevcut değil, oluşturuluyor..."
        else
            echo -e "${THEME_WARNING}⚠️  '$primary_group' grubu mevcut değil, oluşturuluyor...${THEME_RESET}"
        fi
        groupadd "$primary_group"
    fi
    
    echo
    
    # Ek gruplar
    echo -n "Ek gruplar (virgülle ayırın, opsiyonel): "
    read -r additional_groups
    
    echo
    
    # Home dizini oluşturma seçeneği
    echo -n "Home dizini oluşturulsun mu? (y/n, varsayılan: y): "
    read -r create_home
    create_home=${create_home:-y}
    
    echo
    
    # Şifre seçeneği
    echo -n "Şifre belirlensin mi? (y/n, varsayılan: y): "
    read -r set_password
    set_password=${set_password:-y}
    
    echo
    
    # Onay
    if command -v draw_subheader &> /dev/null; then
        draw_subheader "📋 KULLANICI BİLGİLERİ"
    else
        echo -e "${THEME_SECONDARY}📋 📋 KULLANICI BİLGİLERİ:${THEME_RESET}"
    fi
    
    echo -e "   Kullanıcı adı: ${THEME_SUCCESS}$username${THEME_RESET}"
    echo -e "   Tam ad: ${THEME_SUCCESS}${fullname:-"Belirtilmedi"}${THEME_RESET}"
    echo -e "   Ana grup: ${THEME_SUCCESS}$primary_group${THEME_RESET}"
    echo -e "   Ek gruplar: ${THEME_SUCCESS}${additional_groups:-"Yok"}${THEME_RESET}"
    echo -e "   Home dizini: ${THEME_SUCCESS}$([[ "$create_home" == "y" ]] && echo "Oluşturulacak" || echo "Oluşturulmayacak")${THEME_RESET}"
    echo -e "   Şifre: ${THEME_SUCCESS}$([[ "$set_password" == "y" ]] && echo "Belirlenecek" || echo "Belirlenmeyecek")${THEME_RESET}"
    echo
    
    echo -n "Devam etmek istiyor musunuz? (y/n): "
    read -r confirm
    
    if [[ "$confirm" != "y" ]]; then
        if command -v show_status &> /dev/null; then
            show_status "warning" "İşlem iptal edildi."
        else
            echo -e "${THEME_WARNING}❌ İşlem iptal edildi.${THEME_RESET}"
        fi
        return
    fi
    
    echo
    
    # Kullanıcı oluşturma
    if command -v show_status &> /dev/null; then
        show_status "loading" "'$username' kullanıcısı oluşturuluyor..."
    else
        echo -e "${THEME_SECONDARY}🔄 '$username' kullanıcısı oluşturuluyor...${THEME_RESET}"
    fi
    
    local useradd_cmd="useradd"
    
    if [[ "$create_home" == "y" ]]; then
        useradd_cmd="$useradd_cmd -m"
    fi
    
    if [[ -n "$fullname" ]]; then
        useradd_cmd="$useradd_cmd -c \"$fullname\""
    fi
    
    useradd_cmd="$useradd_cmd -g \"$primary_group\" \"$username\""
    
    if eval $useradd_cmd; then
        if command -v show_status &> /dev/null; then
            show_status "success" "Kullanıcı başarıyla oluşturuldu!"
        else
            echo -e "${THEME_SUCCESS}✅ Kullanıcı başarıyla oluşturuldu!${THEME_RESET}"
        fi
        
        # Ek grupları ekle
        if [[ -n "$additional_groups" ]]; then
            if command -v show_status &> /dev/null; then
                show_status "loading" "Ek gruplar ekleniyor..."
            else
                echo -e "${THEME_SECONDARY}🔄 Ek gruplar ekleniyor...${THEME_RESET}"
            fi
            
            IFS=',' read -ra groups <<< "$additional_groups"
            for group in "${groups[@]}"; do
                group=$(echo "$group" | xargs)  # Boşlukları temizle
                if getent group "$group" &>/dev/null; then
                    usermod -a -G "$group" "$username"
                    echo -e "   ✅ '$group' grubuna eklendi"
                else
                    echo -e "   ⚠️  '$group' grubu bulunamadı, atlandı"
                fi
            done
        fi
        
        # Şifre belirleme
        if [[ "$set_password" == "y" ]]; then
            if command -v show_status &> /dev/null; then
                show_status "loading" "Şifre belirleniyor..."
            else
                echo -e "${THEME_SECONDARY}🔐 Şifre belirleniyor...${THEME_RESET}"
            fi
            passwd "$username"
        fi
        
        echo
        if command -v draw_success_box &> /dev/null; then
            draw_success_box "Kullanıcı '$username' başarıyla oluşturuldu!"
        else
            echo -e "${THEME_SUCCESS}🎉 Kullanıcı '$username' başarıyla oluşturuldu!${THEME_RESET}"
        fi
        echo
        
        if command -v draw_subheader &> /dev/null; then
            draw_subheader "📋 KULLANICI BİLGİLERİ"
        else
            echo -e "${THEME_SECONDARY}📋 📋 KULLANICI BİLGİLERİ:${THEME_RESET}"
        fi
        
        id "$username"
        echo
        
        if command -v draw_subheader &> /dev/null; then
            draw_subheader "📁 HOME DİZİNİ"
        else
            echo -e "${THEME_SECONDARY}📋 📁 HOME DİZİNİ:${THEME_RESET}"
        fi
        
        echo -e "   $(eval echo ~$username)"
        echo
        
    else
        if command -v show_status &> /dev/null; then
            show_status "error" "Kullanıcı oluşturulurken hata oluştu!"
        else
            echo -e "${THEME_DANGER}❌ Kullanıcı oluşturulurken hata oluştu!${THEME_RESET}"
        fi
        return 1
    fi
}

# Ana fonksiyon
main() {
    check_root
    add_user
    echo -n "Ana menüye dönmek için Enter'a basın..."
    read -r
}

# Script başlatıldığında
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
