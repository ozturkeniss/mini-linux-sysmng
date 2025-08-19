#!/bin/bash

# Dosya Gezgini Modülü
# Bu modül dosya sistemi yönetimi sağlar

# Tema dosyasını yükle
source "$(dirname "$0")/../../themes/default.sh"

# Global değişkenler
CURRENT_DIR="$HOME"
HISTORY=()
HISTORY_INDEX=0

# Ana fonksiyon
main() {
    draw_header "📁 Dosya Gezgini Modülü"
    
    while true; do
        show_current_directory
        
        echo
        draw_subheader "Dosya İşlemleri:"
        echo "1. 📂 Dizin Değiştir"
        echo "2. 🔍 Dosya Ara"
        echo "3. 📋 Dosya Bilgileri"
        echo "4. ✂️  Dosya Kopyala/Taşı"
        echo "5. 🗑️  Dosya Sil"
        echo "6. 📝 Dosya Düzenle"
        echo "7. 📊 Dizin Boyutu"
        echo "8. 🔒 İzinleri Değiştir"
        echo "9. 📚 Geçmiş"
        echo "0. 🔙 Ana Menüye Dön"
        
        read -p "Seçiminizi yapın (0-9): " choice
        
        case $choice in
            1) change_directory ;;
            2) search_files ;;
            3) show_file_info ;;
            4) copy_move_files ;;
            5) delete_files ;;
            6) edit_file ;;
            7) show_directory_size ;;
            8) change_permissions ;;
            9) show_history ;;
            0) break ;;
            *) echo "❌ Geçersiz seçim!" ;;
        esac
        
        if [[ $choice != 0 ]]; then
            echo
            read -p "Devam etmek için Enter'a basın..."
        fi
    done
}

# Mevcut dizini göster
show_current_directory() {
    echo
    draw_subheader "📂 Mevcut Dizin: $CURRENT_DIR"
    
    # Dizin içeriğini listele
    if [[ -d "$CURRENT_DIR" ]]; then
        echo "📋 Dizin İçeriği:"
        
        # Dizinler
        echo "   📁 Dizinler:"
        find "$CURRENT_DIR" -maxdepth 1 -type d | head -10 | while read -r dir; do
            if [[ "$dir" != "$CURRENT_DIR" ]]; then
                dir_name=$(basename "$dir")
                echo "      📁 $dir_name"
            fi
        done
        
        # Dosyalar
        echo "   📄 Dosyalar:"
        find "$CURRENT_DIR" -maxdepth 1 -type f | head -10 | while read -r file; do
            file_name=$(basename "$file")
            file_size=$(du -sh "$file" 2>/dev/null | cut -f1 || echo "N/A")
            echo "      📄 $file_name ($file_size)"
        done
        
        # Toplam sayı
        total_dirs=$(find "$CURRENT_DIR" -maxdepth 1 -type d | wc -l)
        total_files=$(find "$CURRENT_DIR" -maxdepth 1 -type f | wc -l)
        echo "   📊 Toplam: $((total_dirs - 1)) dizin, $total_files dosya"
    else
        draw_error_box "Dizin bulunamadı: $CURRENT_DIR"
        CURRENT_DIR="$HOME"
    fi
}

# Dizin değiştir
change_directory() {
    draw_subheader "📂 Dizin Değiştir"
    
    echo "Mevcut dizin: $CURRENT_DIR"
    echo
    echo "Seçenekler:"
    echo "1. 📁 Alt dizine git"
    echo "2. ⬆️  Üst dizine git"
    echo "3. 🏠 Ana dizine git"
    echo "4. 📍 Tam yol gir"
    echo "5. 🔙 Önceki dizine dön"
    
    read -p "Seçiminizi yapın (1-5): " subchoice
    
    case $subchoice in
        1) go_to_subdirectory ;;
        2) go_to_parent_directory ;;
        3) go_to_home_directory ;;
        4) go_to_specific_path ;;
        5) go_to_previous_directory ;;
        *) echo "❌ Geçersiz seçim!" ;;
    esac
}

