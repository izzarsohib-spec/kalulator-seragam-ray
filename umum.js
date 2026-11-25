// Fungsi bersama kalkulator dan administrator.
const rp = n => 'Rp ' + Math.round(n || 0).toLocaleString('id-ID');
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);
// Daftar harga dibaca dari harga.json (satu-satunya sumber data).
async function muatDaftar() {
  const r = await fetch('harga.json', { cache: 'no-store' });
  if (!r.ok) throw new Error('harga.json tidak bisa dibaca (' + r.status + ')');
  return r.json();
}
