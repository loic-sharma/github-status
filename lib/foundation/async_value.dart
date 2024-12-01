import 'package:flutter/foundation.dart';

sealed class AsyncValue<T> {
  const AsyncValue();

  factory AsyncValue.loading() = LoadingValue;
  factory AsyncValue.data(T value) = DataValue;
  factory AsyncValue.error({required Object error, required StackTrace stackTrace}) = ErrorValue;
}

class LoadingValue<T> extends AsyncValue<T> {
  const LoadingValue();
}

class DataValue<T> extends AsyncValue<T> {
  const DataValue(this.value);

  final T value;
}

class ErrorValue<T> extends AsyncValue<T> {
  const ErrorValue({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;
}

typedef AsyncValueNotifier<T> = ValueNotifier<AsyncValue<T>>;
typedef AsyncValueListenable<T> = ValueListenable<AsyncValue<T>>;
