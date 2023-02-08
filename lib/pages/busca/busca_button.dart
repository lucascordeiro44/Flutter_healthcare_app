import 'package:flutter/material.dart';
import 'package:flutter_dandelin/colors.dart';
import 'package:flutter_dandelin/widgets/app_form_field.dart';
import 'package:rxdart/subjects.dart';

class BuscaButton extends StatefulWidget {
  final Widget icon;
  final Function onClick;
  final Color color;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String title;
  final Function(String) onChanged;
  final Function(String) onFieldSubmitted;
  final String hintText;

  BuscaButton({
    Key key,
    this.icon,
    this.onClick,
    this.color = Colors.white,
    this.controller,
    this.focusNode,
    this.title,
    this.onChanged,
    this.onFieldSubmitted,
    this.hintText,
  }) : super(key: key);

  @override
  _BuscaButtonState createState() => _BuscaButtonState();
}

class _BuscaButtonState extends State<BuscaButton> {
  final _onChangedStream = PublishSubject<String>();

  @override
  void initState() {
    super.initState();
    _onChangedStream.stream
        .debounceTime(Duration(milliseconds: 400))
        .listen(widget.onChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.2,
      child: Container(
        color: widget.color,
        child: AppFormField(
          hintText: widget.hintText,
          showFocusRisk: false,
          focusNode: widget.focusNode,
          controller: widget.controller,
          isCircular: false,
          prefixIcon: widget.icon,
          onChanged: _onChangedStream.add,
          onFieldSubmitted: widget.onFieldSubmitted,
          fontWeight: FontWeight.w500,
          fontColor: AppColors.greyFont,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _onChangedStream.close();
    super.dispose();
  }
}
