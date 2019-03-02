import 'package:flutter/material.dart';

import '../widgets/edit_text.dart' show EditText;
import '../widgets/button.dart' show Button;
import '../utils/general.dart' show General;
import '../utils/localization.dart' show Localization;
import '../utils/theme.dart' as Theme;
import '../utils/validator.dart' show Validator;

class Agreement extends StatefulWidget {
  Agreement({Key key}) : super(key: key);

  @override
  _AgreementState createState() => new _AgreementState();
}

class _AgreementState extends State<Agreement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.Colors.dusk,
        ),
        title: Text('TERMS & AGREEMENT'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.only(top: 44.0, left: 60.0, right: 60.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
