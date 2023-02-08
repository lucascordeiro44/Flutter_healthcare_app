import 'package:flutter_dandelin/model/consulta.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/chat/chat_detalhe_api.dart';
import 'package:flutter_dandelin/utils/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart';

class ChatDetalheBloc {
  final urlChat = SimpleBloc<String>();

  init(User user, User medico) async {
    // print(consulta);
    try {
      HttpResponse response = await ChatDetalheApi.getChat(user, medico);

// consulta.

      if (response == null) {
        urlChat.addError("Erro ao carregar chat");
        return;
      }

      Map entity = response.data["entity"];

      String u = entity["url"];

      String url = "https://dandelin.livetouchdev.com.br" +
          u +
          "&removeListaContato=true&removeHeader=true";

      urlChat.add(url);
    } catch (e) {
      print(e);
      urlChat.addError("Erro ao carregar chat");
    }
  }

  dispose() {
    urlChat.dispose();
  }
}
