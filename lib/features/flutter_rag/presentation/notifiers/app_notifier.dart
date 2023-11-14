import 'package:flutter/foundation.dart';
import 'package:flutter_neon_rags/core/config.dart';
import 'package:flutter_neon_rags/features/flutter_rag/data/models/querymodel.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/usecases/create_neon_table.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/usecases/query_neon_table.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/usecases/update_neon_table.dart';
import 'package:postgres/postgres.dart';

import '../../../../core/helpers/helper_functions.dart';

enum IndexEnum { initial, loading, loaded, error }

enum QueryEnum { initial, loading, loaded, error }

class AppNotifier extends ChangeNotifier {
  late CreateNeonTable createNeonTable;
  late UpdateNeonTable updateNeonTable;
  late QueryNeonTable queryNeonTable;
  PostgreSQLConnection connection;
  AppNotifier({
    required this.connection,
    required this.createNeonTable,
    required this.updateNeonTable,
    required this.queryNeonTable,
  });

  final _queryState = ValueNotifier<QueryState>(
      QueryState(result: "", state: QueryEnum.initial));
  ValueNotifier<QueryState> get queryState => _queryState;
  final _apiState = ValueNotifier<IndexEnum>(IndexEnum.initial);
  ValueNotifier<IndexEnum> get apiState => _apiState;

  final _queryEnum = ValueNotifier(QueryEnum.initial);
  ValueNotifier<QueryEnum> get queryEnum => _queryEnum;

  initPostgresConnection() async {
    await connection.open().then((value) {
      if (kDebugMode) {
        print("Database Connected");
      }
    });
  }

  void createNeonVectorTable() async {
    try {
      _apiState.value = IndexEnum.loading;
      await createNeonTable.execute(
          tableName: ServiceConfig.tableName, extName: ServiceConfig.extName);
      final fetchCsv = await getCSV();
      await updateNeonTable.execute(
          tableName: "table_vector", csvData: fetchCsv);
      _apiState.value = IndexEnum.loaded;
    } catch (e) {
      _apiState.value = IndexEnum.error;
    }
  }

  void queryNeonVectorTable(String query) async {
    _queryState.value = QueryState(result: "", state: QueryEnum.loading);
    try {
      _queryEnum.value = QueryEnum.loading;
      final queryResponse = await queryNeonTable.execute(
          query: query, tableName: ServiceConfig.tableName);
      _queryState.value =
          QueryState(result: queryResponse, state: QueryEnum.loaded);
    } catch (e) {
      _queryState.value = QueryState(result: "", state: QueryEnum.error);
    }
  }
}
