import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dandelin/utils/imports.dart';
import 'package:flutter_dandelin/widgets/app_bar.dart';

class CountryPick extends StatefulWidget {
  final String initialSelection;
  final Function(CountryCode) onChanged;

  const CountryPick({
    Key key,
    this.initialSelection = "+55",
    @required this.onChanged,
  }) : super(key: key);
  @override
  _CountryPickState createState() => _CountryPickState();
}

class _CountryPickState extends State<CountryPick> {
  @override
  Widget build(BuildContext context) {
    return CountryListPick(
      appBar: DandelinAppbar("Selecione o país"),
      pickerBuilder: (context, CountryCode countryCode) {
        return Row(
          children: [
            Image.asset(
              countryCode.flagUri,
              package: 'country_list_pick',
              height: 25,
            ),
            SizedBox(width: 7),
            Container(
              padding: EdgeInsets.only(top: 4),
              child: AppText(
                countryCode.dialCode,
                fontSize: 16,
                color: AppColors.greyFont,
              ),
            ),
            SizedBox(width: 7),
          ],
        );
      },
      theme: CountryTheme(
        searchHintText: "Procurar..",
        lastPickText: "Selecionado:",
        isShowFlag: true,
        isShowCode: true,
        isDownIcon: true,
        searchText: "Selecione",
        alphabetSelectedBackgroundColor: AppColors.kPrimaryColor,
      ),
      initialSelection: widget.initialSelection,
      onChanged: widget.onChanged,
    );
  }
}