# Alt dizine git
go_to_subdirectory() {
    echo "📋 Mevcut alt dizinler:"
    find "$CURRENT_DIR" -maxdepth 1 -type d | while read -r dir; do
        if [[ "$dir" != "$CURRENT_DIR" ]]; then
            dir_name=$(basename "$dir")
            echo "   📁 $dir_name"
        fi
    done
    
    read -p "Gidilecek dizin adı: " target_dir
    
    if [[ -n "$target_dir" ]]; then
        new_path="$CURRENT_DIR/$target_dir"
        if [[ -d "$new_path" ]]; then
            add_to_history "$CURRENT_DIR"
            CURRENT_DIR="$new_path"
            echo "✅ Dizin değiştirildi: $CURRENT_DIR"
        else
            draw_error_box "Dizin bulunamadı: $new_path"
        fi
    fi
}

# Üst dizine git
go_to_parent_directory() {
    parent_dir=$(dirname "$CURRENT_DIR")
    if [[ "$parent_dir" != "$CURRENT_DIR" ]]; then
        add_to_history "$CURRENT_DIR"
        CURRENT_DIR="$parent_dir"
        echo "✅ Üst dizine geçildi: $CURRENT_DIR"
    else
        echo "❌ Zaten kök dizindesiniz."
    fi
}

# Ana dizine git
go_to_home_directory() {
    if [[ "$CURRENT_DIR" != "$HOME" ]]; then
        add_to_history "$CURRENT_DIR"
        CURRENT_DIR="$HOME"
        echo "✅ Ana dizine geçildi: $CURRENT_DIR"
    else
        echo "❌ Zaten ana dizindesiniz."
    fi
}

# Belirli yola git
go_to_specific_path() {
    read -p "Tam dizin yolu: " target_path
    
    if [[ -n "$target_path" ]]; then
        if [[ -d "$target_path" ]]; then
            add_to_history "$CURRENT_DIR"
            CURRENT_DIR="$target_path"
            echo "✅ Dizin değiştirildi: $CURRENT_DIR"
        else
            draw_error_box "Dizin bulunamadı: $target_path"
        fi
    fi
}

# Önceki dizine dön
go_to_previous_directory() {
    if [[ $HISTORY_INDEX -gt 0 ]]; then
        HISTORY_INDEX=$((HISTORY_INDEX - 1))
        CURRENT_DIR="${HISTORY[$HISTORY_INDEX]}"
        echo "✅ Önceki dizine dönüldü: $CURRENT_DIR"
    else
        echo "❌ Geçmiş bulunamadı."
    fi
}

# Geçmişe ekle
add_to_history() {
    local dir="$1"
    HISTORY+=("$dir")
    HISTORY_INDEX=${#HISTORY[@]}
}

# Dosya ara
search_files() {
    draw_subheader "🔍 Dosya Ara"
    
    read -p "Aranacak dosya/dizin adı: " search_term
    
    if [[ -n "$search_term" ]]; then
        echo "🔍 Aranıyor: $search_term"
        echo "📂 Konum: $CURRENT_DIR"
        echo
        
        # Dosya ara
        find "$CURRENT_DIR" -name "*$search_term*" -type f 2>/dev/null | head -20 | while read -r file; do
            file_name=$(basename "$file")
            file_size=$(du -sh "$file" 2>/dev/null | cut -f1 || echo "N/A")
            echo "   📄 $file_name ($file_size)"
        done
        
        # Dizin ara
        find "$CURRENT_DIR" -name "*$search_term*" -type d 2>/dev/null | head -10 | while read -r dir; do
            dir_name=$(basename "$dir")
            echo "   📁 $dir_name"
        done
        
        echo
        echo "💡 Daha fazla sonuç için terminal'de 'find' komutunu kullanın."
    fi
}

# Dosya bilgileri
show_file_info() {
    draw_subheader "📋 Dosya Bilgileri"
    
    read -p "Dosya/dizin adı: " target_name
    
    if [[ -n "$target_name" ]]; then
        target_path="$CURRENT_DIR/$target_name"
        
        if [[ -e "$target_path" ]]; then
            echo "📋 Dosya Bilgileri: $target_name"
            echo
            
            # Temel bilgiler
            if [[ -f "$target_path" ]]; then
                echo "   📄 Tür: Dosya"
            elif [[ -d "$target_path" ]]; then
                echo "   📁 Tür: Dizin"
            elif [[ -L "$target_path" ]]; then
                echo "   🔗 Tür: Sembolik Link"
            fi
            
            # Boyut
            if [[ -f "$target_path" ]] || [[ -d "$target_path" ]]; then
                size=$(du -sh "$target_path" 2>/dev/null | cut -f1 || echo "N/A")
                echo "   📏 Boyut: $size"
            fi
            
            # İzinler
            permissions=$(ls -ld "$target_path" | cut -c1-10)
            echo "   🔒 İzinler: $permissions"
            
            # Sahip
            owner=$(ls -ld "$target_path" | awk '{print $3}')
            group=$(ls -ld "$target_path" | awk '{print $4}')
            echo "   👤 Sahip: $owner:$group"
            
            # Tarih
            modified=$(stat -c %y "$target_path" | cut -d' ' -f1)
            echo "   📅 Son Değişiklik: $modified"
            
            # İçerik önizleme (dosya ise)
            if [[ -f "$target_path" ]]; then
                echo
                echo "📖 İçerik Önizleme (ilk 5 satır):"
                head -5 "$target_path" | while read -r line; do
                    echo "   $line"
                done
            fi
        else
            draw_error_box "Dosya/dizin bulunamadı: $target_name"
        fi
    fi
}

# Dosya kopyala/taşı
copy_move_files() {
    draw_subheader "✂️  Dosya Kopyala/Taşı"
    
    echo "1. 📋 Dosya Kopyala"
    echo "2. ✂️  Dosya Taşı"
    echo "3. 🔗 Sembolik Link Oluştur"
    
    read -p "Seçiminizi yapın (1-3): " subchoice
    
    case $subchoice in
        1) copy_file ;;
        2) move_file ;;
        3) create_symlink ;;
        *) echo "❌ Geçersiz seçim!" ;;
    esac
}

