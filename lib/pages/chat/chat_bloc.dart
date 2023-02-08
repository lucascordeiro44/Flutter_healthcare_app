import 'package:flutter_dandelin/pages/chat/chat.dart';
import 'package:flutter_dandelin/pages/chat/chat_api.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/bloc.dart';

class ChatBloc {
  final chats = SimpleBloc<List<Chat>>();
  final badges = SimpleBloc<int>();

  int page = 0;

  fetch({bool refresh = false}) async {
    if (refresh) {
      chats.add(null);
    }


    ApiResponse response = await ChatApi.fetchChats(page);

    if (response.ok) {
      List<Chat> data = chats.value ?? List<Chat>();

      data.addAll(response.result);
      chats.add(data);
    } else {
      chats.addError(response.msg);
    }
  }

  fetchTotalBadges() async {
      ApiResponse response = await ChatApi.getTotalBadges();
      if(response.ok){
        badges.add(response.result == null ? 0 : response.result);
      }
  }

  fetchMore() {
    page = page++;
    fetch();
  }

  dispose() {
    chats.dispose();
  }
}
