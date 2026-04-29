class ResponseDataMap {
  bool status;
  String? message;
  dynamic data;

  ResponseDataMap({
    required this.status,
    this.message,
    this.data,
  });
}