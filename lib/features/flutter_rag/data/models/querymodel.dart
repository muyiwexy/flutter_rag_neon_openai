import '../../presentation/notifiers/app_notifier.dart';

class QueryState {
  final String result;
  final QueryEnum state;

  QueryState({
    required this.result,
    required this.state,
  });

  QueryState copyWith({
    String? result,
    QueryEnum? state,
  }) {
    return QueryState(
      result: result ?? this.result,
      state: state ?? this.state,
    );
  }
}
