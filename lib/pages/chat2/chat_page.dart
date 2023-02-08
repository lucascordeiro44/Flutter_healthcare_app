import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dandelin/pages/chat2/chat.dart';
import 'package:flutter_dandelin/pages/chat2/chat_conversas_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/chat_mensagem_info_page.dart';
import 'package:flutter_dandelin/pages/chat2/chat_page_bloc.dart';
import 'package:flutter_dandelin/pages/chat2/colors.dart';
import 'package:flutter_dandelin/pages/chat2/user_chat.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/alert.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/chat_buble.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/image_viewer.dart';
import 'package:flutter_dandelin/pages/chat2/widgets/link_infos_card.dart';
import 'package:flutter_dandelin/utils/api_response.dart';
import 'package:flutter_dandelin/utils/nav.dart';
import 'package:flutter_dandelin/utils_livecom/scroll.dart';
import 'package:flutter_dandelin/widgets/app_circle_avatar.dart';
import 'package:flutter_dandelin/widgets/dialogs.dart';
import 'package:flutter_dandelin/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dandelin/pages/chat2/websocket/web_socket.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dandelin/pages/chat2/app_bloc_chat.dart';

class ChatPage extends StatefulWidget {
  final Chat c;
  final String avatar;
  final User user;
  final ChatConversasBloc chatConversasBloc;
  final bool fromConsultaAgendadoPage;

  ChatPage(this.c, this.avatar, this.user, this.chatConversasBloc, {this.fromConsultaAgendadoPage = false});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  var _bloc = ChatPageBloc();
  AppBloc _appBlocChat = AppBloc();

  var _scrollController = ScrollController();
  var _controller = TextEditingController();
  var _focusNode = FocusNode();
  var _audioController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var showProgressMessage = false;

  Chat get conversa => widget.c;

  User get usuario => widget.user;

  String get avatar => widget.avatar;
  bool get fromConsultaAgendadoPage => widget.fromConsultaAgendadoPage;
  bool fromChatOn;
  bool fromChatAway = false;

  @override
  void initState() {
    super.initState();
    fetchChat();
    _listenChat();
    _listenAudioTimeRecording();
    _listenIsDragging();
    _listenTextField();
    _listenFocusNode();
    addScrollListener(_scrollController, _bloc.fetchMore,
        outMaxSrollCallback: _bloc.readAllMsgs);

    WidgetsBinding.instance.addObserver(this);
  }



  _userConnectWebSocket() async {
    widget.chatConversasBloc.init(_appBlocChat, usuario);
    if (usuario != null) {
      print("webSocket.connect > ${usuario.id}");
      webSocket.connect("${usuario.id}");
      webSocket.listen();
      print("webSocket.login > ${usuario.login} - ${usuario.senha}");
      webSocket.login("${usuario.login}", "${usuario.senha}");
    }
  }

  fetchChat() async {

    webSocket.online();
    _bloc.init();
    _bloc.fetch(conversa);
    _listenStatus();
  }

  bool thereSelected = false;
  bool isDragging = false;

  int totalSelected;

  _listenChat() {
    _bloc.chat.listen(
      (v) {
        // if (v == null) {
        //   return;
        // }
        List<Chat> list = v;
        setState(
          () {
            totalSelected =
                list.where((c) => c.isSelected != null && c.isSelected).length;
            thereSelected = totalSelected > 0;
          },
        );
      },
    );
  }

  _listenStatus() {
    widget.chatConversasBloc.listen((v) {
      if(fromChatOn == null){
        fromChatOn = usuario.id == conversa.fromId ? conversa.toChatOn : conversa.fromChatOn;
        fromChatAway = usuario.id == conversa.fromId ? conversa.toChatAway : conversa.fromChatAway;
      }
      List<Chat> list = v;
      if (list != null) {
        list.forEach((Chat c) {
          if (c.conversaId == conversa.conversaId) {
            if (c.statusChat != null) {
              fromChatOn = c.statusChat == StatusChat.online;
              fromChatAway = c.statusChat != StatusChat.online;

            }
          }
        });
        if(this.mounted){
          setState(() {
            _getstatusChat();
          });
        }
      }
    });
  }

  _listenAudioTimeRecording() {
    _bloc.timeRecording.listen(
      (time) {
        _audioController.text = time;
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print("App in foreground");
       _userConnectWebSocket();
       webSocket.online();
      _onClickAtualizarConversa();
    } else {
      print("App in background");
//      isAndroid ? webSocket.close() : dispose();
        webSocket.close();
    }
  }

  _listenIsDragging() {
    _bloc.isDragging.listen(
      (v) {
        setState(
          () {
            isDragging = v;
          },
        );
      },
    );
  }

  _listenTextField() {
    _controller.addListener(() {
      if (_controller.text.startsWith("https://www")) {
        _bloc.fetchLink(_controller.text);
      }
    });
  }

  _listenFocusNode() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _bloc.readAllMsgs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AppBar _appBar = thereSelected ? _thereSelectedAppBar() : _defaultAppBar();

    return Scaffold(
      key: _scaffoldKey,
      appBar: _appBar,
      body: _body(),
    );
  }

