# Kalkulator Estimasi Seragam & Peralatan

Aplikasi statis (HTML/JS murni), tanpa database. Hasil hitungan tidak disimpan.

- `index.html` kalkulator; `admin.html` administrator (ubah, tambah, hapus item).
- `harga.json` satu-satunya sumber harga jual (107 item: 70 seragam, 37 peralatan, dari web pengadaan per 2026-11-25). Harga beli tidak dibawa.

**Cara mengubah harga:** edit isi `harga.json` di repo lalu commit dan push. Halaman admin hanya untuk mencoba perubahan sementara di browser (tidak tersimpan).

Buka lewat server (mis. GitHub Pages atau `python -m http.server`), bukan klik dua kali berkas, karena `harga.json` dibaca lewat fetch.
