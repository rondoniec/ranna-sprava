# Ranná Správa — Server Infrastructure

*How the backend was set up, how it works, and how to replicate it.*

---

## Overview

The architecture separates concerns cleanly into three layers:

```
Visitor browser
 ↓ visits
rannasprava.sk (GitHub Pages — static HTML/CSS/JS)
 ↓ signup form POSTs to
api.rannasprava.sk (VPS — Node.js + Caddy)
 ↓ calls
api.brevo.com (Brevo — stores email, sends newsletters)
```

The reason for this split: the Brevo API key must never appear in frontend code — anyone could view source and steal it. The VPS holds the key privately in an environment variable, acts as a secure middleman, and the frontend never sees it.

---

## Stack

| Layer | Tool | Why |
|---|---|---|
| Frontend hosting | GitHub Pages | Free, automatic HTTPS, no server |
| Reverse proxy | Caddy | Auto-manages HTTPS certificates, zero config |
| App runtime | Node.js 20 | Simple, fast, AI-friendly to write |
| Process manager | PM2 | Keeps Node running forever, restarts on crash |
| Email provider | Brevo | Free up to 300 emails/day, unlimited contacts |

---

## VPS Directory Structure

```
~/api/
├── index.js ← the Node app
├── .env ← secret keys (never commit this)
├── package.json
└── node_modules/
```

---

## The Node App (`~/api/index.js`)

A minimal Express server with one real endpoint and one health check.

### What it does

**`POST /subscribe`**
- Receives `{ email }` from the frontend form
- Validates the email (basic format check)
- Calls Brevo API with the email and list ID
- Returns `{ success: true }` or an error

**`GET /health`**
- Returns `{ ok: true }`
- Used to verify the server is running

### Key decisions

- `cors()` is configured to only accept requests from your own domains — no random sites can abuse your endpoint
- `updateEnabled: true` in the Brevo call means re-subscribing an existing contact doesn't throw an error
- The API key lives only in `.env`, loaded via `dotenv` — never hardcoded

---

## The `.env` File

```
BREVO_API_KEY=your_key_here
PORT=3001
```

**Never commit this file to git.** Add `.env` to `.gitignore` if you ever put the api folder in a repo.

To edit it on the server:
```bash
nano ~/api/.env
```

After changing the key, restart the app:
```bash
pm2 restart ranna-api
```

---

## Caddy (`/etc/caddy/Caddyfile`)

```
api.rannasprava.sk {
 reverse_proxy localhost:3001
}
```

Caddy listens on port 443 (HTTPS), handles the TLS certificate automatically via Let's Encrypt, and forwards traffic to Node on port 3001. No manual certificate renewal needed — ever.

To reload after config changes:
```bash
sudo systemctl reload caddy
```

---

## PM2 — Process Management

PM2 keeps the Node app alive. If it crashes, PM2 restarts it automatically.

### Common commands

```bash
pm2 status # see all running processes
pm2 logs ranna-api # live logs
pm2 restart ranna-api # restart after code changes
pm2 stop ranna-api # stop
pm2 start index.js --name ranna-api # start fresh
pm2 save # save process list
pm2 startup # generate systemd command so PM2 survives reboots
```

After any change to `index.js`, always run `pm2 restart ranna-api`.

---

## DNS Records

At your domain registrar, four A records point the root domain to GitHub's servers, and one A record points the `api` subdomain to your VPS:

```
A @ 185.199.108.153 ← GitHub Pages
A @ 185.199.109.153 ← GitHub Pages
A @ 185.199.110.153 ← GitHub Pages
A @ 185.199.111.153 ← GitHub Pages
CNAME www rondoniec.github.io
A api YOUR_VPS_IP ← your server
```

TTL 600 is fine. Changes propagate within 10–30 minutes typically.

---

## Brevo Setup

1. Account at **brevo.com**
2. Contacts → Lists → create a list called "Ranná Správa" — it gets assigned ID 2 (ID 1 is the default "All contacts" list)
3. Settings → API Keys → generate a key → paste it into `.env` on the VPS
4. When sending a newsletter: Campaigns → New campaign → paste the vydanie HTML → select the list → send or schedule

The list ID `2` is hardcoded in `index.js`. If you ever delete and recreate the list, update that number in the code and restart PM2.

---

## How to Replicate from Scratch

If you ever need to move to a new VPS or rebuild:

### 1. Install dependencies

```bash
# Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# PM2
sudo npm install -g pm2

# Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install -y caddy
```

### 2. Create the app

```bash
mkdir -p ~/api && cd ~/api
npm init -y
npm install express cors dotenv
```

### 3. Create `.env`

```bash
nano .env
```

```
BREVO_API_KEY=your_key_here
PORT=3001
```

### 4. Create `index.js`

```js
require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors({
 origin: ['https://rannasprava.sk', 'https://www.rannasprava.sk', 'https://rondoniec.github.io']
}));

app.post('/subscribe', async (req, res) => {
 const { email } = req.body;

 if (!email || !email.includes('@') || email.length > 254) {
 return res.status(400).json({ error: 'Neplatný email.' });
 }

 try {
 const response = await fetch('https://api.brevo.com/v3/contacts', {
 method: 'POST',
 headers: {
 'Content-Type': 'application/json',
 'api-key': process.env.BREVO_API_KEY
 },
 body: JSON.stringify({
 email: email.toLowerCase().trim(),
 listIds: [2],
 updateEnabled: true
 })
 });

 if (response.ok || response.status === 204) {
 return res.json({ success: true });
 }

 if (response.status === 400) {
 const body = await response.json();
 if (body.code === 'duplicate_parameter') {
 return res.json({ success: true, already: true });
 }
 }

 throw new Error('Brevo error: ' + response.status);

 } catch (err) {
 console.error(err);
 return res.status(500).json({ error: 'Chyba servera. Skús znova.' });
 }
});

app.get('/health', (req, res) => res.json({ ok: true }));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`API running on port ${PORT}`));
```

### 5. Start with PM2

```bash
pm2 start index.js --name ranna-api
pm2 save
pm2 startup
# run the command PM2 prints
```

### 6. Configure Caddy

```bash
sudo nano /etc/caddy/Caddyfile
```

```
api.rannasprava.sk {
 reverse_proxy localhost:3001
}
```

```bash
sudo systemctl reload caddy
```

### 7. Update DNS

Add `A api YOUR_NEW_VPS_IP` at your registrar.

### 8. Verify

```bash
curl https://api.rannasprava.sk/health
# {"ok":true}
```

---

## Ongoing Maintenance

### Rotating the Brevo API key

1. Generate new key in Brevo → Settings → API Keys
2. `nano ~/api/.env` → update the key
3. `pm2 restart ranna-api`
4. Test with `curl https://api.rannasprava.sk/health`

### Checking if emails are being saved

Brevo → Contacts → your list → see all subscribers with signup timestamps.

### If the API goes down

```bash
pm2 logs ranna-api # check for errors
pm2 restart ranna-api
sudo systemctl status caddy
```

### Updating the Node app

Edit `~/api/index.js` → `pm2 restart ranna-api`. Changes are live in seconds.

---

*Last updated: March 2026*
