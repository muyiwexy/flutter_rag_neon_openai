import 'package:flutter_neon_rags/features/flutter_rag/domain/repositories/flutter_rag_repository.dart';

class UpdateNeonTable {
  FlutterRagRepository flutterRagRepository;
  UpdateNeonTable(this.flutterRagRepository);
  Future<void> execute(
      {required String tableName, required List<List<dynamic>> csvData}) {
    return flutterRagRepository.updateNeonTable(tableName, csvData);
  }
}
