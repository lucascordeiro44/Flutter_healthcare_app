class Badges {
  int total;
  int posts;
  int likes;
  int favoritos;
  int comentarios;
  int likesComentario;
  int grupoParticipar;
  int grupoSair;
  int grupoSolicitarParticipar;
  int grupoUsuarioAdicionado;
  int grupoUsuarioAceito;
  int grupoUsuarioRemovido;
  int grupoUsuarioRecusado;
  int usuarioAmizadeSolicitada;
  int usuarioAmizadeDesfeita;
  int usuarioAmizadeAceita;
  int usuarioAmizadeRecusada;
  int mensagens;
  int reminders;

  Badges(
      {this.total,
        this.posts,
        this.likes,
        this.favoritos,
        this.comentarios,
        this.likesComentario,
        this.grupoParticipar,
        this.grupoSair,
        this.grupoSolicitarParticipar,
        this.grupoUsuarioAdicionado,
        this.grupoUsuarioAceito,
        this.grupoUsuarioRemovido,
        this.grupoUsuarioRecusado,
        this.usuarioAmizadeSolicitada,
        this.usuarioAmizadeDesfeita,
        this.usuarioAmizadeAceita,
        this.usuarioAmizadeRecusada,
        this.mensagens,
        this.reminders});

  Badges.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    posts = json['posts'];
    likes = json['likes'];
    favoritos = json['favoritos'];
    comentarios = json['comentarios'];
    likesComentario = json['likesComentario'];
    grupoParticipar = json['grupoParticipar'];
    grupoSair = json['grupoSair'];
    grupoSolicitarParticipar = json['grupoSolicitarParticipar'];
    grupoUsuarioAdicionado = json['grupoUsuarioAdicionado'];
    grupoUsuarioAceito = json['grupoUsuarioAceito'];
    grupoUsuarioRemovido = json['grupoUsuarioRemovido'];
    grupoUsuarioRecusado = json['grupoUsuarioRecusado'];
    usuarioAmizadeSolicitada = json['usuarioAmizadeSolicitada'];
    usuarioAmizadeDesfeita = json['usuarioAmizadeDesfeita'];
    usuarioAmizadeAceita = json['usuarioAmizadeAceita'];
    usuarioAmizadeRecusada = json['usuarioAmizadeRecusada'];
    mensagens = json['mensagens'];
    reminders = json['reminders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['posts'] = this.posts;
    data['likes'] = this.likes;
    data['favoritos'] = this.favoritos;
    data['comentarios'] = this.comentarios;
    data['likesComentario'] = this.likesComentario;
    data['grupoParticipar'] = this.grupoParticipar;
    data['grupoSair'] = this.grupoSair;
    data['grupoSolicitarParticipar'] = this.grupoSolicitarParticipar;
    data['grupoUsuarioAdicionado'] = this.grupoUsuarioAdicionado;
    data['grupoUsuarioAceito'] = this.grupoUsuarioAceito;
    data['grupoUsuarioRemovido'] = this.grupoUsuarioRemovido;
    data['grupoUsuarioRecusado'] = this.grupoUsuarioRecusado;
    data['usuarioAmizadeSolicitada'] = this.usuarioAmizadeSolicitada;
    data['usuarioAmizadeDesfeita'] = this.usuarioAmizadeDesfeita;
    data['usuarioAmizadeAceita'] = this.usuarioAmizadeAceita;
    data['usuarioAmizadeRecusada'] = this.usuarioAmizadeRecusada;
    data['mensagens'] = this.mensagens;
    data['reminders'] = this.reminders;
    return data;
  }
}
