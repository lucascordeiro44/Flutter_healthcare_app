extension Extension on Object {
  bool isNullOrEmpty() {
    if (this is List) {
      return this == null || (this as List).length == 0;
    }
    return this == null || this == '';
  }

  bool isNullEmptyOrFalse() => this == null || this == '' || !this;

  bool isNullEmptyZeroOrFalse() =>
      this == null || this == '' || !this || this == 0;
}
