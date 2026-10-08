widget 
1. storeheader
error : garis hitam dan kuning yang overflow di sebelah layar kanan hp kecil ( 320)
layout yang dilanggar : dikarenakan row diberikan lebar tanpa batas yang membuat melebar sampai keluar garis
solusi : tambahkan expanded agar membuat row membagian sisa layar yang ada

2. searchbar
error : layout berantakan disaat membuka keyboard virtual
layout yang dilanggar : komponen imput membutuhkan struktur yang stabil dan konsisten di scrool view
solusi : menggunakana search bawaan yang biasa dengan propert  decoration: InputDecoration(isDense: true) sambil tetap perhatankan k
key: const Key('search-field') agar selain input itu rinkas tetapi tetap dapt dikenali 

3. menutile
error : overflow saat nama produk sangat panjang
layout yang dilanggar : card/colimn tidak dibatasi ukuran sehingga melebihi batas
solusi : gunakan kondisi agar ruang tidak terbung jika kalau deskripsi kosong sambil dibatasi teks dengan maxlines dan  overflow: TextOverflow.ellipsis tidak melebihi batas

4. menucard
error : teks deskripsi dan judul saling menumpuk 
layout yang dilanggar : columns memiliki tempat yang terbatas yang membuat elemen gampang terdorong keluar
solusi : menggunakan expaded agar ruang sisa buat kartu 
dan menggunakan maxline : 2 buat dapat muat 2 baris dengan spacer agar harga dab tombol bisa ke kartu

5. menuscreen 
error : layar overflow saat diubah ke langscape
layout yang dilanggar : column tinggal di scafford jadi semisal vertical sulit buat column menyesuaiakan
solusi: ubah componen customscroolview agar komponen dapat masuk silvertoboxadepter agar layar menyesuaikan semisal layar menyempit sambil memindahan cart bard ke bottomnavigationbar agar selalu terkunci tanpa menganggu 

6. empty state
error : bisa pecah ketika pencarian 0
layout yang dilanggar : data yang kosong diwajibkan menampilkan ikon pesan dll yang terstruktur
solusi : SliverFillRemaining(hasScrollBody: false) di dalam CustomScrollView untuk otomatis container dapat di tengah sambil berisi teks menu tidak ditemukan

7. breakpoint table
error : melebarkan tanpa mengubah struktur visualnya.
layout yang dilanggar : standar buat struktur layout harus berdasarkan ukuran ruang yang diterima widget
solusi : bungkus sktrutur utama  semisal lebih  bakal diubah menjadi crossaxiscount; 4 semisal tidak gunakan yang biasa

8. promostrip
error : rentan memicu overlow dikarenakan format tidak baku
layout yang dilanggar : konten scroll membutuhkan standar agar tidak memakan ruang yang lain
solusi : tambahkan if (promos.isNotEmpty) sebelum memunculkan daftar promo dan memastikan kontainer yang pasti buat ukurannya agar dapat dirapikan dengan helper rupiah()