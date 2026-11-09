# Ball Sort Warna

Game puzzle Ball Sort 2D — tuang bola sampai tiap tabung berisi satu warna.
Godot 4.4, portrait HP (720x1280), renderer GL Compatibility.

## Cara main

1. Tap satu tabung untuk memilihnya (tabung terangkat + panah kuning).
2. Tap tabung lain untuk menuang bola warna atas ke sana.
3. Aturan tuang:
   - Tabung tujuan tidak boleh penuh.
   - Kalau tabung tujuan tidak kosong, warna atasnya harus sama.
   - Yang dituang adalah seluruh rangkaian bola warna sama di atas
     (sebatas ruang kosong di tabung tujuan).
4. Menang kalau semua tabung yang terisi penuh dengan satu warna.

Tombol **↩ Urung** membatalkan satu langkah (angka di tombol = sisa langkah
yang bisa diurungkan), **＋ Tabung** menambah satu tabung kosong (maks 2 per
level), **Petunjuk** menampilkan langkah optimal berikutnya (dihitung solver
BFS di runtime), **⟳ Ulang** mengulang level. Tombol **Level** di kiri atas
membuka layar pilih level.

## Fase 1 — 30 level, hint, save progres

- **30 level** (L1–3 buatan tangan; L4–30 digenerate acak dengan seed tetap
  dan diverifikasi solvable oleh solver BFS dengan aturan tuang yang sama).
  Tingkat kesulitan naik: L4–10 = 3 warna, L11–20 = 4 warna, L21–30 =
  5 warna. Langkah minimal tiap level tercatat untuk penilaian bintang.
- **Layar pilih level** (grid 5×6): nomor level + bintang yang diraih,
  level terkunci sampai level sebelumnya selesai.
- **Save progres** (`user://ball_sort_save.cfg`): level yang terbuka,
  bintang per level, dan langkah terbaik per level tersimpan otomatis.
- **Hint**: solver BFS di runtime mencari solusi optimal dari posisi
  sekarang dan menyorot tabung sumber + menyebut tabung tujuan. Kalau
  pencarian melewati batas state, hint memakai langkah valid apa pun.
- **Deteksi deadlock**: kalau tidak ada langkah valid tersisa (dan belum
  menang), game menampilkan pesan buntu sampai pemain mengurungkan atau
  mengulang level.

## Fase 2 — Animasi tuang, suara, getar

- **Animasi tuang beneran**: bola tidak lagi teleport — bola-bola yang
  dituang terbang dari mulut tabung sumber ke mulut tabung tujuan mengikuti
  busur parabola, satu per satu dengan jeda kecil (`scripts/pour_fx.gd`).
  Selama animasi berjalan, input diblokir; state baru di-commit setelah
  animasi selesai, jadi undo tetap mengembalikan keadaan sebelum tuang.
- **Suara sintesis prosedural** (`scripts/sound.gd`): semua suara dibuat
  di kode ke AudioStreamWAV 16-bit (tanpa file audio sama sekali) — pilih
  tabung, klik tombol, tuang (sapuan nada turun), tabung selesai (dua nada),
  langkah gagal (bunyi kotak rendah), menang (arpeggio 4 nada).
- **Tombol mute** di layar pilih level ("Suara: Nyala/Mati"), tersimpan di
  file save yang sama.
- **Getar** (`Input.vibrate_handheld`): 60 ms saat tuang berhasil, 40 ms
  saat langkah gagal, 120 ms saat menang.

## Fase 3 — Loading, menu utama, 4 mode, pause (v1.2.0)

- **Loading** (`scenes/loading.tscn`): splash + progress bar nyata (muat save,
  preload scene, siapkan suara, ~1,6 detik) + tips bergilir, lalu ke menu utama.
- **Menu utama** (`scenes/menu.tscn`): tombol MULAI MAIN (lanjut level terakhir),
  Mode, Harian (dengan streak), Pengaturan, Cara Main; footer progres
  (level, bintang, skor waktu). Semua tujuan ≤ 2 tap.
- **4 mode** (`scenes/mode_select.tscn`, `scripts/game_state.gd` autoload):
  Klasik (30 level, santai), Waktu (90 detik per papan, skor akumulasi antar
  papan), Sulit (langkah terbatas = langkah minimal + 3, bintang terpisah),
  Harian (satu puzzle per hari dari seed tanggal, streak tersimpan).
  Save dipusatkan di `GameState` (`user://ball_sort_save.cfg`) dengan format
  lama tetap terbaca, jadi progres pemain tidak hilang.
