class InvalidJsonException implements Exception {
  final String message;
  InvalidJsonException(this.message);

  @override
  String toString() {
    return message;
  }
}
