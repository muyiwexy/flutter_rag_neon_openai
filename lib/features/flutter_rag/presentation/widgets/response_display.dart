part of '../views/base_home_view.dart';

class QueryResponseDisplay extends StatelessWidget {
  const QueryResponseDisplay({
    super.key,
    required this.appNotifier,
  });

  final AppNotifier appNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QueryState>(
      valueListenable: appNotifier.queryState,
      builder: (BuildContext context, value, Widget? child) {
        if (value.state == QueryEnum.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (value.state == QueryEnum.error) {
          return const Center(
            child: Text("Sorry, an Error occured"),
          );
        } else if (value.state == QueryEnum.loaded) {
          return Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  value.result,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
