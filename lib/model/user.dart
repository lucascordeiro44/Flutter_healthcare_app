import 'dart:convert';
import 'package:flutter_dandelin/model/address.dart';
import 'package:flutter_dandelin/model/dependente.dart';
import 'package:flutter_dandelin/model/ocupation.dart';
import 'package:flutter_dandelin/model/role.dart';
import 'package:flutter_dandelin/utils/datetime_helper.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/utils/prefs.dart';

class User {
  int id;
  String firstName;
  String lastName;
  String customerAt;
  String phone = "";
  String mobilePhone = "";

  String ddiMobilePhone;
  String gender;
  Ocupation ocupation;
  List<Address> address;
  String username;
  String password;
  String document;
  String birthday;
  String avatar;
  //usado só na hora para validar o siepe
  String cpfMasked;
  Partnership partnership;

  Parent parent;
  bool underAge;
  bool agreeUnderAge;
  int parentId;
  bool notificationToParent;
  bool approval;

  String statusDependent;
  Company company;

  List<Dependente> dependents;
  Role role;
  String token;
  String fullName;
  String status;
  String firebaseId;
  //sistema op
  String so;
  bool twoFactorAuthentication;
  bool telefoneValido;
  String tokenSocialLogin;
  int livecomId;

  CameFrom cameFrom;

  //social login
  String uid;
  String tokenId;

