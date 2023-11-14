import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tiktoken/tiktoken.dart';
import 'package:http/http.dart' as http;

Future<int> numTokensFromString(String str,
    {String encodingName = "cl100k_base"}) async {
  if (str.isEmpty) {
    return 0;
  }

  final encoding = getEncoding(encodingName);
  final numTokens = encoding.encode(str).length;
  return numTokens;
}

Future<List<List<dynamic>>> getCSV() async {
  final rawcsvFile = await rootBundle.loadString("assets/mydata.csv");
  final csvData =
      const CsvToListConverter().convert(rawcsvFile.splitMapJoin("/n"));
  return csvData;
}

Future<List<dynamic>> getEmbeddings(String text) async {
  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/embeddings"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']!}',
    },
    body: jsonEncode({
      'model': 'text-embedding-ada-002',
      'input': text,
    }),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    List<dynamic> embedding = responseData['data'][0]['embedding'];
    return embedding;
  } else {
    throw response.body;
  }
}

Future<String> getCompletionFromMessages(messages,
    {model = "gpt-3.5-turbo-0613", temperature = 0, maxtokens = 1000}) async {
  final response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']!}',
    },
    body: jsonEncode({
      'model': model,
      'messages': messages,
      'max_tokens': maxtokens,
    }),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    String content = responseData['choices'][0]['message']['content'];
    return content;
  } else {
    throw response.body;
  }
}
