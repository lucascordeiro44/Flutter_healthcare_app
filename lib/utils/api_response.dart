class ApiResponse<T> {
  bool status;
  String msg;
  dynamic error;

  T result;

//  ApiResponse(this.status, {this.msg, this.result});

  bool get ok => status;

  ApiResponse.ok({this.result, this.msg}) {
    this.status = true;
  }

  ApiResponse.error(this.msg) {
    this.status = false;
  }

  ApiResponse.errorDynamic(this.error) {
    this.status = false;
  }

  @override
  String toString() {
    return 'ApiResponse {ok: $status, msg: $msg, result: $result}';
  }
}
