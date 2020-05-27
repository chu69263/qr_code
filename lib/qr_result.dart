class QrResult {
  String text;
  int code;

  QrResult({this.text, this.code});

  factory QrResult.fromJson(Map map) {
    return QrResult(
      code: map['code'],
      text: map['text'],
    );
  }
}
