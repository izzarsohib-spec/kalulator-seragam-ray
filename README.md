# Kalkulator Estimasi Seragam & Peralatan

Aplikasi statis (HTML/JS murni) untuk menghitung perkiraan anggaran client. Hasil hitungan tidak disimpan. Hanya daftar harga jual yang disimpan di database.

- `index.html` kalkulator; `admin.html` administrator (ubah, tambah, hapus item, dijaga kode admin).
- `supabase.sql` tabel `kalk_item` dan fungsi, berisi data awal 107 item (70 seragam, 37 peralatan) dari web pengadaan per 2026-11-25. Ganti `GANTI_KODE_ADMIN` sebelum dijalankan di Supabase SQL Editor.
- `data-awal.json` daftar bawaan; dipakai kalkulator bila database belum disiapkan (hanya baca).
- Harga beli tidak dibawa; hanya harga jual.
