import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final List<Map<String, String>> anggotaKelompok = [
    {
      'nama': 'Rifqi Arief Nur Rasyid',
      'foto': 'assets/images/anggota1.jpg',
      'nim': '123220162',
      'kelas': 'IF - D',
    },
    {
      'nama': 'Royan Aditya',
      'foto': 'assets/images/anggota2.jpg',
      'nim': '123220164',
      'kelas': 'IF - D',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Kelompok"),
        backgroundColor: Colors.blue[600],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: anggotaKelompok.length,
        itemBuilder: (context, index) {
          final anggota = anggotaKelompok[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(anggota['foto']!),
              ),
              title: Text(
                anggota['nama']!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              subtitle: Text('NIM: ${anggota['nim']!}\nKelas: ${anggota['kelas']!}'),
              isThreeLine: true,
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
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
            ),
          );
        },
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
        backgroundColor: Colors.blue[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: AssetImage(foto),
            ),
            SizedBox(height: 24),
            Text(
              nama,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Divider(height: 32, thickness: 1),
            ListTile(
              leading: Icon(Icons.perm_identity),
              title: Text('NIM'),
              subtitle: Text(nim),
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('Kelas'),
              subtitle: Text(kelas),
            ),
          ],
        ),
      ),
    );
  }
}
