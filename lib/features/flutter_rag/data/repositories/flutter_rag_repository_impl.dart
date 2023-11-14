import 'package:flutter_neon_rags/features/flutter_rag/data/datasources/flutter_rag_remote_datasources.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/repositories/flutter_rag_repository.dart';

class FlutterRagRepositoryImpl extends FlutterRagRepository {
  late FlutterRagRemoteDataSource flutterRagRemoteDataSource;

  FlutterRagRepositoryImpl({required this.flutterRagRemoteDataSource});

  @override
  Future<void> createNeonTable(String tableName, String extName) async {
    await flutterRagRemoteDataSource.createNeonTable(
      extName: extName,
      tableName: tableName,
    );
  }

  @override
  Future<void> updateNeonTable(
      String tableName, List<List<dynamic>> csvData) async {
    await flutterRagRemoteDataSource.updateNeoNTable(
        tableName: tableName, csvData: csvData);
  }

  @override
  Future<String> queryNeonTable(String query, String tableName) async {
    final querriedResponse = await flutterRagRemoteDataSource.queryNeonTable(
        tableName: tableName, query: query);
    return querriedResponse;
  }
}
