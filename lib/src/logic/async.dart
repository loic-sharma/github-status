sealed class AsyncValue<T> {
  const AsyncValue();
}

class LoadingValue<T> extends AsyncValue<T> {
  const LoadingValue();
}

class DataValue<T> extends AsyncValue<T> {
  const DataValue({required this.value});

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

