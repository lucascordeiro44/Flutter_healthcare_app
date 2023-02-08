import 'package:flutter_dandelin/model/expertise.dart';

class Cv {
  String name = "";
  List<Councils> councils = <Councils>[];
  int ratingDoctor = 1;
  List<Focus> focus = <Focus>[];
  List<DiseaseTreatment> diseaseTreatments = <DiseaseTreatment>[];
  List<Expertise> expertises = <Expertise>[];
  List<SubExpertise> subExpertises = <SubExpertise>[];
  List<Target> targets = <Target>[];
  bool accessibility = false;
  List<Language> languages = <Language>[];
  String resume = "";
  List<Topic> topics = <Topic>[];
  List<Universitie> universities = <Universitie>[];

  String crms() {
    String crm = "";

    if (councils == null) {
      return crm;
    }
    councils.forEach((element) {
      crm += "${element.council} ${element.numberCouncil} ";
    });

    return crm;
  }

  String targs() {
    String targ = "";

    int length = targets.length;

    if (length == 1) {
      return targets.first.type;
    }

    targets.asMap().forEach((i, value) {
      if (i == 0) {
        targ = value.type;
      } else {
        targ += i == (length - 1) ? " e ${value.type}" : ", ${value.type}";
      }
    });

    return targ;
  }

  String langs() {
    String lang = "";

    int length = languages.length;

    if (length == 1) {
      return languages.first.name;
    }

    languages.asMap().forEach((i, value) {
      if (i == 0) {
        lang = value.name;
      } else {
        lang += i == (length - 1) ? " e ${value.name}" : ", ${value.name}";
      }
    });

    return lang;
  }

  Cv({
    this.name,
    this.councils,
    this.ratingDoctor,
    this.focus,
    this.diseaseTreatments,
    this.expertises,
    this.subExpertises,
    this.targets,
    this.accessibility,
    this.languages,
    this.resume,
    this.topics,
    this.universities,
  });

