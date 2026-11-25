// Fungsi bersama kalkulator dan administrator.
const rp = n => 'Rp ' + Math.round(n || 0).toLocaleString('id-ID');
const esc = s => String(s ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]);

async function rpc(fn, body) {
  const r = await fetch(`${KALK.URL}/rest/v1/rpc/${fn}`, {
    method: 'POST',
    headers: { apikey: KALK.KEY, Authorization: `Bearer ${KALK.KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body || {})
  });
  const t = await r.text();
  let j; try { j = t ? JSON.parse(t) : null; } catch { j = null; }
  if (!r.ok) throw new Error((j && (j.message || j.hint)) || `Gagal (${r.status})`);
  return j;
}

// Daftar harga: dari database; bila belum disiapkan, pakai daftar awal bawaan (hanya baca).
async function muatDaftar() {
  try { return { data: await rpc('kalk_daftar'), sumber: 'db' }; }
  catch (e) {
    const r = await fetch('data-awal.json');
    return { data: await r.json(), sumber: 'awal', galat: e.message };
  }
}
