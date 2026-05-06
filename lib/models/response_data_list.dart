class ResponseDataList<T> {
  bool status;
  String? message;
  List<T>? data;

  ResponseDataList({
    required this.status,
    this.message,
    this.data,
  });
}