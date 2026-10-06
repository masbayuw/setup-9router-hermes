# Cara Setup 9Router + Hermes di VPS — Gampang Banget

Gue jelasin step-by-step biar lo bisa pasang AI agent sendiri di VPS. Gak ribet, langsung praktek.

---

## 1. Nyiapin VPS Baru

Baru sewa VPS? Update dulu sistemnya, install Node.js 20, beres.

**SSH masuk, jalanin:**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ufw
```

**Install Node.js 20 (butuh ini buat 9Router):**

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v  # cek versi, mesti v20.x ke atas
```

> **Catatan:** Node ini khusus buat 9Router doang. Nanti Hermes bawa runtime sendiri yang terpisah.

**Ceklis:**
- ✅ Sistem udah diupdate
- ✅ Node.js 20+ terinstall

---

## 2. Install 9Router

9Router itu gateway cerdas buat manage banyak AI provider sekaligus. Kalau satu provider down, otomatis fallback ke yang lain. Di VPS tinggal install paket global, gak perlu clone repo atau build manual.

**Install:**

```bash
sudo npm install -g 9router
9router --version
```

**Jalanin:**

```bash
9router
```

Pilih **Hide to Tray** biar jalan di background.

**Buka port 20128 di firewall VPS:**

```bash
sudo ufw allow 20128/tcp
sudo ufw enable
sudo ufw status
```

**Buka port di Tencent Cloud Console:**

Masuk Tencent Cloud Console → instance → firewall → add rule.
- Protocol: `TCP`
- Port: `20128`
- Source: `0.0.0.0/0`

Setelah aktif, buka `http://IP-VPS:20128` dari browser lo.

**Ceklis:**
- ✅ 9Router jalan sebagai background process
- ✅ UFW ngizinkan port 20128
- ✅ Security Group Tencent udah dibuka
- ✅ Dashboard bisa diakses dari browser

---

## 3. Masukin API Key Provider

9Router support 40+ provider. Yang paling sering dipake: NVIDIA, OpenRouter, Cloudflare Workers AI.

**Masuk Dashboard → Providers → Add Provider:**

**NVIDIA:**
```
Provider: NVIDIA
API Key: <NVIDIA_NIM_API_KEY>
```

**OpenRouter:**
```
Provider: OpenRouter
API Key: <OPENROUTER_API_KEY>
```

**Cloudflare Workers AI:**
```
Provider: Cloudflare Workers AI
API Token: <CLOUDFLARE_API_TOKEN>
Account ID: <CLOUDFLARE_ACCOUNT_ID>
```

> **Catatan:** Cloudflare butuh API Token DAN Account ID. Isi keduanya, validasi koneksi dulu sebelum save.

**Ceklis:**
- ✅ NVIDIA API key masuk & tervalidasi
- ✅ OpenRouter API key masuk & tervalidasi
- ✅ Cloudflare API Token + Account ID masuk & tervalidasi

---

## 4. Install Hermes + Connect ke 9Router

Hermes itu AI agent framework dari Nous Research. Ada memory system, skill system, semuanya built-in. Installernya self-contained, jadi dependency-nya disiapkan otomatis.

**Install:**

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc
hermes doctor  # cek semua dependency oke
```

**Setup wizard (sekalian konfig provider):**

```bash
hermes setup
```

Pas wizard nanya provider, isi:

```
Base URL: http://localhost:20128/v1
API Key: <API key dari dashboard 9Router>
Model: nvidia/<model-id> atau openrouter/<model-id>
```

Mau ganti model? Tinggal:

```bash
/model nvidia/model-id
```

> **Catatan:** `hermes setup` itu wizard all-in-one. Provider, model, tools dikonfig sekali jalan. Gak perlu command terpisah.

**Ceklis:**
- ✅ Installer sukses, `hermes doctor` bersih
- ✅ Wizard selesai, provider diarahin ke 9Router
- ✅ Test chat via CLI udah respon

---

## 5. Connect ke Telegram Bot

Satu gateway process buat Telegram (dan platform lain kalau mau).

**Setup:**

```bash
hermes gateway setup
# ikutin wizard: pilih Telegram, masukin Bot Token dari @BotFather
hermes gateway install
hermes gateway start
hermes gateway status
```

Test kirim pesan pertama ke bot buat mastiin nyambung.

> **Catatan:** Gateway yang sama juga support Discord, Slack, WhatsApp, Signal. Bisa nyala bareng dari satu proses.

**Ceklis:**
- ✅ Bot token dari BotFather udah dimasukin
- ✅ Bot merespon pesan test pertama

---

## 6. Kenali Identitas Agent

Hermes punya format native buat persona & memory:

```
~/.hermes/SOUL.md      → identitas & karakter agent lo
~/.hermes/MEMORY.md    → long-term memory (agent yang kelola)
~/.hermes/USER.md      → profil user, dibangun otomatis dari histori
~/.hermes/skills/      → skill folder, YAML frontmatter
```

**"Closed learning loop":** Setelah selesai task kompleks, agent bisa nyimpen prosedur yang berhasil sebagai skill reusable. Terus diperbaiki pas dipake lagi.

**Ceklis:**
- ✅ `SOUL.md` diisi (identitas agent)
- ✅ `USER.md` dicek (profil user)
- ✅ Konsep skill system udah paham

---

## 7. Setup Folder Credentials Personal

Pisahin wallet, X, Google, dan Telethon session. Tiap secret disimpan aman per akun.

**Struktur folder:**

```
~/.hermes/credentials/
├── wallet/
│   ├── wallet1.env
│   ├── wallet2.env
│   └── ...
├── x/
│   └── x1.env
├── google/
│   └── google1.env
└── telethon/
    └── sessions/
```

**Prompt ke Hermes (via chat/Telegram):**

```
Buatin folder ~/.hermes/credentials/ dengan subfolder wallet, x,
google, dan telethon. Folder ini khusus nyimpen file personal env
buat wallet, login X, login Google/email, dan Telethon session.

Lalu generate 5 wallet EVM baru yang khusus dioperasikan Hermes.
Simpan address dan private key tiap wallet dalam file .env terpisah:
wallet/wallet1.env sampai wallet/wallet5.env.

Amanin semua folder dengan chmod 700 dan semua file credentials
dengan chmod 600. Jangan tampilkan password, session, mnemonic,
atau private key mentah di chat, terminal output, atau log.
```

> ⛔ **JANGAN** buka atau `cat` file credentials di terminal yang lagi dibagikan. Tampilkan struktur folder dan nama file aja. Jangan pernah ekspos password, session, mnemonic, atau private key.

> ⚠ **Folder ini kredensial operasional asli.** Jangan commit ke Git, jangan upload ke cloud storage publik. Pastikan permission file tetap `600`.

**Ceklis:**
- ✅ Subfolder wallet, X, Google, Telethon dibuat terpisah
- ✅ 5 wallet EVM khusus Hermes berhasil dibuat
- ✅ Tiap wallet disimpan sebagai file `.env` terpisah
- ✅ Folder `chmod 700`, file credentials `chmod 600`
- ✅ Gak ada kredensial mentah keliatan di layar atau log

---

## Done

Lo sekarang punya:
- 9Router yang manage multi-provider dengan auto-fallback
- Hermes agent dengan memory & skill system
- Telegram bot yang siap dipake
- Credentials aman & terpisah per akun

Tinggal mainin agent lo sekarang. Enjoy.
