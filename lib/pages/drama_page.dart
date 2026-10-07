import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../datasources/drama_remote_datasource.dart';
import '../repositories/drama_repository.dart';
import '../models/drama_model.dart';

class DramaPage extends StatefulWidget {
  const DramaPage({super.key});

  @override
  State<DramaPage> createState() => _DramaPageState();
}

class _DramaPageState extends State<DramaPage> {
  late final DramaRepository repository;
  late Future<List<DramaModel>> dramaFuture;

  @override
  void initState() {
    super.initState();
    // Ganti via: flutter run --dart-define=BASE_URL=http://<ip-laptop>:3000
    // Default 10.0.2.2 = localhost laptop dari emulator Android.
    // Kalau pakai HP fisik, isi dengan IP LAN laptop (contoh: http://192.168.1.5:3000).
    const baseUrl = String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'http://10.0.2.2:3000',
    );
    final dataSource = DramaRemoteDataSource(
      baseUrl: baseUrl,
      client: http.Client(),
    );
    repository = DramaRepository(dataSource: dataSource);
    dramaFuture = repository.getDramaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Series'),
        backgroundColor: Colors.grey[850],
      ),
      body: FutureBuilder<List<DramaModel>>(
        future: dramaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final dramas = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: dramas.length,
            itemBuilder: (context, index) {
              final drama = dramas[index];
              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Render Cover Gambar dari URL
                    Image.network(
                      drama.cover,
                      width: 95,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 95,
                          height: 140,
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    // Detail Teks Drakor
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                          right: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${drama.title} (${drama.year})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '⭐ ${drama.rating}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              drama.genres.join(', '),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              drama.synopsis,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
