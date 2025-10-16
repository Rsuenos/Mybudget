import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_model.dart';

class TransactionState {
  final List<TransactionModel> items;
  final bool loading;
  TransactionState({required this.items, required this.loading});
  TransactionState copyWith({List<TransactionModel>? items, bool? loading}) =>
      TransactionState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
      );
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(TransactionState(items: [], loading: false));

  Future<void> load({int limit = 50, int offset = 0}) async {
    state = state.copyWith(loading: true);
    // TODO: call repository
    await Future.delayed(Duration(milliseconds: 200));
    state = state.copyWith(loading: false);
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionState>(
      (ref) => TransactionNotifier(),
    );