  _defaultAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => pop(result: true),
      ),
      title: ListTile(
        // onTap: _onClickAppBarUser,
        contentPadding: EdgeInsets.all(0),
        leading: AppCircleAvatar(
          radius: 20,
          avatar: conversa.getAvatar(usuario),
        ),
        title: Text(
          conversa.getNameChat(usuario),
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _getstatusChat(),
      ),
      actions: <Widget>[
//        _iconButtonAppBar(Icons.attach_file, _onCickShowAnexos),
        _optionsAppBar(),
      ],
    );
  }

  _optionsAppBar() {
    return PopupMenuButton(
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 1,
            child: Text("Atualizar"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Apagar conversa"),
          ),
          // PopupMenuItem(
          //   value: 3,
          //   child: Text("Informações de acesso"),
          // ),
//          PopupMenuItem(
//            value: 4,
//            child: Text("Iniciar videoconferência"),
//          ),
        ];
      },
      onSelected: (value) {
        switch (value) {
          case 1:
            _onClickAtualizarConversa();
            break;
          case 2:
            _onClickApagarConversa();
            break;
          case 3:
            break;
          case 4:
            _onClickVideoconferencia();
            break;
          default:
        }
      },
      icon: Icon(
        Icons.more_vert,
        color: Colors.white,
      ),
    );
  }

  _thereSelectedAppBar() {
    return AppBar(
      backgroundColor: Colors.red,
      title: Text(totalSelected.toString()),
      actions: <Widget>[
        totalSelected == 1
            ? _iconButtonAppBar(Icons.info, _onClickInfoMsg)
            : SizedBox(),
        _copyboardButton(),
        SizedBox(width: 20)
//        _iconButtonAppBar(MdiIcons.arrowRightBold, () {}),
//        _iconButtonAppBar(Icons.more_vert, () {})
      ],
    );
  }

  _copyboardButton() {
    return StreamBuilder(
      initialData: List<Chat>(),
      stream: _bloc.chat.stream,
      builder: (context, snapshot) {
        List<Chat> list = snapshot.data;

        return list
                    .where((element) =>
                        element.isSelected != null &&
                        element.isSelected &&
                        (element.isAudio || element.isImagem))
                    .length >
                0
            ? SizedBox()
            : _iconButtonAppBar(Icons.content_copy, _onClickCopyboard);
      },
    );
  }

  _iconButtonAppBar(IconData icon, Function function) {
    return IconButton(
      icon: Icon(icon),
      onPressed: function,
    );
  }


  _body() {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/chat/chat_background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: _chatScreen(),
              ),
              _linkInfosWidget(),
              _fieldMenssage(),
            ],
          ),
        ),
        _showMenuAnexos(),
      ],
    );
  }

  _showMenuAnexos() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.showMenuAnexos.stream,
      builder: (context, snapshot) {
        bool show = snapshot.data;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: 350),
              width: MediaQuery.of(context).size.width,
              height: show ? 100 : 0,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    _menuAnexosButton('assets/chat/chat_attach_gallery.png',
                        "Galeria", _onClickGaleria),
                    _menuAnexosButton('assets/chat/chat_attach_camera.png',
                        "Câmera", _onClickCamera),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _linkInfosWidget() {
    return StreamBuilder(
      stream: _bloc.linkData.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        Entity entity = snapshot.data;

        return Container(
          color: Color.fromRGBO(220, 248, 198, 1),
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          margin: EdgeInsets.only(bottom: 3),
          child: LinkInfosCard(
            color: Color.fromRGBO(205, 237, 184, 1),
            descricao: entity.descricao,
            imageLink: entity.imagem,
            titleLink: entity.titulo,
            url: entity.url,
          ),
        );
      },
    );
  }

  _menuAnexosButton(String img, String title, Function function) {
    return RawMaterialButton(
      onPressed: function,
      child: Column(
        children: <Widget>[
          Image.asset(img, height: 50),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  _chatScreen() {
    return StreamBuilder(
      stream: _bloc.chat.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Text(snapshot.error.toString(), textAlign: TextAlign.center),
          );
        }

        if (!snapshot.hasData) {
          return Progress();
        }

        List<Chat> list = snapshot.data;

        if (list.length == 0) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: Text("Não possui nenhuma menssagem."),
          );
        }

        return _listMenssagens(list);
      },
    );
  }

  _listMenssagens(List<Chat> list) {
    List<Chat> listR = list.reversed.toList();

    int msgNotRead = listR
        .where((element) => element.lida == 0 && element.fromId != usuario.id)
        .length;

    bool temMsgNotRead = msgNotRead > 0;

    int length = listR.length + 1;

    if (temMsgNotRead) {
      length++;
    }

    return ListView.builder(
      reverse: true,
      controller: _scrollController,
      itemCount: length,
      itemBuilder: (context, idx) {
        if (listR.length == idx - (temMsgNotRead ? 1 : 0)) {
          return _loading();
        }

        if (temMsgNotRead && idx == msgNotRead) {
          return _msgNotReadRow(msgNotRead);
        }

        int i = idx -
            (temMsgNotRead
                ? idx > msgNotRead
                    ? 1
                    : 0
                : 0);

        return ChatBuble(
          usuario: usuario,
          chat: listR[i],
          marginBottom: idx == 0,
          marginTop: idx == listR.length - (temMsgNotRead ? 2 : 1),
          onLongPress: _onLongPressChatBuble,
          onClick: _onClickChatBuble,
          isDragging: _bloc.isDragging,
          audioPlaying: _bloc.audioPlaying,
          onClickImage: _onClickImage,
          onClickArquivo: _onClickArquivo,
        );
      },
    );
  }

  _loading() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.loading.stream,
      builder: (context, snapshot) {
        return snapshot.data
            ? Container(
                child: Progress(),
                margin: EdgeInsets.symmetric(vertical: 10),
              )
            : SizedBox();
      },
    );
  }

  _msgNotReadRow(int msgNotRead) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 2),
      height: 35,
      color: Colors.black.withOpacity(.08),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.15),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          "Você possui $msgNotRead ${msgNotRead > 1 ? "mensagens" : "mensagem"} não lida${msgNotRead > 1 ? "s" : ""}",
        ),
      ),
    );
  }

  _fieldMenssage() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 5, left: 5, right: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                _inputText(),
                SizedBox(width: 7),
                _iconButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _inputText() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(30.0),
          color: AppColors.branco_255,
        ),
        child: StreamBuilder(
            initialData: false,
            stream: _bloc.recording.stream,
            builder: (context, snapshot) {
              return snapshot.data ? _audioTextField() : _textTextField();
            }),
      ),
    );
  }

  _audioTextField() {
    return TextFormField(
      controller: _audioController,
      decoration: InputDecoration(
        contentPadding:
            EdgeInsets.only(top: 13, bottom: 9, left: 20, right: 20),
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.mic,
          color: Colors.redAccent,
        ),
      ),
      style: TextStyle(
        color: Colors.grey,
        fontSize: 18,
      ),
    );
  }

  _textTextField() {
    return TextFormField(
      focusNode: _focusNode,
      controller: _controller,
      maxLines: null,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(top: 9, bottom: 9, left: 20, right: 20),
        border: InputBorder.none,
        hintText: "Digite uma messagem",
        suffix: _streamLinkData(),
      ),
      onChanged: _isTypingText,
    );
  }

  _streamLinkData() {
    return StreamBuilder(
      initialData: false,
      stream: _bloc.isLink.stream,
      builder: (context, snapshot) {
        return snapshot.data
            ? Container(
                child: Progress(),
                width: 15,
                height: 15,
              )
            : SizedBox();
      },
    );
  }

  _iconButton() {
//    return StreamBuilder(
//      initialData: false,
//      stream: _bloc.isTyping.stream,
//      builder: (context, snapshot) {
//        if (snapshot.data) {
    return RawMaterialButton(
      padding: EdgeInsets.all(13),
      onPressed: _onClickMenssage,
      child: Icon(
        Icons.send,
        color: Colors.white,
        size: 22,
      ),
      shape: new CircleBorder(),
      elevation: 0.0,
      fillColor: Theme.of(context).primaryColor,
      constraints: BoxConstraints(),
    );
//        } else {
//          return ChatWidgetAudio(bloc: _bloc, usuario: usuario);
//        }
//      },
//    );
  }

  _isTypingText(String value) {
    _bloc.isTyping.add(value != "" && value != null);
  }

  _getstatusChat() {
    if (fromChatOn != null) {
      if (fromChatOn) {
        return Text(fromChatAway ? "Offline" : "Online",
            style: TextStyle(color: Colors.white));
      } else if (!fromChatOn) {
        return Text("Offline", style: TextStyle(color: Colors.white));
      }
    } else {
      return SizedBox();
    }
  }

  _onClickInfoMsg() {
    push(ChatMensagemInfoPage(chat: _bloc.getMsgSelected(), usuario: usuario));
  }

  _onClickMenssage() async {
    if (_controller.text.isNotEmpty) {
      String msg = _controller.text;

      _controller.clear();
      Chat defaultChat = await _bloc.sendMessage(msg, usuario);
      widget.chatConversasBloc.newChat(defaultChat);
      _bloc.isTyping.add(false);
    }
  }

  _onLongPressChatBuble(Chat chat) {
    if (!isDragging) {
      _bloc.chatOnlongPress(chat);
    }
  }

  _onClickChatBuble(Chat chat) async {
    bool launchLink = _bloc.chatOnClick(chat);

    if (chat.isLink && launchLink) {
      if (await canLaunch(chat.msg)) {
        await launch(chat.msg);
      } else if (await canLaunch("https://${chat.msg}")) {
        await launch("https://${chat.msg}");
      } else {
        showSimpleDialog("Não é possivel abrir este link.");
      }
      launch(chat.msg);
    }
  }

  _onCickShowAnexos() {
    _bloc.showAnexos();
  }

  _onClickAtualizarConversa() {
    _bloc.atualizarConversa();
  }

  _onClickGaleria() async {
    var file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (file == null) {
      return;
    }

    _sendFile(file);
  }

  _onClickCamera() async {
    var file = await ImagePicker.pickImage(source: ImageSource.camera);

    if (file == null) {
      return;
    }

    _sendFile(file);
  }

  _sendFile(File file) {
    _bloc.showMenuAnexos.add(false);
    _bloc.sendImage(file, usuario);
  }

  _onClickApagarConversa() {
    showAlertConfirm(context,
        "Ao excluir a conversa todas as mensagens serão apagadas, confirma?",
        callbackNao: _onClickNao,
        callbackSim: _onClickDeletar,
        nao: "NÃO",
        sim: "DELETAR");
  }

  _onClickDeletar() async {
    pop(result: true);
    showSimpleDialog('Excluindo conversa..', progress: true);

    ApiResponse response = await _bloc.deletarConversa();

    pop(result: true);
    response.ok ? pop(result: true) : alert(response.msg);
  }

  _onClickNao() {
    pop();
  }

  _onClickImage(ImageProvider imageProvider, String imagePath) {
    push(ImageViewer(imageProvider: imageProvider, imagePath: imagePath));
  }

  _onClickCopyboard() {
    AppCopyboard appCopyboard = _bloc.getCopyboard();

    Clipboard.setData(new ClipboardData(text: appCopyboard.msg));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: appCopyboard.total == 1
          ? Text("Mensagem copiada!")
          : Text('${appCopyboard.total} mensagens copiadas!'),
    ));

    _bloc.unselectAll();
  }

  _onClickAppBarUser() {
    int id = conversa.getIdOtherUser(usuario);

    if (id != null) {
      alert("Abir pagina de usuário");
//      push(UserPage(
//        showDrawer: false,
//        user: User(
//          id: id,
//          urlFotoUsuario: conversa.getAvatar(usuario),
//          urlFotoUsuarioThumb: conversa.getAvatar(usuario),
//        ),
//        userId: id,
//        userName: conversa.getNameChat(usuario),
//      ));
    }
  }

  _onClickVideoconferencia() async {
    try {
      if (Platform.isAndroid) {
        // await AppAvailability.checkAvailability(
        //     "com.google.android.apps.meetings");

        _onClickProsseguir(doPop: false);
      } else {
        _alertMeetHangouts();
      }
    } catch (e) {
      _alertMeetHangouts();
    }
  }

  _alertMeetHangouts() {
    showAlertConfirm(
      context,
      "Para uma melhor experiencia, é indicado você possuir o aplicativo Meet Hangouts instalado em seu smarthphone. Deseja abrir a loja ?",
      callbackNao: _onClickAbrirLoja,
      nao: "Abrir loja",
      sim: "Prosseguir",
      callbackSim: _onClickProsseguir,
    );
  }

  _onClickProsseguir({bool doPop = true}) async {
    if (doPop) {
      pop();
    }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          Container(
            width: 35,
            height: 35,
            child: CircularProgressIndicator(),
          ),
          SizedBox(width: 15),
          Text("Criando link Meet Hangouts.."),
        ],
      ),
      duration: Duration(seconds: 15),
    ));

    ApiResponse response = await _bloc.createVideoConferencia(usuario);

    _scaffoldKey.currentState.removeCurrentSnackBar();
    if (!response.ok) {
      showSimpleDialog(response.msg);
    }
  }

  _onClickAbrirLoja() async {
    launch(Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.google.android.apps.meetings&hl=pt_BR'
        : 'https://apps.apple.com/br/app/hangouts/id643496868');

    pop();
  }

  _onClickArquivo(Chat chat) {
    launch(chat.firtsArquivo.url);
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.readAllMsgs();
    _bloc.dispose();
    _scrollController.dispose();
    _controller.dispose();
    _audioController.dispose();
    _focusNode.dispose();
     webSocket.away();
    WidgetsBinding.instance.removeObserver(this);
  }
}
