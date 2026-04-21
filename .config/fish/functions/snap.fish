function snap --description 'Membuat snapshot btrfs dengan snapper secara interaktif'
    # Meminta input deskripsi dari user
    read -P "Masukkan keterangan snapshot: " deskripsi

    # Cek apakah deskripsi kosong
    if test -z "$deskripsi"
        echo "Error: Deskripsi tidak boleh kosong."
        return 1
    end

    # Menjalankan perintah snapper
    echo "Membuat snapshot untuk config 'root'..."
    sudo snapper -c root create -d "$deskripsi"

    # Verifikasi status
    if test $status -eq 0
        echo "Snapshot berhasil dibuat."
    else
        echo "Gagal membuat snapshot."
    end
end
