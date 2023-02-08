import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dandelin/utils/imports.dart';

class AppFormField extends StatelessWidget {
  final Function onChanged;
  final Function onSaved;
  final Widget suffixIcon;
  final String hintText;
  final bool isPassword;
  final FocusNode focusNode;
  final Function(String) onFieldSubmitted;
  final TextInputType textInputType;
  final Widget prefix;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final TextAlign textAlign;
  final List<TextInputFormatter> inputFormatterrs;
  final bool autoFocus;
  final bool enabled;
  final String initialValue;
  final bool isCircular;
  final bool showFocusRisk;
  final bool showUnfocusRisk;
  final bool showErrorBorder;
  final String labelText;
  final Function validator;
  final Widget prefixIcon;
  final EdgeInsets contentPadding;
  final String fontFamily;
  final String fontFamilyHint;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;
  final int maxLines;
  final double letterSpacing;

  const AppFormField({
    Key key,
    this.onChanged,
    this.onSaved,
    this.suffixIcon,
    this.hintText,
    this.isPassword = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.textInputType,
    this.prefix,
    this.textCapitalization = TextCapitalization.none,
    this.controller,
    this.textAlign = TextAlign.start,
    this.inputFormatterrs,
    this.autoFocus = false,
    this.enabled = true,
    this.initialValue,
    this.isCircular = false,
    this.labelText,
    this.validator,
    this.prefixIcon,
    this.contentPadding,
    this.fontFamily,
    this.fontFamilyHint,
    this.fontSize = 16,
    this.showFocusRisk = true,
    this.showUnfocusRisk = true,
    this.showErrorBorder = true,
    this.fontWeight,
    this.fontColor,
    this.letterSpacing,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCircular ? 43 : null,
      child: new TextFormField(
        maxLines: maxLines,
        style: TextStyle(
          letterSpacing: letterSpacing,
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
        initialValue: initialValue,
        enabled: enabled,
        autofocus: autoFocus,
        inputFormatters: inputFormatterrs,
        controller: controller,
        decoration: InputDecoration(
          contentPadding: isCircular
              ? EdgeInsets.symmetric(vertical: 12, horizontal: 20)
              : contentPadding,
          prefix: prefix,
          focusedBorder: isCircular
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: showFocusRisk ? 1.0 : 0.1,
                  ),
                ),
          border: isCircular
              ? OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.greyFont),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                )
              : null,
          enabledBorder: isCircular
              ? OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.greyFontLow,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                )
              : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black12,
                    width: showUnfocusRisk ? 1 : 0.1,
                  ),
                ),
          errorBorder: showErrorBorder
              ? null
              : UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 0.1,
                  ),
                ),
          labelText: labelText,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            color: AppColors.greyStrong,
            fontWeight: FontWeight.w300,
            fontFamily: isCircular ? 'Mark Book' : fontFamily,
          ),
        ),
        textAlign: textAlign,
        textCapitalization: textCapitalization,
        onSaved: onSaved,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        obscureText: isPassword,
        focusNode: focusNode,
        keyboardType: textInputType,
        validator: validator,
      ),
    );
  }
}
