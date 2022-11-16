import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:wecount/models/category.dart';
import 'package:wecount/models/ledger_item.dart' show LedgerItem;
import 'package:wecount/models/photo.dart' show Photo;
import 'package:wecount/screens/category_add.dart';
import 'package:wecount/utils/navigation.dart';
import 'package:wecount/utils/routes.dart';
import 'package:wecount/widgets/category_list.dart';
import 'package:wecount/widgets/gallery.dart' show Gallery;
import 'package:wecount/widgets/header.dart';
import 'package:wecount/widgets/header.dart' show renderHeaderClose;
import 'package:wecount/utils/asset.dart' as Asset;
import 'package:wecount/utils/db_helper.dart';
import 'package:wecount/utils/localization.dart' show Localization;
import 'package:wecount/utils/logger.dart';

class LedgerItemEdit extends HookWidget {
  const LedgerItemEdit({
    Key? key,
    this.title = '',
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final List<String> choices = ['CONSUME', 'INCOME'];
    final formatCurrency = NumberFormat.simpleCurrency();
    final TextEditingController priceTextEditingController1 =
        TextEditingController(
      text: '0',
    );
    final TextEditingController priceTextEditingController2 =
        TextEditingController(
      text: '0',
    );

    var _ledgerItemConsume = useState<LedgerItem>(LedgerItem());
    var _ledgerItemIncome = useState<LedgerItem>(LedgerItem());
    // TabController? _tabController;
    var _tabController = useTabController(initialLength: 2);

    var categories = useState<List<Category>>([]);

    var _localization = Localization.of(context);

    void onDatePressed({
      CategoryType categoryType = CategoryType.CONSUME,
    }) async {
      int year = DateTime.now().year;
      int prevDate = year - 100;
      int lastDate = year + 10;
      DateTime? pickDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(prevDate),
        lastDate: DateTime(lastDate),
      );
      TimeOfDay? pickTime;
      if (pickDate != null) {
        pickTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 0, minute: 0),
        );
      }
      if (pickDate != null && pickTime != null) {
        if (categoryType == CategoryType.CONSUME) {
          _ledgerItemConsume.value.selectedDate = DateTime(
            pickDate.year,
            pickDate.month,
            pickDate.day,
            pickTime!.hour,
            pickTime.minute,
          );
        } else if (categoryType == CategoryType.INCOME) {
          _ledgerItemIncome.value.selectedDate = DateTime(
            pickDate.year,
            pickDate.month,
            pickDate.day,
            pickTime!.hour,
            pickTime.minute,
          );
        }
      }
    }

    void onLocationPressed({
      CategoryType categoryType = CategoryType.CONSUME,
    }) async {
      Map<String, dynamic>? result =
          await (navigation.navigate(context, AppRoute.locationView.path));

      if (result == null) return;

      if (categoryType == CategoryType.CONSUME) {
        _ledgerItemConsume.value.address = result['address'];
        _ledgerItemConsume.value.latlng = result['latlng'];
      } else if (categoryType == CategoryType.INCOME) {
        _ledgerItemIncome.value.address = result['address'];
        _ledgerItemIncome.value.latlng = result['latlng'];
      }
    }

    void onLedgerItemEditPressed() {
      logger.i('onLedgerItemEditPressed');
      logger.d('${_ledgerItemConsume.toString()}');
    }

    void showCategory(
      BuildContext context, {
      CategoryType categoryType = CategoryType.CONSUME,
    }) async {
      var _localization = Localization.of(context);
      categories.value = categoryType == CategoryType.CONSUME
          ? await DBHelper.instance.getConsumeCategories(context)
          : await DBHelper.instance.getIncomeCategories(context);

      void onClosePressed() {
        Navigator.of(context).pop();
      }

      void onAddPressed(CategoryType categoryType) async {
        var result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: CategoryAdd(
                categoryType: categoryType,
                lastId: categories.value[categories.value.length - 1].id,
              ),
            );
          },
        );
        if (result != null) {
          categories.value.add(result);
        }
      }

      var _result = await showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: EdgeInsets.only(top: 8),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: onClosePressed,
                      icon: Icon(Icons.close),
                    ),
                    Text(
                      '${_localization!.trans('CATEGORY')}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.displayLarge!.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onAddPressed(categoryType),
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Container(height: 8),
              Expanded(
                child: CategoryList(categories: categories.value),
              ),
            ],
          ),
        ),
      );

      useEffect(() {
        if (_tabController != null) {
          return _tabController.dispose;
        }
      }, [_tabController]);

      if (_result != null) {
        if (categoryType == CategoryType.CONSUME) {
          _ledgerItemConsume.value.category = _result;
        } else if (categoryType == CategoryType.INCOME) {
          _ledgerItemIncome.value.category = _result;
        }
      }
    }

    Widget renderBox({
      EdgeInsets margin = const EdgeInsets.only(top: 8.0),
      IconData icon = Icons.category,
      AssetImage? image,
      String text = '',
      bool showDropdown = true,
      bool active = false,
      required void Function() onPressed,
    }) {
      return Container(
        margin: margin,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: Asset.Colors.cloudyBlue,
                width: 1.0,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: image == null
                      ? Icon(
                          icon,
                          color: active
                              ? Theme.of(context).textTheme.displayLarge!.color
                              : Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .color,
                        )
                      : Image(
                          image: image,
                          width: 20,
                          height: 20,
                        ),
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: AutoSizeText(
                            text,
                            style: TextStyle(
                              color: active == true
                                  ? Theme.of(context)
                                      .textTheme
                                      .displayLarge!
                                      .color
                                  : Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        showDropdown
                            ? Icon(
                                Icons.arrow_drop_down,
                                color: Asset.Colors.cloudyBlue,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget renderConsumeView() {
      void onCategoryPressed() {
        showCategory(context, categoryType: CategoryType.CONSUME);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: GestureDetector(
          onTap: () {
            priceTextEditingController1.text =
                '${formatCurrency.format(_ledgerItemConsume.value.price ?? 0.0)}';
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: <Widget>[
              /// PRICE
              Container(
                margin: EdgeInsets.only(top: 44),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Image(
                        image: Asset.Icons.icCoins,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Text(
                      _localization!.trans('PRICE')!,
                      style: TextStyle(
                        color: Asset.Colors.cloudyBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              /// PRICE INPUT
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text('- ',
                          style: TextStyle(
                            fontSize: 28,
                            color: Asset.Colors.carnation,
                          )),
                    ),
                    Expanded(
                      child: Container(
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          onChanged: (String value) {
                            String inputPrice = value.trim();

                            if (inputPrice == "") {
                              _ledgerItemConsume.value.price = 0;
                            } else {
                              _ledgerItemConsume.value.price =
                                  double.parse(value);
                            }
                          },
                          onTap: () {
                            priceTextEditingController1.text =
                                '${_ledgerItemConsume.value.price ?? 0.0}';
                          },
                          onEditingComplete: () {
                            priceTextEditingController1.text =
                                '${formatCurrency.format(_ledgerItemConsume.value.price ?? 0.0)}';
                          },
                          controller: priceTextEditingController1,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                          style: TextStyle(
                            fontSize: 28,
                            color: Asset.Colors.carnation,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// CATEGORY
              _ledgerItemConsume.value.category == null
                  ? renderBox(
                      margin: EdgeInsets.only(top: 52),
                      icon: Icons.category,
                      text: _localization.trans('CATEGORY')!,
                      showDropdown: true,
                      onPressed: onCategoryPressed,
                    )
                  : renderBox(
                      margin: EdgeInsets.only(top: 52),
                      image:
                          iconMaps[_ledgerItemConsume.value.category!.iconId!],
                      text: _ledgerItemConsume.value.category!.label!,
                      showDropdown: true,
                      onPressed: onCategoryPressed,
                      active: true,
                    ),

              /// SELECTED DATE
              _ledgerItemConsume.value.selectedDate == null
                  ? renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.date_range,
                      text: _localization.trans('DATE')!,
                      showDropdown: true,
                      onPressed: onDatePressed,
                    )
                  : renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.date_range,
                      text: DateFormat('yyyy-MM-dd hh:mm a')
                          .format(_ledgerItemConsume.value.selectedDate!)
                          .toLowerCase(),
                      showDropdown: true,
                      onPressed: onDatePressed,
                      active: true,
                    ),

              /// LOCATION
              _ledgerItemConsume.value.address == null
                  ? renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.location_on,
                      text: _localization.trans('LOCATION')!,
                      showDropdown: true,
                      onPressed: onLocationPressed,
                    )
                  : renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.location_on,
                      text: _ledgerItemConsume.value.address!,
                      showDropdown: false,
                      onPressed: onLocationPressed,
                      active: true,
                    ),
              Gallery(
                margin: EdgeInsets.only(top: 26),
                pictures: [Photo(isAddBtn: true)],
                ledgerItem: _ledgerItemConsume.value,
              ),
            ],
          ),
        ),
      );
    }

    Widget renderIncomeView() {
      void onCategoryPressed() {
        showCategory(context, categoryType: CategoryType.INCOME);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: GestureDetector(
          onTap: () {
            priceTextEditingController2.text =
                '${formatCurrency.format(_ledgerItemIncome.value.price ?? 0.0)}';
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(
            children: <Widget>[
              /// PRICE
              Container(
                margin: EdgeInsets.only(top: 44),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 8),
                      child: Image(
                        image: Asset.Icons.icCoins,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Text(
                      _localization!.trans('PRICE')!,
                      style: TextStyle(
                        color: Asset.Colors.cloudyBlue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              /// PRICE INPUT
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Text('+ ',
                          style: TextStyle(
                            fontSize: 28,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          )),
                    ),
                    Expanded(
                      child: Container(
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          onChanged: (String value) {
                            String inputPrice = value.trim();

                            if (inputPrice == "") {
                              _ledgerItemIncome.value.price = 0;
                            } else {
                              _ledgerItemIncome.value.price =
                                  double.parse(value);
                            }
                          },
                          onTap: () {
                            priceTextEditingController2.text =
                                '${_ledgerItemIncome.value.price ?? 0.0}';
                          },
                          onEditingComplete: () {
                            priceTextEditingController2.text =
                                '${formatCurrency.format(_ledgerItemIncome.value.price ?? 0.0)}';
                          },
                          controller: priceTextEditingController2,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                          ),
                          style: TextStyle(
                            fontSize: 28,
                            color: Asset.Colors.mediumGray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// CATEGORY
              _ledgerItemIncome.value.category == null
                  ? renderBox(
                      margin: EdgeInsets.only(top: 52),
                      icon: Icons.category,
                      text: _localization.trans('CATEGORY')!,
                      showDropdown: true,
                      onPressed: onCategoryPressed,
                    )
                  : renderBox(
                      margin: EdgeInsets.only(top: 52),
                      image:
                          iconMaps[_ledgerItemIncome.value.category!.iconId!],
                      text: _ledgerItemIncome.value.category!.label!,
                      showDropdown: true,
                      onPressed: onCategoryPressed,
                      active: true,
                    ),

              /// SELECTED DATE
              _ledgerItemIncome.value.selectedDate == null
                  ? renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.date_range,
                      text: _localization.trans('DATE')!,
                      showDropdown: true,
                      onPressed: () =>
                          onDatePressed(categoryType: CategoryType.INCOME),
                    )
                  : renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.date_range,
                      text: DateFormat('yyyy-MM-dd hh:mm a')
                          .format(_ledgerItemIncome.value.selectedDate!)
                          .toLowerCase(),
                      showDropdown: true,
                      onPressed: () =>
                          onDatePressed(categoryType: CategoryType.INCOME),
                      active: true,
                    ),

              /// LOCATION
              _ledgerItemIncome.value.address == null
                  ? renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.location_on,
                      text: _localization.trans('LOCATION')!,
                      showDropdown: true,
                      onPressed: () =>
                          onLocationPressed(categoryType: CategoryType.INCOME),
                    )
                  : renderBox(
                      margin: EdgeInsets.only(top: 8),
                      icon: Icons.location_on,
                      text: _ledgerItemIncome.value.address!,
                      showDropdown: false,
                      onPressed: () =>
                          onLocationPressed(categoryType: CategoryType.INCOME),
                      active: true,
                    ),
              Gallery(
                margin: EdgeInsets.only(top: 26),
                pictures: [Photo(isAddBtn: true)],
                ledgerItem: _ledgerItemIncome.value,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: renderHeaderClose(
        context: context,
        brightness: Theme.of(context).brightness,
        actions: [
          Container(
            width: 56.0,
            child: RawMaterialButton(
              padding: EdgeInsets.all(0.0),
              shape: CircleBorder(),
              onPressed: onLedgerItemEditPressed,
              child: Icon(
                Icons.add_box,
                color: Theme.of(context).textTheme.displayLarge!.color,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: TabBar(
                unselectedLabelColor: Asset.Colors.paleGray,
                isScrollable: true,
                controller: _tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      color: Theme.of(context).textTheme.displayLarge!.color!,
                      width: 4.0),
                  insets: EdgeInsets.symmetric(horizontal: 8),
                  // insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 40.0),
                ),
                indicatorColor: Theme.of(context).colorScheme.background,
                labelColor: Theme.of(context).textTheme.displayLarge!.color,
                labelStyle: TextStyle(
                  fontSize: 20,
                ),
                labelPadding: EdgeInsets.symmetric(horizontal: 8),
                // indicatorPadding: EdgeInsets.symmetric(horizontal: 10),
                tabs: choices.map((String choice) {
                  return Container(
                    child: Tab(
                      text: _localization!.trans(choice),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: choices.map((String choice) {
                  switch (choice) {
                    case 'CONSUME':
                      return renderConsumeView();
                    case 'INCOME':
                      return renderIncomeView();
                  }
                  return Container();
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
