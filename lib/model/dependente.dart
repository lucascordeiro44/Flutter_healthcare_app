class Dependente {
  int id;
  String createdAt;
  String updatedAt;
  String dependentName;
  String parentName;
  bool approved;
  bool underAge;
  String document;
  String avatar;
  String username;
  String birthday;
  String approvalMessage;
  String deletedAt;

  Dependente({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.dependentName,
    this.parentName,
    this.approved,
    this.underAge,
    this.document,
    this.avatar,
    this.username,
    this.birthday,
    this.approvalMessage,
    this.deletedAt,
  });

  bool get isDeletado => this.deletedAt != null;
  bool get renviarConviteEnable =>
      this.approved != null &&
      !this.approved &&
      this.deletedAt != null &&
      this.deletedAt.isNotEmpty;

  Dependente.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    dependentName = json['dependentName'];
    parentName = json['parentName'];
    approved = json['approved'];
    underAge = json['underAge'];
    document = json['document'];
    avatar = json['avatar'];
    username = json['username'];
    birthday = json['birthday'];
    approvalMessage = json['approvalMessage'];
    deletedAt = json['deletedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['dependentName'] = this.dependentName;
    data['parentName'] = this.parentName;
    data['approved'] = this.approved;
    data['underAge'] = this.underAge;
    data['document'] = this.document;
    data['avatar'] = this.avatar;
    data['username'] = this.username;
    data['birthday'] = this.birthday;
    return data;
  }
}
