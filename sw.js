/* KAU PWA Service Worker — path-safe untuk GitHub Pages dan Cloudflare Pages. */
const VERSION = 'kau-pwa-v3.1.0';
const BASE_URL = new URL('./', self.registration.scope);
const SHELL_CACHE = `${VERSION}-shell`;
const RUNTIME_CACHE = `${VERSION}-runtime`;
const APP_SHELL = [
  new URL('./', BASE_URL).href,
  new URL('./index.html', BASE_URL).href,
  new URL('./manifest.json', BASE_URL).href,
  new URL('./icons/icon-192.png', BASE_URL).href,
  new URL('./icons/icon-512.png', BASE_URL).href,
  new URL('./icons/icon-maskable-512.png', BASE_URL).href
];
const XLSX_CDN = 'https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js';

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(SHELL_CACHE);
    await cache.addAll(APP_SHELL);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter(key => key.startsWith('kau-pwa-') && key !== SHELL_CACHE && key !== RUNTIME_CACHE).map(key => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') self.skipWaiting();
});

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;
  const response = await fetch(request);
  if (response && response.ok) {
    const cache = await caches.open(SHELL_CACHE);
    cache.put(request, response.clone()).catch(() => {});
  }
  return response;
}

async function networkFirst(request) {
  const cache = await caches.open(RUNTIME_CACHE);
  try {
    const response = await fetch(request);
    if (response && (response.ok || response.type === 'opaque')) cache.put(request, response.clone()).catch(() => {});
    return response;
  } catch (error) {
    const cached = await cache.match(request);
    if (cached) return cached;
    throw error;
  }
}

self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);

  // Simpan library XLSX dari CDN setelah berhasil dimuat online agar bisa dipakai offline berikutnya.
  if (url.href === XLSX_CDN) {
    event.respondWith(networkFirst(request).catch(() => new Response('Library XLSX belum pernah tersimpan. Hubungkan internet lalu muat ulang aplikasi.', { status: 503, headers: { 'Content-Type': 'text/plain; charset=utf-8' } })));
    return;
  }

  if (url.origin !== self.location.origin) return;
  if (request.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        const response = await fetch(request);
        if (response && response.ok) {
          const cache = await caches.open(SHELL_CACHE);
          cache.put(new URL('./index.html', BASE_URL).href, response.clone()).catch(() => {});
        }
        return response;
      } catch (error) {
        return (await caches.match(new URL('./index.html', BASE_URL).href)) || (await caches.match(new URL('./', BASE_URL).href)) || Response.error();
      }
    })());
    return;
  }
  event.respondWith(cacheFirst(request).catch(async () => (await caches.match(new URL('./index.html', BASE_URL).href)) || Response.error()));
});
