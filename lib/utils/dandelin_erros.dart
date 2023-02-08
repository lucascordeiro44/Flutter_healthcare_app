class DandelinError {
  String msg;
  DandelinErrosEnum code;

  DandelinError.create(String msg, String error) {
    this.msg = msg;
    switch (error) {
      case "NO_PAYMENT_METHOD":
        this.code = DandelinErrosEnum.no_payment_method;
        break;
      default:
    }
  }
}

enum DandelinErrosEnum {
  no_payment_method,
}
