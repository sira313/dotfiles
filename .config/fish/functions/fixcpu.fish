function fixcpu --description 'Fix AMD Ryzen throttling by overriding power limits'
    echo "Mencoba melepaskan limitasi daya CPU..."
    
    # Menjalankan ryzenadj dengan parameter yang sudah kita uji
    sudo ryzenadj --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000
    
    if test $status -eq 0
        echo "Berhasil! Memeriksa frekuensi CPU saat ini..."
        # Menampilkan frekuensi CPU saat ini sekilas
        grep "cpu MHz" /proc/cpuinfo | head -n 4
    else
        echo "Gagal menjalankan ryzenadj. Pastikan password sudo benar."
    end
end
