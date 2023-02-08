import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/model/user.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart' as userChat;
import 'package:flutter_dandelin/pages/chat2/app_bloc_chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_conversas_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/chat_conversas_card.dart';
import 'package:flutter_dandelin/pages/chat2/chat_nova_conversa_page.dart';
import 'package:flutter_dandelin/pages/chat2/chat_page.dart';
import 'package:flutter_dandelin/pages/chat2/colors.dart';
import 'package:flutter_dandelin/colors.dart' as dandelinColors;
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/error.dart';
import 'package:flutter_dandelin/utils/nav.dart';
import 'package:flutter_dandelin/utils_livecom/network.dart';
import 'package:flutter_dandelin/utils_livecom/scroll.dart';
import 'package:flutter_dandelin/utils_livecom/shimmer.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:flutter_dandelin/utils_livecom/object_extension.dart';

class ChatConversasPage extends StatefulWidget {
  @override
  _ChatConversasPageState createState() => _ChatConversasPageState();
}

class _ChatConversasPageState extends State<ChatConversasPage>
    with WidgetsBindingObserver {
  final _bloc = ChatConversasBloc();
  final _scrollController = ScrollController();

  User dandelinUser;
  userChat.User usuario;

//  AppBloc get _appBlocChat => AppBloc.get(context);

  AppBloc _appBlocChat = AppBloc();

  bool _isSearching = false;
  FocusNode _searchFn = FocusNode();

  @override
  void initState() {
    super.initState();
    _userConnectWebSocket();

    _bloc.fetch();

    addScrollListener(_scrollController, _fetchMore);

    _listenSearch();
    _listenSyncingChats();

    WidgetsBinding.instance.addObserver(this);
  }

  _userConnectWebSocket() async {
    usuario = await userChat.User.getPrefs();
    _bloc.init(_appBlocChat, usuario);
    if (usuario != null) {
      print("webSocket.connect > ${usuario.id}");
      webSocket.connect("${usuario.id}");
      webSocket.listen();
      print("webSocket.login > ${usuario.login} - ${usuario.senha}");
      webSocket.login("${usuario.login}", "${usuario.senha}");
    }
  }

  _listenSearch() {
    _bloc.isSearching.listen((bool v) {
      setState(() => _isSearching = v);
    });
  }

  _listenSyncingChats() {
    _bloc.syncing.listen((syncing) {
      if (syncing != null) {
        syncing ? _syncingAlert(syncing) : pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.cinza_04,
        appBar: _isSearching ? _searchAppBar() : _defaultAppBar(),
        floatingActionButton: _floatingActionButton(),
        body: _body(),
      ),
    );
  }

  _defaultAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: pop,
      ),
      title: Text(
        "Chat",
        style: TextStyle(color: Colors.white),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: _onClickSearch,
        ),
        _popupMenuButton(),
      ],
    );
  }

  _searchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: _onClickCancelSearch,
      ),
      title: TextFormField(
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
        focusNode: _searchFn,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Pesquisar..",
          hintStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        onChanged: _onChangedSearchInput,
      ),
      actions: <Widget>[],
    );
  }

  _popupMenuButton() {
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.more_horiz,
        color: Colors.white,
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            child: Text("Atualizar"),
            value: 1,
          ),
