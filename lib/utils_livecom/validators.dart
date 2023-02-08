isEmpty(String s) {
  return s == null || s.isEmpty || "null" == s;
}

isNotEmpty(String s) {
  return s != null && s.isNotEmpty && s != "null";
}

// Verifica se cada String da lista nao está vazia
isNotEmptyStringList(List<String> list) {
  if (list == null) {
    return false;
  }
  for (String s in list) {
    if (isEmpty(s)) {
      return false;
    }
  }
  return true;
}

// Verifica se cada String da lista nao está vazia
isNotEmptyList<T>(List<T> list) {
  if (list == null) {
    return false;
  }
  for (T s in list) {
    if (s == null) {
      return false;
    }
  }
  return true;
}

isEmptyList(List list) {
  return list == null || list.length == 0;
}

String validateRequired(String s, String msg) {
  return isEmpty(s) ? msg : null;
}

String validateEmail(String s) {
  return isEmpty(s) || !isValidEmail(s)
      ? "e-mail inválido,\nverifique se digitou corretamente"
      : null;
}

bool isValidEmail(String email) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = new RegExp(pattern);
  if (email.length == 0) {
    return false;
  }
  return regExp.hasMatch(email);
}

String validateCpf(String s) {
  return isEmpty(s) || !isValidCpf(s)
      ? "CPF inválido,\nverifique se digitou corretamente"
      : null;
}

String validateFone(String s) {
  return isEmpty(s) || !isValidFone(s)
      ? "telefone inválido,\nverifique se digitou corretamente"
      : null;
}

bool isValidFone(String fone) {
  String pattern = r'^\([1-9]{2}\) (?:[2-8]|9[1-9])[0-9]{3}[0-9]{4}$';
  RegExp regExp = new RegExp(pattern);
  if (fone.length == 0) {
    return false;
  }
  return regExp.hasMatch(fone);
}

bool isValidCpf(String cpf) {
  List<int> listCpf = cpf
      .replaceAll(new RegExp(r'\.|-'), '')
      .split('')
      .map((String digit) => int.parse(digit))
      .toList();

  if (listCpf.length != 11) {
    return false;
  }

  var d1 = _gerarDigitoVerificador(listCpf.sublist(0, 9));

  if (d1 != listCpf[9]) {
    return false;
  }

  var d2 = _gerarDigitoVerificador(listCpf.sublist(0, 10));

  if (d2 != listCpf[10]) {
    return false;
  }

  return true;
}

int _gerarDigitoVerificador(List<int> digits) {
  int baseNumber = 0;
  for (var i = 0; i < digits.length; i++) {
    baseNumber += digits[i] * ((digits.length + 1) - i);
  }
  int verificationDigit = baseNumber * 10 % 11;
  return verificationDigit >= 10 ? 0 : verificationDigit;
}

bool validateConfirmarSenha(password, confirmPassword) {
  return password == confirmPassword ? true : false;
}

String validateSenhas(String senha1, String senha2) {
  if (isEmpty(senha1) || isEmpty(senha2)) {
    return "Informe a senha";
  }
  if (senha1.length < 4 || senha2.length < 4) {
    return "deve possuir pelo menos 4 caracteres";
  }
  if (senha1 != senha2) {
    return "as senhas devem ser iguais";
  }
  return null;
}
