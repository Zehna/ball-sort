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

Tombol **↩ Urung** membatalkan satu langkah, **⟳ Ulang** mengulang level.

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
| `project.godot` | Konfigurasi: main scene, viewport portrait 720x1280, GL Compatibility |
| `scenes/main.tscn` | Scene utama: judul, HUD, wadah tabung, tombol, panel menang |
| `scripts/main.gd` | Logika game: level, pilih/tuang, undo, menang/kalah, UI |
| `scripts/tube.gd` | Satu tabung: gambar tabung + bola, tap, status penuh/seragam |
| `icon.svg` | Ikon project |

## Lisensi

MIT — lihat `LICENSE`.
