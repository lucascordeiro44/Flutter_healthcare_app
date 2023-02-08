
import 'package:flutter_dandelin/pages/chat2/post/comentario.dart';
import 'package:flutter_dandelin/pages/chat2/post/post.dart';

class Notificacao {
  final int id;
  final String texto;
  final String titulo;
  final String dataHora;
  final String data;
  final String tipo;
  final String nomeUsuario;
  final String urlThumbUsuario;
  final String urlThumbGrupo;

  final bool lida;

  final int postId;
  final Post post;
  final Comentario comentario;
  ThumbTipo thumbTipo;

  Notificacao(
      this.id,
      this.texto,
      this.titulo,
      this.dataHora,
      this.tipo,
      this.nomeUsuario,
      this.urlThumbUsuario,
      this.lida,
      this.urlThumbGrupo,
      this.data,
      this.postId,
      this.post,
      this.comentario);

//  Notificacao.fromFirebasePush(Map<String, dynamic> map)

  Notificacao.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        texto = map["texto"],
        titulo = map["titulo"],
        dataHora = map["dataHora"],
        tipo = map["tipo"],
        nomeUsuario = map["nomeUsuario"],
        urlThumbUsuario = map["urlThumbUsuario"],
        lida = map["lida"] as bool,
        urlThumbGrupo = map["urlThumbGrupo"],
        data = map["data"],
        postId = map["postId"],
        post = map["post"] != null ? Post.fromJson(map["post"]) : null,
        comentario = map["comentario"] != null
            ? Comentario.fromJson(map["comentario"])
            : null;

  Notificacao.fromPayload(Map<String, dynamic> map)
      : id = int.parse(map["data"]["pushId"]),
        texto = map["notification"]["body"],
        titulo = map["notification"]["title"],
        dataHora = null,
        tipo = map["data"]["tipo"],
        nomeUsuario = null,
        urlThumbUsuario = null,
        lida = null,
        urlThumbGrupo = null,
        data = null,
        postId = map["data"]["postId"] != null
            ? int.parse(map["data"]["postId"])
            : null,
        post = null,
        comentario = null;

  Notificacao.fromMessage(Map<String, dynamic> map)
      : id = int.parse(map["data"]["mensagemId"]),
        texto = map["notification"]["body"],
        titulo = map["notification"]["title"],
        tipo = map["data"]["tipo"],
        data = null,
        nomeUsuario = null,
        urlThumbGrupo = null,
        urlThumbUsuario = null,
        lida = null,
        dataHora = null,
        postId = int.parse(map["data"]["pushId"]),
        post = null,
        comentario = null;

  getThumb() {
    if (equalsOrContains(tipo, "LIKE")) {
      return ThumbTipo.like;
    } else if (equalsOrContains(tipo, "COMENTARIO")) {
      return ThumbTipo.comentario;
    } else if (equalsOrContains(tipo, "NEW_POST")) {
      return ThumbTipo.newPost;
    } else if (equalsOrContains(tipo, "FAVORITO")) {
      return ThumbTipo.favorito;
    } else if (equalsOrContains(tipo, "USUARIO_SOLICITAR_AMIZADE")) {
      return ThumbTipo.usuarioSolicitarAmizade;
    } else if (equalsOrContains(tipo, "USUARIO_ACEITAR_AMIZADE")) {
      return ThumbTipo.usuarioAceitarAmizade;
    } else if (equalsOrContains(tipo, "USUARIO_DESFAZER_AMIZADE")) {
      return ThumbTipo.usuarioDesfazerAmizade;
    } else if (equalsOrContains(tipo, "USUARIO_RECUSAR_AMIZADE")) {
      return ThumbTipo.usuarioRecusarAmizade;
    } else if (equalsOrContains(tipo, "GRUPO_")) {
      return ThumbTipo.grupo;
    } else
      return ThumbTipo.defaults;
  }

  bool get isMensagem => tipo == "MENSAGEM";

  equalsOrContains(String valueA, String valueB) {
    return valueA == valueB || valueA.contains(valueB);
  }

  getMensagem() {
    String mensagem = comentario?.mensagem;
    if (mensagem != null && mensagem.isNotEmpty) return mensagem;
    return post?.mensagem;
  }
}

class ThumbTipo {
  String thumbOn;
  String thumbOff;

  ThumbTipo(this.thumbOn, this.thumbOff);

  static ThumbTipo defaults = ThumbTipo(
      "assets/notifications/notification_comment_on.png",
      "assets/notifications/notification_comment_off.png");
  static ThumbTipo like = ThumbTipo(
      "assets/notifications/notification_like_on.png",
      "assets/notifications/notification_like_off.png");
  static ThumbTipo comentario = ThumbTipo(
      "assets/notifications/notification_comment_on.png",
      "assets/notifications/notification_comment_off.png");
  static ThumbTipo newPost = ThumbTipo(
      "assets/notifications/notification_publish_on.png",
      "assets/notifications/notification_publish_off.png");
  static ThumbTipo favorito = ThumbTipo(
      "assets/notifications/notification_favorito_on.png",
      "assets/notifications/notification_favorito_off.png");
  static ThumbTipo usuarioSolicitarAmizade = ThumbTipo(
      "assets/notifications/notification_user_accept_on.png",
      "assets/notifications/notification_user_accept_off.png");
  static ThumbTipo usuarioAceitarAmizade = ThumbTipo(
      "assets/notifications/notification_grupo_on.png",
      "assets/notifications/notification_grupo_off.png");
  static ThumbTipo usuarioDesfazerAmizade = ThumbTipo(
      "assets/notifications/notification_user_reject_on.png",
      "assets/notifications/notification_user_reject_off.png");
  static ThumbTipo usuarioRecusarAmizade = ThumbTipo(
      "assets/notifications/notification_user_reject_on.png",
      "assets/notifications/notification_user_reject_off.png");
  static ThumbTipo grupo = ThumbTipo(
      "assets/notifications/notification_grupo_on.png",
      "assets/notifications/notification_grupo_off.png");
}
