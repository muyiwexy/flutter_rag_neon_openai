import 'package:flutter/material.dart';
import 'package:flutter_neon_rags/features/flutter_rag/data/models/querymodel.dart';
import 'package:flutter_neon_rags/features/flutter_rag/presentation/notifiers/app_notifier.dart';
import 'package:provider/provider.dart';
part '../widgets/response_display.dart';

class BaseHomeView extends StatelessWidget {
  const BaseHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final queryController = TextEditingController();
    final appNotifier = Provider.of<AppNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Ask a question"),
              TextField(
                controller: queryController,
                decoration: const InputDecoration(hintText: "Enter a query"),
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.topRight,
                child: ValueListenableBuilder<QueryState>(
                  valueListenable: appNotifier.queryState,
                  builder: (BuildContext context, value, Widget? child) {
                    return SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: value.state == QueryEnum.loading
                            ? null
                            : () {
                                appNotifier
                                    .queryNeonVectorTable(queryController.text);
                                queryController.clear();
                              },
                        child: const Text("Ask"),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              ValueListenableBuilder<IndexEnum>(
                valueListenable: appNotifier.apiState,
                builder: (BuildContext context, value, Widget? child) {
                  return SizedBox(
                    width: 150,
                    child: OutlinedButton(
                      onPressed: value == IndexEnum.loading
                          ? null
                          : () {
                              appNotifier.createNeonVectorTable();
                            },
                      child: value == IndexEnum.loading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                              ),
                            )
                          : value == IndexEnum.error
                              ? const Row(children: [
                                  Text("Upload CSV"),
                                  Icon(Icons.error_outline)
                                ])
                              : value == IndexEnum.loaded
                                  ? const Row(
                                      children: [
                                        Text("Upload CSV"),
                                        Icon(Icons.check)
                                      ],
                                    )
                                  : const Text("Upload CSV"),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              QueryResponseDisplay(appNotifier: appNotifier),
            ],
          ),
        ),
      ),
    );
  }
}