- **Pause + panel gagal** di dalam game, plus layar Pengaturan (suara, getar,
  reset progres dengan konfirmasi) dan Cara Main (3 langkah + booster).
- **Verifikasi headless Godot 4.4:** smoke test alur lengkap 54/54 lolos
  (loading → menu → mode → pengaturan → cara main → klasik/hard/timed/daily,
  termasuk menang level 1 optimal 10 langkah, 3 bintang). Satu bug sempat
  ketemu di tes ini dan sudah diperbaiki: skor mode Waktu sempat ter-reset
  tiap "Papan Berikutnya" — sekarang skor akumulasi sampai sesi berakhir.

## Fase 4 — Portrait tegak + visual juicy + BGM (v1.3.0)

- **Portrait tegak:** `display/window/stretch/aspect="keep"` (dulu "expand"
  yang membuat layout portrait 720×1280 melebar di layar landscape) +
  `display/window/handheld/orientation=1` (portrait) — game selalu tampil
  tegak, dengan letterbox kalau jendelanya landscape.
- **Bola 3D glossy** (digambar kode, tanpa file gambar): alas gelap, badan,
  kilau atas-kiri, titik specular, garis tepi — dipakai tabung (`tube.gd`)
  dan animasi tuang (`pour_fx.gd`).
- **Tabung kaca:** badan tembus pandang, kilau vertikal, bibir atas,
  bayangan di lantai; tabung terpilih tetap naik + panah emas, tabung
  selesai tetap berkilau + bintang emas.
- **Tombol pill 3D:** bayangan bawah (timbul), mengecil saat ditekan;
  palet baru — hijau #2ECC71, biru #3498DB, emas #F39C12, merah #E74C3C
  (tombol Ulang), latar gradien #14172B → #0B0C16.
- **Judul kartun:** "BALL SORT" emas dengan outline putih tebal + bayangan
  (menu, loading, judul game); ikon aplikasi baru `icon.svg` (tabung miring
  menuang bola glossy) juga tampil di layar loading.
- **Konfeti menang** (`scripts/confetti.gd`): 90 potongan warna-warni jatuh
  + berputar tiap kali menang, hilang sendiri.
- **Audio:** SFX diperkaya (select pop, tuang "plip", selesai 3 nada,
  menang fanfare 6 nada) + **BGM loop 8 detik prosedural** (pad akor
  Am7–Fmaj7–Cmaj7–G6 + melodi marimba pentatonik, tanpa file audio) yang
  jalan terus dari autoload `GameState`, dengan toggle Musik di Pengaturan.
- **Verifikasi headless Godot 4.4:** smoke test 65/65 lolos (54 lama +
  11 baru: portrait, palet, tombol 3D, outline judul, BGM loop, toggle
  musik, konfeti).
- **Tes di HP (Godot 4.7, 2026-11-09 23:56 WIB):** game jalan, level 1
  dimenangkan Diane dalam 11 langkah, 2 bintang — migrasi 4.4→4.7 tidak
  merusak apa pun.

## Fase 5 — Aset gambar persis board + perbaikan force-close (v1.4.0)

- **Analisis video tes HP (2026-11-10 00:20 WIB):** game jalan bagus
  (loading → menu → pilih level → level 2, bola glossy tampil), lalu
  **proses berhenti sendiri** ("Debugging process stopped") dan di run
  kedua tampilannya **berputar 90°** — menu + pilih level tampil miring.
  Kedua gejala ini ciri konflik orientasi: `window/handheld/orientation=1`
  meminta aktivitas Android berputar ke portrait sementara jendela editor
  landscape; perubahan orientasi membuat Android menghancurkan + membuat
  ulang aktivitas (proses game mati) dan framebuffer tampil terputar.
  **Perbaikan:** baris `orientation` dihapus dari `project.godot`;
  portrait tetap dijamin oleh `stretch/aspect="keep"` (kolom portrait
  dengan letterbox di jendela apa pun) tanpa memaksa orientasi OS.
  Kalau setelah ini masih force-close, kirim screenshot panel Output
  (baris ERROR di atas "Debugging process stopped") untuk diagnosis lanjut.
- **Aset gambar SVG (baru, `res://assets/`):** tampilan sekarang memakai
  file gambar sesuai board referensi, bukan lagi digambar kode —
  `assets/balls/ball_*.svg` (7 warna, gradien radial + kilau),
  `assets/tubes/tube_glass.svg` (kaca + kilau + bibir),
  `assets/ui/star_gold.svg` + `star_empty.svg`,
  `assets/ui/arrow_down.svg` (panah penunjuk tabung terpilih),
  `assets/ui/lock.svg` (gembok level terkunci). Tabung + animasi tuang
  menggambar tekstur ini (`draw_texture_rect`).
