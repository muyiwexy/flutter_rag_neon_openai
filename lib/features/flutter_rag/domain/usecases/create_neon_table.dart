import 'package:flutter_neon_rags/features/flutter_rag/domain/repositories/flutter_rag_repository.dart';

class CreateNeonTable {
  late FlutterRagRepository flutterRagRepository;

  CreateNeonTable(this.flutterRagRepository);
  Future<void> execute(
      {required String tableName, required String extName}) async {
    return await flutterRagRepository.createNeonTable(tableName, extName);
  }
}
