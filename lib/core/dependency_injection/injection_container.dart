import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neon_rags/features/flutter_rag/data/datasources/flutter_rag_remote_datasources.dart';
import 'package:flutter_neon_rags/features/flutter_rag/data/repositories/flutter_rag_repository_impl.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/repositories/flutter_rag_repository.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/usecases/create_neon_table.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/usecases/query_neon_table.dart';
import 'package:flutter_neon_rags/features/flutter_rag/domain/usecases/update_neon_table.dart';
import 'package:flutter_neon_rags/features/flutter_rag/presentation/notifiers/app_notifier.dart';
import 'package:get_it/get_it.dart';
import 'package:postgres/postgres.dart';
import 'package:http/http.dart' as http;

final serviceLocator = GetIt.asNewInstance();

Future<void> init() async {
  //providers
  serviceLocator.registerFactory(
    () => AppNotifier(
      connection: serviceLocator(),
      createNeonTable: serviceLocator(),
      updateNeonTable: serviceLocator(),
      queryNeonTable: serviceLocator(),
    ),
  );
  //usecases

  serviceLocator.registerLazySingleton(
    () => CreateNeonTable(
      serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(
    () => UpdateNeonTable(
      serviceLocator(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => QueryNeonTable(
      serviceLocator(),
    ),
  );

  //repository
  serviceLocator.registerLazySingleton<FlutterRagRepository>(
    () =>
        FlutterRagRepositoryImpl(flutterRagRemoteDataSource: serviceLocator()),
  );

  //datasources
  serviceLocator.registerLazySingleton<FlutterRagRemoteDataSource>(
    () => FlutterRagRemoteDataSourceImpl(
      client: serviceLocator(),
      connection: serviceLocator(),
    ),
  );
  //! External

  final connection = PostgreSQLConnection(
    dotenv.env['PGHOST']!,
    5432,
    dotenv.env['PGDATABASE']!,
    username: dotenv.env['PGUSER']!,
    password: dotenv.env['PGPASSWORD']!,
    useSSL: true,
  );

  serviceLocator.registerLazySingleton(() => connection);
  serviceLocator.registerLazySingleton(() => http.Client());
}
