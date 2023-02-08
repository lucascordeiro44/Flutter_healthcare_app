import 'package:flutter_dandelin/model/doctor.dart';
import 'package:flutter_dandelin/pages/chat/chat_detalhe_api.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_service.dart';
import 'package:flutter_dandelin/model/user.dart' as userDandelin;
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils_livecom/bloc.dart';
import 'package:flutter_dandelin/utils/http_helper.dart' as httpHelper;
import 'package:flutter_dandelin/pages/chat2/chat_page_bloc.dart';

class ChatNovaConversaBloc {
  final doctors = SimpleBloc<List<Doctor>>();
  final conversaBloc = SimpleBloc<int>();
  final _abrirChatBloc = ChatPageBloc();

  int page = 0;

  fetch() async {
    ApiResponse response = await ChatService.getUsersNovaConversa(page: page);

    if (response.ok) {
      doctors.add(response.result);
    } else {
      doctors.addError(response.msg);
    }
  }

  Future<Chat> getconversa(Doctor doctor) async {

    try {
      Chat chat = Chat();
      final dandelinUser = await userDandelin.User.get();
      httpHelper.HttpResponse response = await ChatDetalheApi.getChat(dandelinUser, doctor.user);
      if (response == null) {
        return null;
      }
      Map entity = response.data["entity"] as Map;
      int conversaId = entity["conversaId"] as int;
      chat.setConversaId(conversaId);
      return chat;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Chat> getChatNovaConversa(int conversaId) async {
    try {
      final ApiResponse<Chat> response = await ChatService.getChatNovaCoversa(page: 0, conversaId: conversaId);
      if (response.result == null) {
        return null;
      }
      Chat chat = response.result;
      chat.setConversaId(conversaId);
      return chat;
    } catch (e) {
      print(e);
      return null;
    }
  }

  getConversaUser(Doctor doctor) async {

    // final conversaId = await getconversaId(doctor);

    // if(conversaId != null){
    //   final reponse = await _abrirChatBloc.getMenssagens();
    // }
    ApiResponse<Chat> response = await ChatService.getConversaUser(doctor.user.id);


    return response;
  }



  dispose() {
    doctors.dispose();
  }
}
