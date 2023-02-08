import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/gradients.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

class Tutorial {
  tutorialPass1(GlobalKey widgetKey, Function onClose) {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = widgetKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(10.0);

    coachMarkTile.show(
        targetContext: widgetKey.currentContext,
        markShape: BoxShape.rectangle,
        markRect: markRect,
        children: [
          TutorialDialog(
            gradient: linearEnabled,
            alignment: Alignment.center,
            topPositioned: target.localToGlobal(Offset.zero).distance +
                target.size.height +
                20,
            title: "TUTORIAL 1/3",
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  _textSpan600("VALORES "),
                  _textSpan300(
                      "Este é o valor da sua mensalidade atualizado em tempo real. Lembre-se que este valor varia de mês para mês! Ele é calculado assim: valor total de consultas realizados por toda a comunidade, divido entre todos os membros. Assim, você nunca vai pagar mais de R\$100 reais e todos terão acesso à saúde de qualidade.")
                ],
              ),
            ),
          )
        ],
        onClose: () {
          onClose();
        });
  }

  tutorialPass2(GlobalKey widgetKey, Function onClose,
      {String title = "TUTORIAL 1/2"}) {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = widgetKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);

    coachMarkTile.show(
        targetContext: widgetKey.currentContext,
        markShape: BoxShape.rectangle,
        markRect: markRect,
        children: [
          TutorialDialog(
            gradient: linearEnabled,
            padding: EdgeInsets.only(right: 16),
            alignment: Alignment.centerRight,
            topPositioned: target.size.height + 60,
            title: title,
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  _textSpan300("Sua conta "),
                  _textSpan600("AINDA NÃO ESTÁ ATIVA,"),
                  _textSpan300(
                      " ou seja, nenhum valor será cobrado.Para ativar sua conta você precisa cadastrar um método de pagamento no seu "),
                  _textSpan600("PERFIL."),
                  _textSpan300(
                      "Sem o método de pagamento você ainda não poderá agendar consultas.")
                ],
              ),
            ),
          )
        ],
        onClose: () {
          onClose();
        });
  }

  tutorialPass3(GlobalKey widgetKey, Function onClose) {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = widgetKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);

    coachMarkTile.show(
        targetContext: widgetKey.currentContext,
        markShape: BoxShape.rectangle,
        markRect: markRect,
        children: [
          TutorialDialog(
            gradient: linearEnabled,
            padding: EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            topPositioned: target.size.height + 60,
            title: "TUTORIAL 3/3",
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  _textSpan600("INBOX "),
                  _textSpan300(
                      "Aqui você receberá mensagens sobre a sua conta e novidades do dandelin. Fique sempre ligado!")
                ],
              ),
            ),
          )
        ],
        onClose: () {
          onClose();
        });
  }

  tutorialPass4(GlobalKey widgetKey, {String title = "TUTORIAL 2/2"}) {
    CoachMark coachMarkTile = CoachMark();
    RenderBox target = widgetKey.currentContext.findRenderObject();

    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(5.0);
    coachMarkTile.show(
        targetContext: widgetKey.currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          TutorialDialog(
            gradient: linearEnabledYTO,
            alignment: Alignment.center,
            bottomPositioned: target.size.height + 40,
            title: title,
            content: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  _textSpan300(
                      "Após ativar a sua conta, você já poderá agendar consultas e exames clicando neste botão: "),
                  _textSpan600("NOVO AGENDAMENTO"),
                ],
              ),
            ),
          )
        ],
        onClose: () {});
  }

  _textSpan300(String content) {
    return TextSpan(
        text: content, style: TextStyle(fontWeight: FontWeight.w300));
  }

  _textSpan600(String content) {
    return TextSpan(
        text: content, style: TextStyle(fontWeight: FontWeight.w600));
  }
}

class TutorialDialog extends StatelessWidget {
  final double topPositioned;
  final double bottomPositioned;
  final String title;
  final Widget content;
  final EdgeInsets padding;
  final Alignment alignment;
  final bool buttonBottom;
  final LinearGradient gradient;

  TutorialDialog({
    Key key,
    this.topPositioned,
    this.bottomPositioned,
    this.title,
    this.content,
    this.padding,
    this.alignment,
    this.buttonBottom = false,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPositioned,
      bottom: bottomPositioned,
      child: Container(
        width: SizeConfig.screenWidth,
        alignment: alignment,
        padding: padding,
        child: Container(
          width: SizeConfig.screenWidth * 0.75,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            top: buttonBottom ? 0 : 10,
            bottom: buttonBottom ? 15 : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              !buttonBottom ? _titleTutorial(context) : _okButton(),
              !buttonBottom ? Container() : SizedBox(height: 10),
              !buttonBottom ? Container() : _titleTutorial(context),
              SizedBox(height: 5),
              _content(),
              !buttonBottom ? SizedBox(height: 15) : Container(),
              !buttonBottom ? _okButton() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _titleTutorial(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  _content() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: content,
    );
  }

  _okButton() {
    return FlatButton(
      padding: EdgeInsets.all(0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {},
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(buttonBottom ? 0 : 10.0),
            bottomRight: Radius.circular(buttonBottom ? 0 : 10.0),
            topLeft: Radius.circular(buttonBottom ? 10.0 : 0.0),
            topRight: Radius.circular(buttonBottom ? 10.0 : 0.0),
          ),
        ),
        height: 40,
        alignment: Alignment.center,
        width: double.infinity,
        child: Text(
          "Ok! Entendi.",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