# Dosya kopyala
copy_file() {
    read -p "Kopyalanacak dosya/dizin: " source_name
    read -p "Hedef konum: " target_path
    
    if [[ -n "$source_name" ]] && [[ -n "$target_path" ]]; then
        source_path="$CURRENT_DIR/$source_name"
        
        if [[ -e "$source_path" ]]; then
            echo "📋 Kopyalanıyor: $source_path -> $target_path"
            
            if cp -r "$source_path" "$target_path"; then
                draw_success_box "Dosya başarıyla kopyalandı!"
            else
                draw_error_box "Kopyalama sırasında hata oluştu!"
            fi
        else
            draw_error_box "Kaynak dosya bulunamadı: $source_name"
        fi
    fi
}

# Dosya taşı
move_file() {
    read -p "Taşınacak dosya/dizin: " source_name
    read -p "Hedef konum: " target_path
    
    if [[ -n "$source_name" ]] && [[ -n "$target_path" ]]; then
        source_path="$CURRENT_DIR/$source_name"
        
        if [[ -e "$source_path" ]]; then
            echo "📋 Taşınıyor: $source_path -> $target_path"
            
            if mv "$source_path" "$target_path"; then
                draw_success_box "Dosya başarıyla taşındı!"
            else
                draw_error_box "Taşıma sırasında hata oluştu!"
            fi
        else
            draw_error_box "Kaynak dosya bulunamadı: $source_name"
        fi
    fi
}

# Sembolik link oluştur
create_symlink() {
    read -p "Hedef dosya/dizin: " target_name
    read -p "Link adı: " link_name
    
    if [[ -n "$target_name" ]] && [[ -n "$link_name" ]]; then
        target_path="$CURRENT_DIR/$target_name"
        link_path="$CURRENT_DIR/$link_name"
        
        if [[ -e "$target_path" ]]; then
            echo "🔗 Sembolik link oluşturuluyor: $link_name -> $target_name"
            
            if ln -s "$target_path" "$link_path"; then
                draw_success_box "Sembolik link başarıyla oluşturuldu!"
            else
                draw_error_box "Link oluşturulurken hata oluştu!"
            fi
        else
            draw_error_box "Hedef dosya bulunamadı: $target_name"
        fi
    fi
}

