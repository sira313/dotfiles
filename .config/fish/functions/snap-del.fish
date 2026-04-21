function snap-del --description 'Menghapus snapshot snapper root berdasarkan nomor'
    # Memastikan argumen nomor snapshot diberikan
    if test (count $argv) -eq 0
        echo "Penggunaan: snap-del <nomor_snapshot>"
        echo "Contoh: snap-del 5"
        return 1
    end

    set -l nomor $argv[1]

    # Konfirmasi sebelum menghapus
    read -P "Apakah Anda yakin ingin menghapus snapshot nomor $nomor? [y/N]: " konfirmasi
    
    if test "$konfirmasi" = "y" -o "$konfirmasi" = "Y"
        echo "Menghapus snapshot $nomor..."
        sudo snapper -c root delete $nomor
        
        if test $status -eq 0
            echo "Snapshot $nomor berhasil dihapus."
        else
            echo "Gagal menghapus snapshot $nomor."
        end
    else
        echo "Operasi dibatalkan."
    end
end
