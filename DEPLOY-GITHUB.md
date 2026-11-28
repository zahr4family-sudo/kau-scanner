# KAU Scanner — deployment melalui GitHub dan Cloudflare Pages

Paket ini disiapkan untuk repository GitHub yang dihubungkan ke **Cloudflare Pages**. Jangan deploy ke GitHub Pages biasa: GitHub Pages tidak menjalankan Cloudflare Pages Functions (`functions/api`).

## 1. Upload ke GitHub
1. Buat repository GitHub baru (atau repository yang memang digunakan untuk KAU).
2. Upload seluruh isi folder `kau-scanner` ini ke **root** repository, termasuk folder `functions`, `icons`, file `index.html`, `admin.html`, dan `schema.sql`.
3. Pastikan `functions/api` ikut terunggah dan tidak dihapus.

## 2. Hubungkan repository ke Cloudflare Pages
1. Cloudflare Dashboard → Workers & Pages → proyek Pages `kau-scanner`.
2. Jika proyek saat ini belum terhubung ke Git: buat/ubah proyek Pages dengan **Connect to Git**, pilih repository GitHub tadi. Jika proyek sudah terhubung, gunakan repository/branch tersebut.
3. Framework preset: None (atau kosong).
4. Build command: kosong (tidak diperlukan untuk paket statis ini).
5. Build output directory: `.`
6. Simpan. Setiap push ke branch yang terhubung akan memicu deployment.

## 3. Binding D1
Di Settings → Functions → D1 database bindings, tambahkan:
- Variable name: `DB`
- Database: `kau-access`

Jika konfigurasi `wrangler.toml` digunakan untuk deployment CLI, ganti `ISI_DATABASE_ID_DARI_CLOUDFLARE` dengan ID D1 yang sebenarnya. Jangan mengubah/menghapus database lama.

## 4. Jalankan schema hanya jika belum diterapkan
Gunakan D1 Console/Query editor pada database `kau-access` untuk menjalankan `schema.sql` jika tabel paket ini belum tersedia. Jangan menjalankan ulang atau mengubah data tabel secara destruktif. Bila database sudah berisi tabel users, user_devices, app_settings dan lainnya, lakukan pemeriksaan terlebih dahulu.

## 5. Secrets admin
Di Pages → Settings → Variables and Secrets, set:
- `ADMIN_PASSWORD` (password panel admin yang kuat)
- `ADMIN_SESSION_SECRET` (secret acak panjang)

Setelah mengubah secret, lakukan deployment ulang.

## 6. Perangkat
Kuota default perangkat untuk akun baru/akun tanpa override adalah **2 perangkat**. Admin dapat menetapkan nilai `device_quota` untuk akun individual. Promotion/VIP mengikuti aturan unlimited yang telah ada.

## 7. Tes setelah deployment
- Buka `https://kau-scanner.pages.dev/` dan tes login/register.
- Tes login akun yang sama pada perangkat pertama dan kedua.
- Tes perangkat ketiga (harus ditolak jika kuota akun masih 2).
- Tes `https://kau-scanner.pages.dev/api/admin?action=login` hanya sebagai URL API; endpoint login admin menerima POST, bukan halaman HTML. Gunakan `admin.html` untuk UI panel.
- Jika Functions tidak aktif atau API mengembalikan HTML, deployment belum mengikutsertakan folder `functions` atau binding DB belum terpasang.
