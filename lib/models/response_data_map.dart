class ResponseDataMap<Map> {
  bool status;
  String message;
  Map? data;

  ResponseDataMap({
    required this.status,
    required this.message,
    this.data,
  });
}