  Cv.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['councils'] != null) {
      councils = new List<Councils>();
      json['councils'].forEach((v) {
        councils.add(new Councils.fromJson(v));
      });
    }
    if(json['ratingDoctor'] != null){
      ratingDoctor = json['ratingDoctor'];
    }
    if (json['focus'] != null) {
      focus = new List<Focus>();
      json['focus'].forEach((v) {
        focus.add(new Focus.fromJson(v));
      });
    }
    if (json['diseaseTreatments'] != null) {
      diseaseTreatments = new List<DiseaseTreatment>();
      json['diseaseTreatments'].forEach((v) {
        diseaseTreatments.add(new DiseaseTreatment.fromJson(v));
      });
    }
    if (json['expertises'] != null) {
      expertises = new List<Expertise>();
      json['expertises'].forEach((v) {
        expertises.add(new Expertise.fromJson(v));
      });
    }
    if (json['subExpertises'] != null) {
      subExpertises = new List<SubExpertise>();
      json['subExpertises'].forEach((v) {
        subExpertises.add(new SubExpertise.fromJson(v));
      });
    }
    if (json['targets'] != null) {
      targets = new List<Target>();
      json['targets'].forEach((v) {
        targets.add(new Target.fromJson(v));
      });
    }
    accessibility = json['accessibility'];
    if (json['languages'] != null) {
      languages = new List<Language>();
      json['languages'].forEach((v) {
        languages.add(new Language.fromJson(v));
      });
    }

    if(json['resume'] != null){
      resume = json['resume'];
    }
    if (json['topics'] != null) {
      topics = new List<Topic>();
      json['topics'].forEach((v) {
        topics.add(new Topic.fromJson(v));
      });
    }
    if (json['universities'] != null) {
      universities = new List<Universitie>();
      json['universities'].forEach((v) {
        universities.add(new Universitie.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    if (this.councils != null) {
      data['councils'] = this.councils.map((v) => v.toJson()).toList();
    }
    data['ratingDoctor'] = this.ratingDoctor;
    if (this.focus != null) {
      data['focus'] = this.focus.map((v) => v.toJson()).toList();
    }
    if (this.diseaseTreatments != null) {
      data['diseaseTreatments'] =
          this.diseaseTreatments.map((v) => v.toJson()).toList();
    }
    if (this.expertises != null) {
      data['expertises'] = this.expertises.map((v) => v.toJson()).toList();
    }
    if (this.subExpertises != null) {
      data['subExpertises'] =
          this.subExpertises.map((v) => v.toJson()).toList();
    }
    if (this.targets != null) {
      data['targets'] = this.targets.map((v) => v.toJson()).toList();
    }
    data['accessibility'] = this.accessibility;
    if (this.languages != null) {
      data['languages'] = this.languages.map((v) => v.toJson()).toList();
    }
    data['resume'] = this.resume;
    if (this.topics != null) {
      data['topics'] = this.topics.map((v) => v.toJson()).toList();
    }
    if (this.universities != null) {
      data['universities'] = this.universities.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Councils {
  int id;
  String council;
  String numberCouncil;
  String councilDistrict;

  Councils({this.id, this.council, this.numberCouncil, this.councilDistrict});

  Councils.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    council = json['council'];
    numberCouncil = json['numberCouncil'];
    councilDistrict = json['councilDistrict'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['council'] = this.council;
    data['numberCouncil'] = this.numberCouncil;
    data['councilDistrict'] = this.councilDistrict;
    return data;
  }
}

class Focus {
  int id;
  String name;

  Focus({this.id, this.name});

  Focus.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class SubExpertise {
  int id;
  String customerAt;
  String name;
  String slug;
  Expertise expertise;

  SubExpertise(
      {this.id, this.customerAt, this.name, this.slug, this.expertise});

  SubExpertise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerAt = json['customerAt'];
    name = json['name'];
    slug = json['slug'];
    expertise = json['expertise'] != null
        ? new Expertise.fromJson(json['expertise'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerAt'] = this.customerAt;
    data['name'] = this.name;
    data['slug'] = this.slug;
    if (this.expertise != null) {
      data['expertise'] = this.expertise.toJson();
    }
    return data;
  }
}

class Target {
  int id;
  String type;
  String customerAt;

  Target({this.id, this.type, this.customerAt});

  Target.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    customerAt = json['customerAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['customerAt'] = this.customerAt;
    return data;
  }
}

class Language {
  int id;
  String name;
  String customerAt;

  Language({this.id, this.name, this.customerAt});

  Language.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    customerAt = json['customerAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['customerAt'] = this.customerAt;
    return data;
  }
}

class Topic {
  int id;
  String customerAt;
  String title;
  String subTitle;
  String local;
  int start;
  int end;

  String get titleApp => "$title - $local ($start - $end)";

  Topic(
      {this.id,
      this.customerAt,
      this.title,
      this.subTitle,
      this.local,
      this.start,
      this.end});

  Topic.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerAt = json['customerAt'];
    title = json['title'];
    subTitle = json['subTitle'];
    local = json['local'];
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerAt'] = this.customerAt;
    data['title'] = this.title;
    data['subTitle'] = this.subTitle;
    data['local'] = this.local;
    data['start'] = this.start;
    data['end'] = this.end;
    return data;
  }
}

class Universitie {
  int id;
  String customerAt = "";
  String name = "";
  String course = "";
  int start;
  int end;

  String get titleApp =>  name != "" ? "$course ($start - $end)" : "";

  Universitie(
      {this.id, this.customerAt, this.name, this.course, this.start, this.end});

  Universitie.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if(json['customerAt'] != null) {
      customerAt = json['customerAt'];
    }
    if(json['name'] != null){
      name = json['name'];
    }
    if(json['course'] != null){
      course = json['course'];
    }
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customerAt'] = this.customerAt;
    data['name'] = this.name;
    data['course'] = this.course;
    data['start'] = this.start;
    data['end'] = this.end;
    return data;
  }
}

class DiseaseTreatment {
  int id;
  String name;

  DiseaseTreatment({this.id, this.name});

  DiseaseTreatment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