//          PopupMenuItem(
//            child: Text("Novo grupo"),
//            value: 2,
//          ),
//          PopupMenuItem(
//            child: Text("Developer Options"),
//            value: 3,
//          ),
//          PopupMenuItem(
//            child: Text("Marcar todas como lidas"),
//            value: 4,
//          ),
        ];
      },
      onSelected: (int value) {
        switch (value) {
          case 1:
            _onClickAtualizarConversas();
            break;
        }
      },
    );
  }

  _onClickAtualizarConversas() {
    _bloc.refresh();
  }

  _floatingActionButton() {
    return Padding(
      padding: Platform.isIOS ? EdgeInsets.only(bottom: 84.0) : EdgeInsets.zero,
      child: FloatingActionButton(
        backgroundColor: dandelinColors.AppColors.kPrimaryColor,
        heroTag: null,
        onPressed: _onClickFabNovaConversa,
        child: Icon(Icons.chat),
      ),
    );
  }

  _body() {
    return Column(
      children: [
        _networkStatus(),
        _streamConversas(),
      ],
    );
  }

  _networkStatus() {
    return StreamBuilder(
      stream: NetworkUtil().onConnectionChanged(),
      builder: (context, snapshot) {
        ConnectivityResult status = snapshot.data;
        return status == ConnectivityResult.none
            ? Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text("Por favor, verifique sua conexão"),
                    height: 40,
                  ),
                  Container(
                    height: 3,
                    color: Color.fromRGBO(255, 62, 62, 1),
                  ),
                ],
              )
            : Container(
                height: 3,
                color: Color.fromRGBO(62, 255, 62, 1),
              );
      },
    );
  }

  _streamConversas() {
    return Expanded(
      child: StreamBuilder(
        stream: _bloc.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _loadingList();
          }

          if (snapshot.hasError) {
            return TextError(snapshot.error);
          }

          List<Chat> list = snapshot.data;

          if (list.isNullOrEmpty()) {
            return Center(
              child: Text(_isSearching
                  ? "Você possui nenhuma conversa com este filtro"
                  : "Você não possui conversas."),
            );
          }

          return _listConversas(list);
        },
      ),
    );
  }

  _loadingList() {
    return ListView.separated(
      separatorBuilder: (_, __) => Divider(indent: 75),
      itemCount: 10,
      itemBuilder: (context, idx) {
        return shimmer(
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            leading: Container(height: 50, width: 50, child: CircleAvatar()),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.white,
                  width: 200,
                  height: 20,
                ),
              ],
            ),
            subtitle: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  color: Colors.white,
                  width: 120,
                  height: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _listConversas(List<Chat> conversas) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: conversas.length + 1,
        itemBuilder: (context, index) {
          if (index == conversas.length) {
            return _loading();
          }

          return ChatConversaCard(
            chat: conversas[index],
            onClickConversa: _onClickConversa,
            usuario: usuario,
          );
        },
      ),
    );
  }

  _loading() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.loading.stream,
      builder: (context, snapshot) {
        return snapshot.data
            ? Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Progress(),
              )
            : SizedBox();
      },
    );
  }

  _syncingAlert(syncing) {
    showWidgetDialog(
      context,
      StreamBuilder(
        stream: _bloc.syncingChats.stream,
        builder: (context, snapshot) {
          SyncingChats syncingChats = snapshot.data;

          return Text(
              "Sincronizando ${syncingChats.count} de total ${syncingChats.total}");
        },
      ),
      dismissible: false,
      progress: true,
    );
  }

  Future<Null> _onRefresh() async {
    _bloc.refresh();
  }

  _fetchMore() {
    _bloc.fetchMore();
  }

  _onClickConversa(Chat c, String avatar) async {
    _bloc.changeOpenedChat(c);

     var v =  await push(ChatPage(c, avatar, usuario, _bloc));

    _bloc.changeOpenedChat(null);

    if (v != null && v) {
      _bloc.refresh();
    }
  }

  _onClickFabNovaConversa() {
    push(ChatNovaConversaPage(
      chatConversasBloc: _bloc,
      user: usuario,
    )).then((_) => _onClickAtualizarConversas());
  }

  _onClickSearch() {
    _bloc.isSearching.add(true);
    _searchFn.requestFocus();
  }

  _onClickCancelSearch() {
    _searchFn.unfocus();
    _bloc.cancelSearch();
  }

  _onChangedSearchInput(String value) {
    _bloc.searchListaConversas(value);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
//    bool isAndroid = Platform.isAndroid;
    if (state == AppLifecycleState.resumed) {
      _userConnectWebSocket();
      _onRefresh();
      // isAndroid ? webSocket.online() : _userConnectWebSocket();
    }  else if( state == AppLifecycleState.paused) {
//      isAndroid ? webSocket.close() : dispose();
    webSocket.close();
    }
  }

  @override
  void dispose() {
    super.dispose();

    print("dispose list");

    WidgetsBinding.instance.removeObserver(this);

    _searchFn.dispose();
    _bloc.dispose();

    webSocket.close();
  }

  _onWillPop() {
    dispose();
  }
}
