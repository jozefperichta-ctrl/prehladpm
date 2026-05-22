# Push notifikácie – nastavenie

## VAPID kľúče (vygenerované)
```
PUBLIC:  BOSSTeG8Zqt4zTxp_JFUlSMYKZrz38XalGjIdZeZcCF2x7Iv8QW0-4FBqdDhzeZK1u4AAyJ6vPIij4USnbC1ymU
PRIVATE: lh3D0Gm4wNesaKFBqs6NUrIEUZCJCgGAfQfeZsr8-4A
```

## 1. Supabase SQL (spustiť v SQL Editor)
Súbor: `supabase/push-setup.sql`

## 2. Edge Function

Ísť do Supabase Dashboard → Edge Functions → New Function → meno: `send-push`
Skopírovať obsah `supabase/functions/send-push/index.ts`

Po deployi nastaviť Secrets (Edge Functions → send-push → Secrets):
- `VAPID_PUBLIC_KEY`  = (PUBLIC kľúč hore)
- `VAPID_PRIVATE_KEY` = (PRIVATE kľúč hore)

`SUPABASE_URL` a `SUPABASE_SERVICE_ROLE_KEY` sú nastavené automaticky.

## 3. Database Webhooks

Ísť do Supabase Dashboard → Database → Webhooks → Create a new hook

### Webhook 1 – Nová ponuka
- Name: `push-on-ponuka`
- Table: `invitations`
- Events: ✓ Update
- URL: `https://cfjkomqxzqflotrqxfyl.supabase.co/functions/v1/send-push`
- HTTP Headers: `Authorization: Bearer <service_role_key>`

### Webhook 2 – Nový denník záznam
- Name: `push-on-dennik`
- Table: `dennik`
- Events: ✓ Insert
- URL: `https://cfjkomqxzqflotrqxfyl.supabase.co/functions/v1/send-push`
- HTTP Headers: `Authorization: Bearer <service_role_key>`

Service role key: nájdeš v Supabase → Settings → API → service_role

## 4. Aktivácia v prehliadači

Po deployi a nastavení webhookov:
1. Otvoriť `index.html` (alebo `ponuky.html`)
2. Kliknúť na 🔔 ikonu v headeri
3. Potvrdiť povolenie notifikácií
