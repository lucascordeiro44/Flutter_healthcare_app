String cleanTelefone(String telefone) {
  return telefone
      .replaceAll('(', '')
      .replaceAll(')', '')
      .replaceAll(' ', '')
      .replaceAll('-', '');
}

String cleanCpf(String cpf) {
  return cpf.replaceAll('.', '').replaceAll('-', '');
}

String cleanCep(String cep) {
  return cep.replaceAll('-', '');
}