- **Kartu level ala board:** nomor + 3 bintang tekstur (emas/abu sesuai
  raihan), level terkunci menampilkan gembok emas.
- **Panel menang:** 3 bintang tekstur emas/abu (dulu teks ★).
- **HUD bar emas satu baris (ala board):** bar ber-border emas berisi
  [Level] [LEVEL 1] [BALL SORT] [Langkah 0] [II]; pesan ("Warna atas
  tidak cocok!") pindah ke bawah bar.
- **Slider volume di Pengaturan (ala board):** "Volume Suara" + "Volume
  Musik" (0–100) di samping toggle Suara/Musik; nilai tersimpan di save
  (`settings/sfx_volume`, `settings/music_volume`), BGM berubah langsung.
- **Verifikasi headless Godot 4.4:** smoke test 77/77 lolos (65 lama +
  12 baru: orientation dihapus, 5 aset SVG, volume default, 2 slider,
  kartu level bintang + gembok, HUD bar, bintang menang tekstur).

## Tampilan (UI/UX)

Riset dari screenshot game Ball Sort / Water Sort yang ramai dimainkan +
praktik HUD game puzzle mobile:

- **Background gradient indigo gelap** (atas terang, bawah gelap) + **rak putih**
  di bawah tabung — tabung terlihat berdiri di atas rak, seperti game aslinya.
- **HUD minimal, papan adalah UI-nya:** atas cuma ada pill **LEVEL** (kiri),
  pill **Langkah** (kanan), dan **3 titik progres level** di tengah
  (emas = level berjalan, hijau = selesai, redup = belum). Tengah layar suci:
  tidak ada yang menutupi tabung.
- **Tabung kaca bersudut membulat**, bola glossy dengan highlight; tabung yang
  dipilih **naik + border emas + panah kuning**; tabung yang selesai
  **berkilau emas + bintang**.
- **Feedback tiap aksi:** tuang berhasil = tabung tujuan "pop" membesar sebentar;
  tuang gagal = tabung digoyang + pesan kenapa ("Tabung tujuan sudah penuh!" /
  "Warna atas tidak cocok!").
- **Panel menang:** bingkai emas, **bintang 1–3** dibanding langkah minimal
  (3 bintang kalau ≤ minimal, 2 kalau ≤ minimal+5), info langkah, tombol emas
  "Level Berikutnya".

## Level

| Level | Warna | Tabung | Langkah minimal |
| --- | --- | --- | --- |
| 1 | 3 (merah, hijau, biru) | 5 (2 kosong) | 10 |
| 2 | 4 (+ kuning) | 6 (2 kosong) | 13 |
| 3 | 5 (+ ungu) | 7 (2 kosong) | 16 |

Semua level sudah dibuktikan bisa diselesaikan dengan solver BFS
(menggunakan aturan tuang yang sama dengan game ini).

## Cara buka

1. Clone repo ini, atau download ZIP-nya.
2. Buka Godot — Import — pilih `project.godot` di folder ini.
3. Tekan Run (F5). Di HP: tap tabung langsung di layar sentuh.

## Struktur

| File | Isi |
| --- | --- |
| `project.godot` | Konfigurasi: main scene, viewport portrait 720x1280, aspect keep, GL Compatibility (tanpa orientation lock — lihat Fase 5) |
| `assets/balls/`, `assets/tubes/`, `assets/ui/` | Aset SVG: 7 bola glossy, tabung kaca, bintang emas/abu, panah, gembok |
| `scenes/main.tscn` | Scene utama: judul, HUD bar emas, wadah tabung, tombol, panel menang |
| `scripts/main.gd` | Logika game: level, pilih/tuang, undo, menang/kalah, UI |
| `scripts/tube.gd` | Satu tabung: gambar tabung kaca + bola (tekstur SVG), tap, status penuh/seragam |
| `scripts/confetti.gd` | Semburan konfeti saat menang |
| `scripts/sound.gd` | SFX + BGM loop, semua disintesis prosedural (tanpa file audio); volume SFX/BGM |
| `scripts/game_state.gd` | Autoload: save progres + mode + streak harian + skor waktu + volume |
| `scripts/loading.gd`, `menu.gd`, `mode_select.gd`, `settings.gd`, `howto.gd` | Layar loading, menu utama, pilih mode, pengaturan, cara main |
| `scripts/ui_kit.gd` | Helper gaya UI bersama (tombol, label, panel, tabung hias) |
| `icon.svg` | Ikon project |

## Lisensi

MIT — lihat `LICENSE`.
