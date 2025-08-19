# Varsayılan Tema - Mini Linux System Management Tool
# Renk şemaları ve görsel stiller

# Ana renkler
THEME_PRIMARY='\033[0;34m'      # Mavi
THEME_SECONDARY='\033[0;36m'    # Cyan
THEME_SUCCESS='\033[0;32m'      # Yeşil
THEME_WARNING='\033[1;33m'      # Sarı
THEME_DANGER='\033[0;31m'       # Kırmızı
THEME_INFO='\033[0;35m'         # Mor
THEME_LIGHT='\033[0;37m'        # Açık gri
THEME_DARK='\033[0;30m'         # Koyu gri
THEME_RESET='\033[0m'           # Reset

# Özel renkler
THEME_HEADER='\033[1;36m'       # Başlık rengi
THEME_BORDER='\033[0;34m'       # Kenarlık rengi
THEME_HIGHLIGHT='\033[1;32m'    # Vurgu rengi

# Tema adı
THEME_NAME="Varsayılan Tema"
THEME_VERSION="1.0"
THEME_AUTHOR="Mini Linux SysMngt Tool"

# Tema bilgilerini göster
show_theme_info() {
    echo -e "${THEME_HEADER}🎨 Tema: $THEME_NAME v$THEME_VERSION${THEME_RESET}"
    echo -e "${THEME_INFO}   Yazar: $THEME_AUTHOR${THEME_RESET}"
}

# Başlık çerçevesi
draw_header() {
    local title="$1"
    local width=60
    
    echo -e "${THEME_BORDER}╔$(printf '═%.0s' $(seq 1 $((width-2))))╗${THEME_RESET}"
    echo -e "${THEME_BORDER}║${THEME_RESET}${THEME_HEADER} $(printf "%-${width}s" "$title")${THEME_RESET}${THEME_BORDER}║${THEME_RESET}"
    echo -e "${THEME_BORDER}╚$(printf '═%.0s' $(seq 1 $((width-2))))╝${THEME_RESET}"
}

# Alt başlık
draw_subheader() {
    local title="$1"
    echo -e "${THEME_SECONDARY}📋 $title${THEME_RESET}"
}

# Bilgi kutusu
draw_info_box() {
    local title="$1"
    local content="$2"
    
    echo -e "${THEME_INFO}╔─ $title${THEME_RESET}"
    echo -e "${THEME_INFO}│${THEME_RESET} $content"
    echo -e "${THEME_INFO}╚${THEME_RESET}"
}

# Durum göstergesi
show_status() {
    local status="$1"
    local message="$2"
    
    case $status in
        "success"|"ok"|"active")
            echo -e "${THEME_SUCCESS}✅ $message${THEME_RESET}"
            ;;
        "warning"|"warn")
            echo -e "${THEME_WARNING}⚠️  $message${THEME_RESET}"
            ;;
        "error"|"fail"|"critical")
            echo -e "${THEME_DANGER}❌ $message${THEME_RESET}"
            ;;
        "info"|"information")
            echo -e "${THEME_INFO}ℹ️  $message${THEME_RESET}"
            ;;
        "loading"|"processing")
            echo -e "${THEME_SECONDARY}🔄 $message${THEME_RESET}"
            ;;
        *)
            echo -e "${THEME_LIGHT}• $message${THEME_RESET}"
            ;;
    esac
}

# İlerleme çubuğu
draw_progress_bar() {
    local current="$1"
    local total="$2"
    local width=40
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${THEME_SECONDARY}["
    printf "${THEME_SUCCESS}#%.0s" $(seq 1 $filled)
    printf "${THEME_LIGHT}-%.0s" $(seq 1 $empty)
    printf "${THEME_SECONDARY}] ${THEME_INFO}%d%%${THEME_RESET}" $percentage
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# Tablo başlığı
draw_table_header() {
    local headers=("$@")
    local separator=""
    
    for header in "${headers[@]}"; do
        separator+="$(printf '─%.0s' $(seq 1 ${#header}))─"
    done
    
    echo -e "${THEME_BORDER}$separator${THEME_RESET}"
    printf "${THEME_HEADER}"
    printf "│ %-15s " "${headers[@]}"
    printf "│\n"
    echo -e "${THEME_RESET}${THEME_BORDER}$separator${THEME_RESET}"
}

# Tablo satırı
draw_table_row() {
    local values=("$@")
    printf "${THEME_LIGHT}│${THEME_RESET}"
    printf " %-15s " "${values[@]}"
    printf "${THEME_LIGHT}│\n${THEME_RESET}"
}

# Tablo sonu
draw_table_footer() {
    local headers=("$@")
    local separator=""
    
    for header in "${headers[@]}"; do
        separator+="$(printf '─%.0s' $(seq 1 ${#header}))─"
    done
    
    echo -e "${THEME_BORDER}$separator${THEME_RESET}"
}

# Uyarı kutusu
draw_warning_box() {
    local message="$1"
    local width=50
    
    echo -e "${THEME_WARNING}┌$(printf '─%.0s' $(seq 1 $((width-2))))┐${THEME_RESET}"
    echo -e "${THEME_WARNING}│${THEME_RESET} $(printf "%-${width}s" "$message")${THEME_WARNING}│${THEME_RESET}"
    echo -e "${THEME_WARNING}└$(printf '─%.0s' $(seq 1 $((width-2))))┘${THEME_RESET}"
}

# Hata kutusu
draw_error_box() {
    local message="$1"
    local width=50
    
    echo -e "${THEME_DANGER}┌$(printf '─%.0s' $(seq 1 $((width-2))))┐${THEME_RESET}"
    echo -e "${THEME_DANGER}│${THEME_RESET} $(printf "%-${width}s" "$message")${THEME_DANGER}│${THEME_RESET}"
    echo -e "${THEME_DANGER}└$(printf '─%.0s' $(seq 1 $((width-2))))┘${THEME_RESET}"
}

# Başarı kutusu
draw_success_box() {
    local message="$1"
    local width=50
    
    echo -e "${THEME_SUCCESS}┌$(printf '─%.0s' $(seq 1 $((width-2))))┐${THEME_RESET}"
    echo -e "${THEME_SUCCESS}│${THEME_RESET} $(printf "%-${width}s" "$message")${THEME_SUCCESS}│${THEME_RESET}"
    echo -e "${THEME_SUCCESS}└$(printf '─%.0s' $(seq 1 $((width-2))))┘${THEME_RESET}"
}
