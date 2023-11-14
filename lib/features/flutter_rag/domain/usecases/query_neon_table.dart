import 'package:flutter_neon_rags/features/flutter_rag/domain/repositories/flutter_rag_repository.dart';

class QueryNeonTable {
  FlutterRagRepository flutterRagRepository;
  QueryNeonTable(this.flutterRagRepository);
  Future<String> execute({required String tableName, required String query}) {
    return flutterRagRepository.queryNeonTable(query, tableName);
  }
}
