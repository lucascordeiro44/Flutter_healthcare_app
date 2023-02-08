class AlertaPreco {
  double preco;
  String alerta;
  String data;

  AlertaPreco(this.preco, this.alerta, this.data);

  @override
  String toString() {
    return 'AlertaPreco{preco: $preco, alerta: $alerta, data: $data}';
  }


}
