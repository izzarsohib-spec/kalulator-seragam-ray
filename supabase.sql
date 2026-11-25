-- Kalkulator estimasi seragam & peralatan: tabel dan fungsi (tabel berawalan kalk_, terpisah dari tabel web pengadaan).
-- Jalankan di Supabase SQL Editor. SEBELUM dijalankan, ganti GANTI_KODE_ADMIN di bawah dengan kode admin pilihan Anda.
-- Hanya harga jual yang disimpan; harga beli tidak dibawa ke aplikasi ini.

create table if not exists public.kalk_item (
  id bigserial primary key,
  jenis text not null check (jenis in ('seragam','peralatan')),
  kategori text not null,
  nama text not null,
  harga int not null check (harga >= 0),
  diperbarui timestamptz not null default now(),
  unique (jenis, nama)
);
create table if not exists public.kalk_rahasia (id int primary key default 1 check (id = 1), kode_hash text not null);

-- RLS aktif tanpa kebijakan: tabel tidak bisa dibaca/ditulis langsung, hanya lewat fungsi di bawah.
alter table public.kalk_item enable row level security;
alter table public.kalk_rahasia enable row level security;
revoke all on public.kalk_item, public.kalk_rahasia from anon, authenticated;

insert into public.kalk_rahasia (id, kode_hash) values (1, extensions.crypt('GANTI_KODE_ADMIN', extensions.gen_salt('bf')))
  on conflict (id) do nothing;

create or replace function public.kalk_kode_ok(p_kode text) returns boolean
  language sql stable security definer set search_path = public, extensions as
$f$ select exists (select 1 from public.kalk_rahasia where id = 1 and p_kode is not null and kode_hash = crypt(p_kode, kode_hash)) $f$;
revoke all on function public.kalk_kode_ok(text) from public, anon, authenticated;

create or replace function public.kalk_daftar() returns table(id bigint, jenis text, kategori text, nama text, harga int)
  language sql stable security definer set search_path = public as
$f$ select i.id, i.jenis, i.kategori, i.nama, i.harga from public.kalk_item i order by i.jenis, i.kategori, i.nama $f$;

create or replace function public.kalk_cek(p_kode text) returns boolean
  language sql stable security definer set search_path = public, extensions as
$f$ select public.kalk_kode_ok(p_kode) $f$;

create or replace function public.kalk_simpan(p_kode text, p_id bigint, p_jenis text, p_kategori text, p_nama text, p_harga int) returns bigint
  language plpgsql security definer set search_path = public, extensions as
$f$
declare rid bigint; n text := trim(p_nama); k text := trim(p_kategori);
begin
  if not public.kalk_kode_ok(p_kode) then raise exception 'kode admin salah'; end if;
  if p_jenis not in ('seragam','peralatan') then raise exception 'jenis harus seragam atau peralatan'; end if;
  if coalesce(n,'') = '' or coalesce(k,'') = '' then raise exception 'nama dan kategori wajib diisi'; end if;
  if p_harga is null or p_harga < 0 then raise exception 'harga wajib diisi dan tidak boleh negatif'; end if;
  if p_id is null then
    if exists (select 1 from public.kalk_item where jenis = p_jenis and nama = n) then raise exception 'item dengan nama itu sudah ada'; end if;
    insert into public.kalk_item (jenis, kategori, nama, harga) values (p_jenis, k, n, p_harga) returning id into rid;
  else
    if exists (select 1 from public.kalk_item where jenis = p_jenis and nama = n and id <> p_id) then raise exception 'item dengan nama itu sudah ada'; end if;
    update public.kalk_item set jenis = p_jenis, kategori = k, nama = n, harga = p_harga, diperbarui = now() where id = p_id returning id into rid;
    if rid is null then raise exception 'item tidak ditemukan'; end if;
  end if;
  return rid;
end $f$;

create or replace function public.kalk_hapus(p_kode text, p_id bigint) returns void
  language plpgsql security definer set search_path = public, extensions as
$f$
begin
  if not public.kalk_kode_ok(p_kode) then raise exception 'kode admin salah'; end if;
  delete from public.kalk_item where id = p_id;
  if not found then raise exception 'item tidak ditemukan'; end if;
end $f$;

grant execute on function public.kalk_daftar() to anon, authenticated;
grant execute on function public.kalk_cek(text) to anon, authenticated;
grant execute on function public.kalk_simpan(text,bigint,text,text,text,int) to anon, authenticated;
grant execute on function public.kalk_hapus(text,bigint) to anon, authenticated;

