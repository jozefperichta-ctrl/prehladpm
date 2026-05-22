self.addEventListener('push', e => {
  const d = e.data?.json() || {};
  e.waitUntil(
    self.registration.showNotification(d.title || 'Notifikácia', {
      body: d.body || '',
      data: { url: d.url || '/' },
      tag: d.tag || 'notif',
      renotify: true,
    })
  );
});

self.addEventListener('notificationclick', e => {
  e.notification.close();
  const url = e.notification.data?.url || '/';
  e.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(wins => {
      const match = wins.find(w => w.url.includes(new URL(url).pathname));
      return match ? match.focus() : clients.openWindow(url);
    })
  );
});