  bool get isMale => this.gender != null && this.gender == "male";

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.customerAt,
    this.phone,
    this.mobilePhone,
    this.gender,
    this.ocupation,
    this.address,
    this.username,
    this.password,
    this.document,
    this.birthday,
    this.avatar,
    this.role,
    this.fullName,
    this.firebaseId,
    this.status,
    this.approval,
    this.twoFactorAuthentication,
    this.livecomId,
    this.cameFrom,
  });

  // Cache para o authorization
  static String authorization;
  String get telefone => isNotEmpty(phone) ? phone : mobilePhone;

  String get ddi {
    String v = telefone != null && isNotEmpty(telefone)
        ? this.telefone.substring(0, 3)
        : "";

    return v.contains("+") ? v : "+55";
  }

  String get tel => telefone != null && isNotEmpty(telefone)
      ? this.telefone.substring(3, this.telefone.length)
      : "";

  bool get isPagamentoAtivoOuPreAtivo =>
      this.status == "ATIVO" || this.status == "PRE_ATIVO" || this.status == "CUPOM_DESCONTO";

  bool get isPreAtivo => this.status == "PRE_ATIVO";
  bool get isAtivo => this.status == "ATIVO";

  bool get isDependente => this.parent != null;
  bool get dependenteRemovido => this.statusDependent == "DEPENDENT_REMOVED" ;

  bool get hasCompany => this.company != null;

  String get cidadeEsado {
    Address ads = this.address?.first;

    if (ads == null) {
      return null;
    }

    return "${ads.city}, ${ads.state}";
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    customerAt = json['customerAt'];
    phone = json['phone'];
    mobilePhone = json['mobilePhone'];
    ddiMobilePhone = json['ddiMobilePhone'];
    gender = json['gender'];
    ocupation = json['ocupation'] != null
        ? new Ocupation.fromJson(json['ocupation'])
        : null;
    if (json['address'] != null) {
      address = new List<Address>();
      json['address'].forEach((v) {
        address.add(new Address.fromJson(v));
      });
    }
    username = json['username'];
    password = json['password'];
    document = json['document'];
    birthday = json['birthday'];
    avatar = json['avatar'];
    role = json['role'] != null ? new Role.fromJson(json['role']) : null;
    token = json['token'];
    fullName = json['fullName'];
    firebaseId = json['firebaseId'];
    status = json['status'];
    partnership = json['partnership'] != null
        ? new Partnership.fromJson(json['partnership'])
        : null;
    if (json['dependents'] != null) {
      dependents = new List<Dependente>();
      json['dependents'].forEach((v) {
        dependents.add(new Dependente.fromJson(v));
      });
    }
    underAge = json['underAge'];
    approval = json['approval'];
    parent =
        json['parent'] != null ? new Parent.fromJson(json['parent']) : null;
    statusDependent = json['statusDependent'];
    so = json['so'];
    company =
        json['company'] != null ? new Company.fromJson(json['company']) : null;

    twoFactorAuthentication = json['twoFactorAuthentication'];
    cameFrom = json['cameFrom'] != null
        ? new CameFrom.fromJson(json['cameFrom'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['customerAt'] = this.customerAt;
    if (this.phone != null) {
      data['phone'] = this.phone;
    }
    if (this.tokenSocialLogin != null) {
      data['tokenSocialLogin'] = this.tokenSocialLogin;
    }
    if (this.mobilePhone != null) {
      data['mobilePhone'] = this.mobilePhone;
    }
    data['ddiMobilePhone'] = this.ddiMobilePhone;
    data['gender'] = this.gender;
    if (this.ocupation != null) {
      data['ocupation'] = this.ocupation.toJson();
    }
    if (this.address != null) {
      data['address'] = this.address.map((v) => v.toJson()).toList();
    }

    data['username'] = this.username;

    if (this.password != null) {
      data['password'] = this.password;
    }
    data['document'] = this.document;
    data['birthday'] = this.birthday;
    data['avatar'] = this.avatar;
    if (this.role != null) {
      data['role'] = this.role.toJson();
    }
    data['token'] = this.token;
    data['firebaseId'] = this.firebaseId;
    data['status'] = this.status;
    if (this.partnership != null) {
      data['partnership'] = this.partnership.toJson();
    }
    if (this.dependents != null) {
      data['dependents'] = this.dependents.map((v) => v.toJson()).toList();
    }

    data['underAge'] = this.underAge;

    if (this.parentId != null) {
      data["parent"] = {
        'id': this.parentId,
      };
    }

    data['notificationToParent'] = this.notificationToParent;
    data['approval'] = this.approval;
    data['so'] = this.so;
    if (this.company != null) {
      data['company'] = this.company.toJson();
    }

    data['twoFactorAuthentication'] = this.twoFactorAuthentication;

    if (this.cameFrom != null) {
      data['cameFrom'] = this.cameFrom.toJson();
    }

    return data;
  }

  Map<String, dynamic> toGA() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['gender'] = this.gender;
    data['username'] = this.username;
    data['document'] = this.document;
    data['birthday'] = this.birthday;

    return data;
  }

  get getUserFullName => fullName == null
      ? "${this.firstName ?? ""} ${this.lastName ?? ""}"
      : fullName;

  save() {
    final s = json.encode(toJson());
    Prefs.setString("user.prefs", s);
  }

  static clear() async {
    clearAuthorization();
    Prefs.setBool('remember.user', false);
    Prefs.setString("user.prefs", "");
  }

  static Future clearAuthorization() async {
    authorization = null;
    var s = await Prefs.getString("user.prefs");
    final map = json.decode(s) as Map<String, dynamic>;
    final user = User.fromJson(map);
    user.token = null;
    s = json.encode(user.toJson());
    await Prefs.setString("user.prefs", s);
  }

  static Future<User> get() async {
    final s = await Prefs.getString("user.prefs");
    if (s == null || s.isEmpty) {
      return null;
    }
    final map = json.decode(s) as Map<String, dynamic>;
    final user = User.fromJson(map);
    return user;
  }

  static Future<String> getToken({String currentToken}) async {
    if (authorization != null && authorization == currentToken) {
      return authorization;
    }

    User u = await User.get();
    if (u != null) {
      authorization = u.token;
    }
    return authorization;
  }

  String dataCleanUser() {
    var array = this.birthday.split('-');

    String year = array[2];
    int month = int.parse(array[1]);
    int day = int.parse(array[0]);

    return "$year${addZeroDate(month)}${addZeroDate(day)}";
  }

  @override
  String toString() {
    return 'User{id: $id, nome: $firstName, sobrenome: $lastName, telefone: $mobilePhone, cpf: $document, email: $username, genero: $gender}';
  }
}

class Parent {
  int id;
  String name;
  String status;

  Parent({this.id, this.name, this.status});

  Parent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }
}

class Company {
  int id;
  String cnpj;
  String name;

  Company({this.id, this.cnpj, this.name});

  Company.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    cnpj = json['cnpj'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['cnpj'] = this.cnpj;
    data['name'] = this.name;
    return data;
  }
}

class CameFrom {
  String channel;
  String description;

  CameFrom({
    this.channel,
    this.description,
  });

  CameFrom.fromJson(Map<String, dynamic> json) {
    channel = json['channel'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['channel'] = this.channel;
    data['description'] = this.description;
    return data;
  }
}
