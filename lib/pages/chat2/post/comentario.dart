import 'package:flutter_dandelin/pages/chat2/constants_chat.dart';

class Comentario {
  final int id;
  final int userId;
  final int postId;
  String msg;
  String nome;
  String data;
  int timeStamp;
  String dataStr;
  String urlFoto;
  String urlFotoThumb;
  int likeCount;
  bool like;
  bool lidaNotification;
  String mensagem;
  final String nomeAutor;

  bool likeLoading = false;

  Comentario(
      this.id,
      this.userId,
      this.postId,
      this.msg,
      this.nome,
      this.data,
      this.timeStamp,
      this.dataStr,
      this.urlFoto,
      this.urlFotoThumb,
      this.likeCount,
      this.like,
      this.lidaNotification,
      this.mensagem,
      this.nomeAutor);

  Comentario.fromJson(Map<String, dynamic> map)
      : id = map["id"] as int,
        userId = map["userId"] as int,
        postId = map["postId"] as int,
        msg = map["msg"],
        nome = map["nome"],
        data = map["data"],
        timeStamp = map["timestamp"] as int,
        dataStr = map["dataStr"],
        urlFoto = map["urlFoto"] ?? USER_PHOTO_DEFAULT,
        urlFotoThumb = map["urlFotoThumb"],
        likeCount = map["likeCount"] as int,
        like = map["like"] == "1",
        lidaNotification = map["lidaNotification"],
        nomeAutor = map["nomeAutor"],
        mensagem = map["msg"];

  @override
  String toString() {
    return 'Comentario{id: $id, userId: $userId, postId: $postId, msg: $msg, nome: $nome, data: $data, timeStamp: $timeStamp, dataStr: $dataStr, urlFoto: $urlFoto, urlFotoThumb: $urlFotoThumb, likeCount: $likeCount, like: $like, lidaNotification: $lidaNotification, mensagem: $mensagem, nomeAutor: $nomeAutor}';
  }
}