# Dosya sil
delete_files() {
    draw_subheader "🗑️  Dosya Sil"
    
    read -p "Silinecek dosya/dizin: " target_name
    
    if [[ -n "$target_name" ]]; then
        target_path="$CURRENT_DIR/$target_name"
        
        if [[ -e "$target_path" ]]; then
            draw_warning_box "Bu işlem geri alınamaz!"
            read -p "Devam etmek istiyor musunuz? (y/N): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "🗑️  Siliniyor: $target_name"
                
                if rm -rf "$target_path"; then
                    draw_success_box "Dosya başarıyla silindi!"
                else
                    draw_error_box "Silme sırasında hata oluştu!"
                fi
            else
                echo "❌ İşlem iptal edildi."
            fi
        else
            draw_error_box "Dosya/dizin bulunamadı: $target_name"
        fi
    fi
}

# Dosya düzenle
edit_file() {
    draw_subheader "📝 Dosya Düzenle"
    
    read -p "Düzenlenecek dosya: " target_name
    
    if [[ -n "$target_name" ]]; then
        target_path="$CURRENT_DIR/$target_name"
        
        if [[ -f "$target_path" ]]; then
            echo "📝 Düzenleniyor: $target_name"
            echo "💡 Kullanılabilir editörler: nano, vim, gedit"
            
            # Editör seç
            if command -v nano &> /dev/null; then
                echo "🟢 nano kullanılıyor..."
                nano "$target_path"
            elif command -v vim &> /dev/null; then
                echo "🟢 vim kullanılıyor..."
                vim "$target_path"
            elif command -v gedit &> /dev/null; then
                echo "🟢 gedit kullanılıyor..."
                gedit "$target_path" &
            else
                draw_error_box "Hiçbir editör bulunamadı!"
                echo "💡 nano, vim veya gedit kurun."
            fi
        else
            draw_error_box "Dosya bulunamadı: $target_name"
        fi
    fi
}

# Dizin boyutu
show_directory_size() {
    draw_subheader "📊 Dizin Boyutu"
    
    echo "📂 Mevcut dizin: $CURRENT_DIR"
    echo "📏 Toplam boyut hesaplanıyor..."
    
    total_size=$(du -sh "$CURRENT_DIR" 2>/dev/null | cut -f1 || echo "N/A")
    echo "📊 Toplam boyut: $total_size"
    
    echo
    echo "📋 Alt dizin boyutları:"
    find "$CURRENT_DIR" -maxdepth 1 -type d | while read -r dir; do
        if [[ "$dir" != "$CURRENT_DIR" ]]; then
            dir_name=$(basename "$dir")
            dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "N/A")
            echo "   📁 $dir_name: $dir_size"
        fi
    done
}

# İzinleri değiştir
change_permissions() {
    draw_subheader "🔒 İzinleri Değiştir"
    
    read -p "Dosya/dizin adı: " target_name
    
    if [[ -n "$target_name" ]]; then
        target_path="$CURRENT_DIR/$target_name"
        
        if [[ -e "$target_path" ]]; then
            echo "🔒 Mevcut izinler:"
            ls -ld "$target_path"
            echo
            
            echo "İzin formatı: 755, 644, 777 gibi"
            read -p "Yeni izinler: " new_permissions
            
            if [[ -n "$new_permissions" ]]; then
                echo "🔒 İzinler değiştiriliyor: $target_name -> $new_permissions"
                
                if chmod "$new_permissions" "$target_path"; then
                    draw_success_box "İzinler başarıyla değiştirildi!"
                    echo "🔒 Yeni izinler:"
                    ls -ld "$target_path"
                else
                    draw_error_box "İzin değiştirme sırasında hata oluştu!"
                fi
            fi
        else
            draw_error_box "Dosya/dizin bulunamadı: $target_name"
        fi
    fi
}

# Geçmişi göster
show_history() {
    draw_subheader "📚 Geçmiş"
    
    if [[ ${#HISTORY[@]} -eq 0 ]]; then
        echo "❌ Geçmiş bulunamadı."
        return
    fi
    
    echo "📚 Dizin Geçmişi:"
    for i in "${!HISTORY[@]}"; do
        if [[ $i -eq $HISTORY_INDEX ]]; then
            echo "   🟢 $i: ${HISTORY[$i]} (Mevcut)"
        else
            echo "   ⚪ $i: ${HISTORY[$i]}"
        fi
    done
    
    echo
    echo "💡 Geçmişe dönmek için 'Dizin Değiştir > Önceki dizine dön' seçeneğini kullanın."
}

# Script çalıştır
main
