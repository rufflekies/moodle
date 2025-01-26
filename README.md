<h1> Script Instalasi dan Uninstalasi Moodle </h1>
   Tersedia dua script Bash untuk memudahkan proses instalasi dan uninstalasi Moodle di server berbasis Linux. Script-script ini dirancang untuk menyederhanakan dan mengotomatisasi pengelolaan instalasi Moodle dengan mengatur server Apache, database MariaDB/MySQL, serta konfigurasi file Moodle.
<h2> 1. moodle_install.sh - Script Instalasi Moodle</h2>
Deskripsi:
Script ini digunakan untuk menginstal Moodle di server Linux, mengonfigurasi database MariaDB, serta mengatur server Apache untuk menjalankan Moodle. Script ini juga akan mengunduh dan mengekstrak file Moodle, mengatur izin file yang tepat, serta mengonfigurasi virtual host Apache agar Moodle dapat diakses melalui server.
<h3>Penggunaan:</h3>

1. Copy script ke clipboard Anda

2. Buka cli, lalu buat dan edit file moodle_install.sh menggunakan perintah:
           
       nano moodle_install.sh
3. Tambahkan kode script yang sudah disiapkan ke dalam file moodle_install.sh.
4. Beri izin eksekusi pada script dengan menjalankan perintah:

       chmod +x moodle_install.sh
5. Jalankan script untuk mulai menginstal Moodle:

       ./moodle_install.sh
<h2> 2. moodle_uninstall.sh - Script Uninstalasi Moodle</h2>
Deskripsi:
Script ini digunakan untuk menghapus seluruh instalasi Moodle dari server, termasuk menghapus database, file instalasi, serta konfigurasi virtual host Apache. Script ini juga akan menghapus aturan firewall untuk HTTP dan HTTPS serta mengembalikan konfigurasi default Apache setelah penghapusan Moodle.
<h3>Penggunaan:</h3>

1. Copy script ke clipboard Anda

2. Buka cli, lalu buat dan edit file moodle_uninstall.sh menggunakan perintah:
           
       nano moodle_uninstall.sh
3. Tambahkan kode script yang sudah disiapkan ke dalam file moodle_uninstall.sh.
4. Beri izin eksekusi pada script dengan menjalankan perintah:

       chmod +x moodle_uninstall.sh
5. Jalankan script untuk mulai menginstal Moodle:

       ./moodle_uninstall.sh
