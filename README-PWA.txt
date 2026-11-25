KAU OMR — PAKET DEPLOY PWA (GITHUB PAGES / CLOUDFLARE PAGES)
============================================================

ISI PAKET
- index.html: aplikasi utama KAU OMR.
- manifest.json: identitas dan konfigurasi instalasi PWA (path relatif, kompatibel dengan GitHub Pages project site).
- sw.js: service worker path-aware, app-shell cache, fallback navigasi offline, dan cache runtime library XLSX.
- icons/: ikon aplikasi 192x192, 512x512, dan maskable 512x512.
- template-import-siswa-nilai.csv: contoh format impor siswa, jawaban, dan nilai.
- _headers: header keamanan/cache untuk Cloudflare Pages (diabaikan hosting yang tidak mendukung).
- .nojekyll: mencegah GitHub Pages memproses folder sebagai situs Jekyll.

A. DEPLOY KE GITHUB PAGES
1. Ekstrak ZIP. Buka folder kau-omr-main; unggah ISI folder ini ke root repository GitHub (index.html harus berada di root repository, bukan di dalam folder tambahan).
2. Commit dan push seluruh file/folder termasuk manifest.json, sw.js, icons, .nojekyll, dan _headers.
3. GitHub repository > Settings > Pages. Pilih Deploy from a branch, branch main, folder /(root), lalu Save.
4. Tunggu proses deployment selesai, lalu buka URL Pages. Konfigurasi manifest memakai path relatif sehingga mendukung URL repository seperti https://username.github.io/nama-repo/.
5. Pastikan file /manifest.json dan /sw.js dapat dibuka pada path situs yang sama.

B. DEPLOY KE CLOUDFLARE PAGES
1. Hubungkan repository GitHub ke Cloudflare Pages.
2. Framework preset: None. Build command: kosongkan. Build output directory: . (root) jika repository ini langsung berisi index.html; jika file berada di subfolder, arahkan output ke subfolder tersebut.
3. Deploy. Pastikan URL HTTPS dapat membuka aplikasi, manifest.json, dan sw.js.
4. Setiap perubahan kode harus di-commit/push agar Cloudflare membangun deployment baru.

C. INSTAL PWA / MEMBUAT APK
1. Buka URL HTTPS di Chrome Android.
2. Pilih Install app / Tambahkan ke layar utama. Uji dahulu sebagai PWA.
3. Untuk paket APK/AAB, masukkan URL HTTPS tersebut ke https://www.pwabuilder.com/.
4. Periksa manifest, ikon, start_url, scope, dan hasil validasi. Pilih Android package/TWA sesuai alur PWABuilder terkini.
5. Uji paket pada perangkat fisik: kamera, pilih foto, scan, cetak/simpan PDF, input data, analisis, impor dan ekspor.
6. Simpan keystore dan kredensial signing dengan aman. Jangan membagikan keystore/password.

PERBAIKAN DALAM PAKET INI
- Manifest memakai start_url dan scope relatif (./), sehingga tidak mengunci aplikasi ke root domain.
- Service worker menghitung base path dari registration scope; mendukung GitHub Pages project path dan Cloudflare Pages.
- Cache versi baru, update check, fallback halaman utama ketika offline, dan pembersihan cache versi lama.
- Permintaan library XLSX dari CDN dicoba melalui network dan disimpan ke cache runtime setelah berhasil dimuat. Setelah library pernah termuat online, ekspor Excel dapat tetap tersedia saat offline pada browser yang mempertahankan cache. Pemuatan pertama tetap memerlukan internet.
- Penyimpanan mencoba localStorage dan IndexedDB secara terpisah; kegagalan localStorage tidak lagi menghentikan percobaan penyimpanan IndexedDB.
- Pemulihan data tetap mencoba IndexedDB jika localStorage tidak tersedia.
- Cetak menunggu pemuatan gambar, menyiapkan frame sebelum dialog print, dan memiliki pembersihan fallback untuk WebView yang tidak mengirim event afterprint.
- Akses kamera memeriksa HTTPS dan dukungan getUserMedia, serta membersihkan stream jika gagal.
- Metadata PWA mobile ditambahkan.

CATATAN DATA DAN KEAMANAN
- Data siswa/nilai disimpan pada browser/perangkat yang digunakan, bukan otomatis tersinkron ke akun atau perangkat lain. Ekspor/cadangkan data secara berkala.
- Jangan menghapus data situs/browser sebelum membuat cadangan.
- Kamera memerlukan HTTPS (atau localhost) dan izin kamera. Jika gagal, gunakan fitur pilih foto.
- PWA offline tidak berarti seluruh fitur eksternal otomatis tersedia. Modul XLSX dari CDN baru tersedia offline setelah berhasil diunduh/cache ketika online.
- Hasil scan OMR perlu diperiksa sebelum nilai ditetapkan. Hasil dapat dipengaruhi pencahayaan, kemiringan, kualitas cetak, dan kualitas foto.
- Scanner membaca format LJK yang dibuat aplikasi. Ikuti keterangan fitur di aplikasi untuk batasan pembacaan PG/B-S/uraian.

UJI SEBELUM DISTRIBUSI
[ ] Aplikasi terbuka pada URL HTTPS.
[ ] Tidak ada error merah di DevTools Console.
[ ] Manifest terbaca dan ikon tampil.
[ ] Service worker berstatus activated dan scope sesuai subpath situs.
[ ] Install PWA berhasil.
[ ] Data tetap ada setelah refresh dan tutup-buka aplikasi.
[ ] Impor CSV dan ekspor Excel berhasil.
[ ] Preview LJK dan cetak ke printer/PDF menghasilkan halaman terisi (bukan blank).
[ ] Kamera dan pilih foto dapat digunakan.
[ ] Scan, analisis, dan pergantian kelas/mapel diuji dengan data contoh.
[ ] Mode offline diuji setelah aplikasi dan library XLSX pernah dibuka saat online.

CATATAN PERBAIKAN CETAK LAPORAN (23 NOVEMBER 2026)
Tombol "Cetak Paket Semua Laporan" kini memeriksa data siswa terlebih dahulu,
menyusun setiap bagian laporan secara terpisah, dan tidak membatalkan seluruh
paket bila satu bagian laporan mengalami kesalahan. Laporan Remedial Siswa
juga disertakan. Jika ada bagian yang dilewati, aplikasi menampilkan nama
bagian tersebut setelah dialog cetak dibuka.

Jika dialog cetak tidak muncul di APK Android, pastikan WebView/komponen
pembungkus APK mendukung window.print(). Sebagai uji silang, buka URL PWA
melalui Chrome Android lalu pilih Cetak Paket Semua Laporan.
