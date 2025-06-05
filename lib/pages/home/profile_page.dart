import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final List<Map<String, String>> anggotaKelompok = [
    {
      'nama': 'Rifqi Arief Nur Rasyid',
      'foto': 'assets/images/tewas.jpg',
      'nim': '123220162',
      'kelas': 'IF - D',
    },
    {
      'nama': 'Royan Aditya',
      'foto': 'assets/images/bangun_tidur.png', // gunakan logo.png jika tidak ada anggota2.jpg
      'nim': '123220164',
      'kelas': 'IF - D',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Kelompok"),
        backgroundColor: const Color.fromARGB(255, 244, 241, 241),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: anggotaKelompok.length,
          itemBuilder: (context, index) {
            final anggota = anggotaKelompok[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnggotaProfilePage(
                      nama: anggota['nama']!,
                      foto: anggota['foto']!,
                      nim: anggota['nim']!,
                      kelas: anggota['kelas']!,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundImage: AssetImage(anggota['foto']!),
                        // Tambahkan child jika ingin debug error
                        // child: Image.asset(anggota['foto']!, errorBuilder: (c, o, s) => Icon(Icons.error)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18.0, horizontal: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anggota['nama']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.badge,
                                    size: 16, color: Colors.blueGrey[700]),
                                const SizedBox(width: 6),
                                Text(
                                  'NIM: ${anggota['nim']}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.class_,
                                    size: 16, color: Colors.blueGrey[700]),
                                const SizedBox(width: 6),
                                Text(
                                  'Kelas: ${anggota['kelas']}',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AnggotaProfilePage extends StatelessWidget {
  final String nama;
  final String foto;
  final String nim;
  final String kelas;

  AnggotaProfilePage({
    required this.nama,
    required this.foto,
    required this.nim,
    required this.kelas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil $nama'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.13),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(foto),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                nama,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.perm_identity,
                          color: Colors.black87),
                      title: const Text('NIM',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(nim),
                    ),
                    const Divider(height: 1, thickness: 1),
                    ListTile(
                      leading: const Icon(Icons.class_, color: Colors.black87),
                      title: const Text('Kelas',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(kelas),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text('Kembali',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
