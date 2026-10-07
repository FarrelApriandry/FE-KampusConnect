import '../datasources/drama_remote_datasource.dart';
import '../models/drama_model.dart';

class DramaRepository {
  final DramaRemoteDataSource dataSource;

  DramaRepository({required this.dataSource});

  Future<List<DramaModel>> getDramaList() async {
    try {
      final rawData = await dataSource.getDramasRaw();
      final List<dynamic> list = rawData['data'];
      return list.map((item) => DramaModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Repository Failure: $e');
    }
  }
}
