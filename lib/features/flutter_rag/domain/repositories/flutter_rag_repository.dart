abstract class FlutterRagRepository {
  Future<void> createNeonTable(String tableName, String extName);
  Future<void> updateNeonTable(String tableName, List<List<dynamic>> csvData);
  Future<String> queryNeonTable(String query, String tableName);
}
