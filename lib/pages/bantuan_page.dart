import 'package:flutter/material.dart';

class BantuanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Bantuan'),
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📖 Bantuan Penggunaan Aplikasi',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30), // Gap between title and steps

              // Stopwatch Section
              _buildSection(
                title: '🔹 Stopwatch',
                description:
                    'Digunakan untuk mengukur waktu secara akurat. Ikuti langkah berikut:',
                steps: [
                  'Tekan tombol "Start" untuk mulai mengukur waktu.',
                  'Tekan tombol "Stop" untuk menghentikan pengukuran.',
                  'Tekan tombol "Reset" untuk mengatur ulang stopwatch.',
                ],
              ),

              // Jenis Bilangan Section
              _buildSection(
                title: '🔹 Jenis Bilangan',
                description:
                    'Menentukan jenis bilangan yang dimasukkan. Berikut caranya:',
                steps: [
                  'Masukkan angka ke dalam kolom input.',
                  'Tekan tombol "Cek" untuk menentukan jenis bilangan (prima, bulat, negatif, atau desimal).',
                ],
              ),

              // Tracking LBS Section
              _buildSection(
                title: '🔹 Tracking LBS',
                description:
                    'Melacak lokasi perangkat menggunakan fitur lokasi. Langkah-langkah:',
                steps: [
                  'Pastikan GPS di perangkat aktif.',
                  'Tekan tombol "Lacak Lokasi" untuk melihat posisi Anda di peta.',
                ],
              ),

              // Konversi Waktu Section
              _buildSection(
                title: '🔹 Konversi Waktu',
                description:
                    'Mengonversi satuan waktu dari tahun ke jam, menit, dan detik. Caranya:',
                steps: [
                  'Masukkan jumlah tahun yang ingin dikonversi.',
                  'Tekan tombol "Konversi" untuk melihat hasil konversi dalam jam, menit, dan detik.',
                ],
              ),

              // Situs Rekomendasi Section
              _buildSection(
                title: '🔹 Situs Rekomendasi',
                description:
                    'Menampilkan daftar situs bermanfaat. Ikuti langkah berikut:',
                steps: [
                  'Pilih situs yang ingin dikunjungi dari daftar yang disediakan.',
                  'Tekan link situs untuk membuka halaman di browser.',
                ],
              ),

              // Profil Section
              _buildSection(
                title: '👤 Profil',
                description:
                    'Menampilkan informasi tentang pengembang aplikasi.',
                steps: [
                  'Tekan tombol "Profil" pada menu utama untuk melihat informasi anggota pengembang.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This builds each section's UI with title, description, and steps
  Widget _buildSection({
    required String title,
    required String description,
    required List<String> steps,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(description, style: TextStyle(fontSize: 16)),
          SizedBox(height: 12),
          ...steps.map(_buildStep).toList(),
        ],
      ),
    );
  }

  // Build each step in the instructions
  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
