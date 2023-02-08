import 'package:flutter/services.dart';

closeKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}
