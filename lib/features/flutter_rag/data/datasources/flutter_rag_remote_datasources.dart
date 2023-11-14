import 'package:flutter_neon_rags/core/helpers/helper_functions.dart';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';

abstract class FlutterRagRemoteDataSource {
  Future<void> createNeonTable({
    required String extName,
    required String tableName,
  });
  Future<void> updateNeoNTable(
      {required String tableName, required List<List<dynamic>> csvData});
  Future<String> queryNeonTable(
      {required String tableName, required String query});
}

class FlutterRagRemoteDataSourceImpl extends FlutterRagRemoteDataSource {
  late final http.Client client;
  late PostgreSQLConnection connection;
  FlutterRagRemoteDataSourceImpl(
      {required this.client, required this.connection});

  @override
  Future<void> createNeonTable(
      {required String extName, required String tableName}) async {
    final extensions = await connection.query(
        "SELECT EXISTS (SELECT FROM pg_extension WHERE extname = '$extName');");
    try {
      if (!extensions[0][0]) {
        print("Createing $extName...");
        await connection.query("CREATE EXTENSION $extName;");
        final tables = await connection.query(
            "SELECT EXISTS (SELECT FROM information_schema.tables WHERE  table_schema = 'public' AND    table_name   = '$tableName');");
        try {
          if (!tables[0][0]) {
            print("Creating $tableName ...");
            await connection.query(
                "CREATE TABLE $tableName (id bigserial primary key, title text, url text, content text, tokens integer, embedding vector(1536));");
          } else {
            print("$tableName already exists");
          }
          print("done...");
        } catch (e) {
          print(e);
        }
        print("done...");
      } else {
        print("$extName already exists");
      }
      print("Exit ... ");
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> updateNeoNTable(
      {required String tableName, required List<List<dynamic>> csvData}) async {
    try {
      print("retrieving Neon table...");
      final table = await connection.query(
          "SELECT * FROM pg_catalog.pg_tables WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';");
      print("Neon table retrieved: ${table[0]}");

      List<List<dynamic>> newList = [];
      for (int i = 1; i < csvData.length; i++) {
        String content = csvData[i][1];
        int tokenLen = await numTokensFromString(content);
        if (tokenLen <= 512) {
          newList.add([csvData[i][0], content, csvData[i][2], tokenLen]);
        } else {
          int start = 0;
          int idealTokenSize = 512;
          int idealSize = (idealTokenSize ~/ (4 / 3)).toInt();
          int end = idealSize;
          List<String> words = content.split(" ");
          words = words.where((word) => word != " ").toList();
          int totalWords = words.length;
          int chunks = totalWords ~/ idealSize;

          if (totalWords % idealSize != 0) {
            chunks += 1;
          }

          List<String> newContent = [];
          for (int j = 0; j < chunks; j++) {
            if (end > totalWords) {
              end = totalWords;
            }

            newContent = words.sublist(start, end);

            String newContentString = newContent.join(" ");
            int newContentTokenLen =
                await numTokensFromString(newContentString);
            if (newContentTokenLen > 0) {
              newList.add([
                csvData[i][0],
                newContentString,
                csvData[i][2],
                newContentTokenLen
              ]);
            }

            start += idealSize;
            end += idealSize;
          }
        }
      }
      for (int i = 0; i < newList.length; i++) {
        try {
          String text = newList[i][1];
          final embedding = await getEmbeddings(text);
          newList[i].add(embedding);
        } catch (e) {
          print('Error occurred for index $i: $e');
        }
      }

      await connection.transaction((ctx) async {
        for (var row in newList) {
          await ctx.query(
            'INSERT INTO $tableName (title, url, content, tokens, embedding) VALUES (@title, @url, @content, @tokens, @embedding)',
            substitutionValues: {
              'title': row[0],
              'content': row[1],
              'url': row[2],
              'tokens': row[3],
              'embedding': '${row[4]}',
            },
          );
        }
      });
      // var result =
      //     await connection.query('SELECT COUNT(*) as cnt FROM $tableName;');

      // var sanityCheck =
      //     await connection.query('SELECT * FROM $tableName LIMIT 1');
      // final fetchOne = sanityCheck[0][0];
      // // int? numrecord;
      // // for (var element in sanityCheck) {
      // //   numrecord = element[0].length;
      // // }
      // print(fetchOne);
      // print("this is the result: ${result[0]}");
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<String> queryNeonTable(
      {required String tableName, required String query}) async {
    print("Started ...");
    String delimiter = "```";
    final queryEmbedding = await getEmbeddings(query);
    final getSimilar = await connection.query(
        "SELECT * FROM $tableName ORDER BY embedding <=> '$queryEmbedding' LIMIT 3");
    String systemMessage = """
      You are a friendly chatbot. \n
      You can answer questions about 	Implementing OAuth2 Clients with Flutter and Appwrite. \n
      You respond in a concise, technically credible tone. \n
      """;

    List<Map<String, String>> messages = [
      {"role": "system", "content": systemMessage},
      {"role": "user", "content": "$delimiter$query$delimiter"},
      {
        "role": "assistant",
        "content":
            "Relevant Appwrite OAuth2 case studies \n ${getSimilar[0][3]} \n ${getSimilar[1][3]} \n ${getSimilar[2][3]}"
      }
    ];

    final finalResponse = await getCompletionFromMessages(messages);
    return finalResponse;
  }
}