-- Data awal: harga jual dari katalog web pengadaan (diambil 2026-11-25).
insert into public.kalk_item (jenis, kategori, nama, harga) values
  ('seragam','Seragam setelan','SERAGAM PDL',265000),
  ('seragam','Seragam setelan','SERAGAM PDH',255000),
  ('seragam','Seragam setelan','SERAGAM PDL SUS',265000),
  ('seragam','Seragam setelan','SERAGAM PDL BORDIR TIMBUL + NAMA',295000),
  ('seragam','Seragam setelan','SERAGAM PDH BORDIR TIMBUL + NAMA',285000),
  ('seragam','Seragam setelan','SERAGAM PDL (BAHAN GAIA)',325000),
  ('seragam','Seragam setelan','SERAGAM PDH (BAHAN GAIA)',315000),
  ('seragam','Seragam setelan','SAFARI LENGAN PENDEK',300000),
  ('seragam','Seragam setelan','SAFARI LENGAN PANJANG',310000),
  ('seragam','Seragam setelan','SAFARI LENGAN PANJANG (BAHAN JETBLACK)',335000),
  ('seragam','Seragam setelan','SERAGAM KAMDAL BORDIR TIMBUL + NAMA',355000),
  ('seragam','Seragam setelan','SERAGAM KEBERSIHAN PENDEK MERAH',260000),
  ('seragam','Seragam setelan','SERAGAM KEBERSIHAN PENDEK BIRU',260000),
  ('seragam','Seragam setelan','SERAGAM KEBERSIHAN PANJANG MERAH',270000),
  ('seragam','Seragam setelan','SERAGAM KEBERSIHAN PANJANG BIRU',270000),
  ('seragam','Seragam setelan','SERAGAM PRAMUBHAKTI DRILL(AMERICAN DRILL)',340000),
  ('seragam','Seragam setelan','SERAGAM PRAMUBHAKTI NAGATA',365000),
  ('seragam','Seragam setelan','SERAGAM BATIK PENDEK',305000),
  ('seragam','Seragam setelan','SERAGAM BATIK PANJANG + BORDIR',315000),
  ('seragam','Seragam setelan','SERAGAM BATIK LURIK PANJANG + BORDIR',315000),
  ('seragam','Seragam setelan','SERAGAM BATIK LURIK PENDEK+ BORDIR',300000),
  ('seragam','Seragam setelan','KAOS PHH SABLON',80000),
  ('seragam','Seragam setelan','KAOS PHH DTF',125000),
  ('seragam','Seragam setelan','KAOS POLO KATUN KERAH',155000),
  ('seragam','Seragam setelan','CELANA PDH',165000),
  ('seragam','Seragam setelan','CELANA PDL',165000),
  ('seragam','Seragam setelan','CELANA CS HITAM(CHINOS)',155000),
  ('seragam','Seragam setelan','KAOS DALAM KREM',70000),
  ('seragam','Seragam setelan','SERAGAM TACTICAL BORDIR TIMBUL',405000),
  ('seragam','Seragam setelan','SERAGAM TACTICAL BORDIR BIASA',375000),
  ('seragam','Seragam setelan','SERAGAM HITAM PUTIH POLOS PENDEK',245000),
  ('seragam','Seragam setelan','SERAGAM HITAM PUTIH BORDIR PENDEK',275000),
  ('seragam','Seragam setelan','SERAGAM HITAM PUTIH POLOS PANJANG',255000),
  ('seragam','Seragam setelan','SERAGAM HITAM PUTIH BORDIR PANJANG',285000),
  ('seragam','Seragam setelan','SETELAN BLAZER, KEMEJA PUTIH POLOS, CELANA HITAM',405000),
  ('seragam','Baju saja','ATASAN PDH',170000),
  ('seragam','Baju saja','ATASAN PDL',185000),
  ('seragam','Baju saja','SERAGAM KEBERSIHAN PENDEK (BAJU SAJA)',160000),
  ('seragam','Baju saja','SERAGAM KEBERSIHAN PANJANG (BAJU SAJA)',170000),
  ('seragam','Baju saja','BAJU TEKNISI (BAJU SAJA)',155000),
  ('seragam','Baju saja','SERAGAM PRAMUBHAKTI DRILL (BAJU SAJA)',155000),
  ('seragam','Baju saja','SERAGAM PRAMUBHAKTI NAGATA (BAJU SAJA)',195000),
  ('seragam','Baju saja','SERAGAM PRAMUBHAKTI TWIS (BAJU SAJA)',260000),
  ('seragam','Baju saja','SERAGAM DRIVER (BAJU SAJA)(BAHAN DRILL)',155000),
  ('seragam','Baju saja','ATASAN PUTIH POLOS LENGAN PANJANG + BORDIR',155000),
  ('seragam','Sepatu','SEPATU PDH DOOF',205000),
  ('seragam','Sepatu','SEPATU PDH HANDYMAN',315000),
  ('seragam','Sepatu','SEPATU PDL COBRA',205000),
  ('seragam','Sepatu','SEPATU PDL HALUS DOFF',260000),
  ('seragam','Sepatu','SEPATU PDL KULIT ASLI TNI/POLRI',270000),
  ('seragam','Sepatu','SEPATU PDH SUS SECWAN PDH SUS (BIASA)',245000),
  ('seragam','Sepatu','SEPATU PDH SUS SECWAN DENAWARI (BAGUS)',310000),
  ('seragam','Sepatu','SEPATU KEBERSIHAN KETS',165000),
  ('seragam','Sepatu','SEPATU PRAMUBHAKTI KETS',165000),
  ('seragam','Aksesoris','IKAT PINGGANG SATPAM',38000),
  ('seragam','Aksesoris','KAOS KAKI PDH',25000),
  ('seragam','Aksesoris','KAOS KAKI PDL',30000),
  ('seragam','Aksesoris','TALI KUR HITAM + PELUIT',35000),
  ('seragam','Aksesoris','KOPEL SATPAM BIASA',43000),
  ('seragam','Aksesoris','KOPEL SATPAM HITAM',53000),
  ('seragam','Aksesoris','TOPI PDL JALA',40000),
  ('seragam','Aksesoris','TOPI PET SAPTAM + EMBLEM',70000),
  ('seragam','Aksesoris','BED LOGO LAMBANG POLDA DLL',25000),
  ('seragam','Aksesoris','BED LOGO LAMBANG POLDA DLL(BORDIR TIMBUL)',100000),
  ('seragam','Aksesoris','ROMPI TEBAL JALA',245000),
  ('seragam','Aksesoris','ROMPI BIASA',120000),
  ('seragam','Aksesoris','PIN SATPAM/KEWENANGAN',30000),
  ('seragam','Aksesoris','PIN GP/SATPAM',15000),
  ('seragam','Aksesoris','BADGE NAMA',15000),
  ('seragam','Aksesoris','BAN DANRU',100000),
  ('peralatan','Peralatan','ATK DAN TINTA PRINTER',100000),
  ('peralatan','Peralatan','BATERAI',20000),
  ('peralatan','Peralatan','BENDERA SEMAPORE',25000),
  ('peralatan','Peralatan','BORGOL',50000),
  ('peralatan','Peralatan','BUKU MUTASI',35000),
  ('peralatan','Peralatan','DISPENSER',225000),
  ('peralatan','Peralatan','FINGER PRINT',1500000),
  ('peralatan','Peralatan','GEMBOK',50000),
  ('peralatan','Peralatan','HELM FULL FACE PKD',325000),
  ('peralatan','Peralatan','HELM PKD',120000),
  ('peralatan','Peralatan','HELM PROYEK',70000),
  ('peralatan','Peralatan','HT',600000),
  ('peralatan','Peralatan','HT HYTERA',2000000),
  ('peralatan','Peralatan','INSPECTION MIRROR',1000000),
  ('peralatan','Peralatan','JAS HUJAN SATPAM',185000),
  ('peralatan','Peralatan','JAS HUJAN STELLAN (ATASAN +CELANA)',220000),
  ('peralatan','Peralatan','LAMPU LALIN',120000),
  ('peralatan','Peralatan','LAMPU LALIN PANJANG',120000),
  ('peralatan','Peralatan','MEJA LIPAT PKD',400000),
  ('peralatan','Peralatan','P3K',783000),
  ('peralatan','Peralatan','PATROLI AMANO',5000000),
  ('peralatan','Peralatan','PAYUNG BESAR PKD',600000),
  ('peralatan','Peralatan','PAYUNG CUSTOMER',150000),
  ('peralatan','Peralatan','PELUIT',5000),
  ('peralatan','Peralatan','ROMPI',225000),
  ('peralatan','Peralatan','ROMPI TIPIS',110000),
  ('peralatan','Peralatan','SAPU',40000),
  ('peralatan','Peralatan','SENTER',120000),
  ('peralatan','Peralatan','SENTER BESAR',300000),
  ('peralatan','Peralatan','SEPATU BOOT',160000),
  ('peralatan','Peralatan','SEPATU PDH',210000),
  ('peralatan','Peralatan','STOPER',170000),
  ('peralatan','Peralatan','TEMPAT SAMPAH',100000),
  ('peralatan','Peralatan','TOA',300000),
  ('peralatan','Peralatan','TONGKAT',50000),
  ('peralatan','Peralatan','TOPI COKLAT PDL JALA',35000),
  ('peralatan','Peralatan','TRAFFIC CONE',150000)
on conflict (jenis, nama) do nothing;
