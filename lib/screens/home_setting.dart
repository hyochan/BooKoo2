import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecount/providers/current_ledger.dart';
import 'package:wecount/screens/setting_currency.dart';
import 'package:wecount/screens/setting_excel.dart';
import 'package:wecount/types/color.dart';
import 'package:wecount/utils/colors.dart';

import '../shared/home_header.dart' show renderHomeAppBar;
import '../shared/setting_list_item.dart'
    show ListItem, TileItem, SettingTileItem;
import '../utils/general.dart' show General;
import '../utils/localization.dart';

class HomeSetting extends StatefulWidget {
  HomeSetting({
    Key? key,
    this.title = '',
  }) : super(key: key);
  final String title;

  @override
  _HomeSettingState createState() => _HomeSettingState();
}

class _HomeSettingState extends State<HomeSetting> {
  @override
  Widget build(BuildContext context) {
    var color = Provider.of<CurrentLedger>(context).getLedger() != null
        ? Provider.of<CurrentLedger>(context).getLedger()!.color
        : ColorType.DUSK;

    final List<ListItem> _items = [
      TileItem(
        title: t('CURRENCY'),
        trailing: Text('ARS | \$ '),
        leading: Icon(
          Icons.account_balance,
          color: cloudyBlueColor,
          size: 24.0,
        ),
        onTap: () =>
            General.instance.navigateScreenNamed(context, SettingCurrency.name),
      ),
      TileItem(
        title: t('EXPORT_EXCEL'),
        trailing: Icon(Icons.arrow_forward),
        leading: Icon(
          Icons.import_export,
          color: cloudyBlueColor,
          size: 24.0,
        ),
        onTap: () =>
            General.instance.navigateScreenNamed(context, SettingExcel.name),
      ),
    ];

    return Scaffold(
      appBar: renderHomeAppBar(
        context: context,
        title: widget.title,
        color: getColor(color),
        fontColor: Colors.white,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                        height: 1.0,
                      ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return SettingTileItem(item as TileItem);
                  }),
            )
          ],
        ),
      ),
    );
  }
}
