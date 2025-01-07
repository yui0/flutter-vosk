import 'package:flutter_riverpod/flutter_riverpod.dart';

// モデル（状態クラス）
class CounterState {
  final int count;
  CounterState(this.count);
}

// 状態管理クラス
class CounterNotifier extends StateNotifier<CounterState> {
  CounterNotifier() : super(CounterState(0));

  void increment() => state = CounterState(state.count + 1);
  void decrement() => state = CounterState(state.count - 1);
}

// Provider定義
final counterProvider = StateNotifierProvider<CounterNotifier, CounterState>(
  (ref) => CounterNotifier(),
);

