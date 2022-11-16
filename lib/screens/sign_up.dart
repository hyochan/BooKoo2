import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wecount/utils/navigation.dart';

import 'package:wecount/widgets/edit_text.dart' show EditText;
import 'package:wecount/widgets/button.dart' show Button;
import 'package:wecount/utils/localization.dart' show Localization;
import 'package:wecount/utils/validator.dart' show Validator;
import 'package:wecount/utils/asset.dart' as Asset;

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class SignUp extends HookWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Localization? _localization;

    String? _email;
    String? _password;
    String? _passwordConfirm;
    String? _displayName;
    String? _name;

    var _errorEmail = useState<String?>(null).value;
    var _errorPassword = useState<String?>(null).value;
    var _errorPasswordConfirm = useState<String?>(null).value;
    var _errorDisplayName = useState<String?>(null).value;
    var _errorName = useState<String?>(null).value;

    var _isValidEmail = useState<bool>(false).value;
    var _isValidPassword = useState<bool>(false).value;
    var _isValidDisplayName = useState<bool>(false).value;
    var _isValidName = useState<bool>(false).value;
    var _isRegistering = useState<bool>(false).value;

    void _signUp() async {
      if (_email == null ||
          _password == null ||
          _passwordConfirm == null ||
          _displayName == null ||
          _name == null) {
        return;
      }

      if (!_isValidEmail) {
        _errorEmail = _localization!.trans('NO_VALID_EMAIL');
        return;
      }

      if (!_isValidPassword) {
        _errorPassword = _localization!.trans('PASSWORD_HINT');
        return;
      }

      if (_passwordConfirm != _password) {
        _errorPasswordConfirm = _localization!.trans('PASSWORD_CONFIRM_HINT');
        return;
      }

      if (!_isValidDisplayName) {
        _errorDisplayName = _localization!.trans('DISPLAY_NAME_HINT');
        return;
      }

      if (!_isValidName) {
        _errorName = _localization!.trans('NAME_HINT');
        return;
      }

      _isRegistering = true;

      try {
        final User? user = (await _auth.createUserWithEmailAndPassword(
          email: _email!,
          password: _password!,
        ))
            .user;

        if (user != null) {
          await user.sendEmailVerification();
          await firestore.collection('users').doc(user.uid).set({
            'email': _email,
            'displayName': _displayName,
            'name': _name,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'deletedAt': null,
          });

          user.updateDisplayName(_displayName);

          return navigation.showSingleDialog(
            context,
            title: Text(
              _localization!.trans('SIGN_UP_SUCCESS_TITLE')!,
              style: TextStyle(
                  color: Theme.of(context).dialogTheme.titleTextStyle!.color),
            ),
            content: Text(
              _localization!.trans('SIGN_UP_SUCCESS_CONTENT')!,
              style: TextStyle(
                  color: Theme.of(context).dialogTheme.contentTextStyle!.color),
            ),
            onPress: () {
              _auth.signOut();
              Navigator.of(context).pop();
            },
          );
        }

        throw Error();
      } catch (err) {
        navigation.showSingleDialog(
          context,
          title: Text(
            _localization!.trans('SIGN_UP_ERROR_TITLE')!,
            style: TextStyle(
                color: Theme.of(context).dialogTheme.titleTextStyle!.color),
          ),
          content: Text(
            _localization!.trans('SIGN_UP_ERROR_CONTENT')!,
            style: TextStyle(
                color: Theme.of(context).dialogTheme.contentTextStyle!.color),
          ),
        );
      } finally {
        _isRegistering = false;
      }
    }

    _localization = Localization.of(context);

    Widget renderSignUpText() {
      return Text(
        _localization!.trans('SIGN_UP')!,
        style: TextStyle(
          fontSize: 24.0,
          color: Theme.of(context).textTheme.displayLarge!.color,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    Widget renderEmailField() {
      return EditText(
        key: Key('email'),
        margin: EdgeInsets.only(top: 68.0),
        textInputAction: TextInputAction.next,
        textLabel: _localization!.trans('EMAIL'),
        textHint: _localization!.trans('EMAIL_HINT'),
        textStyle: TextStyle(
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color),
        hasChecked: _isValidEmail,
        onChanged: (String str) {
          if (Validator.instance.validateEmail(str)) {
            _isValidEmail = true;
            _errorEmail = null;
          } else {
            _isValidEmail = false;
          }
          _email = str;
        },
        errorText: _errorEmail,
        onSubmitted: (String str) => _signUp(),
      );
    }

    Widget renderPasswordField() {
      return EditText(
        key: Key('password'),
        margin: EdgeInsets.only(top: 24.0),
        textInputAction: TextInputAction.next,
        textLabel: _localization!.trans('PASSWORD'),
        textHint: _localization!.trans('PASSWORD_HINT'),
        isSecret: true,
        textStyle: TextStyle(
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color),
        hasChecked: _isValidPassword,
        onChanged: (String str) {
          if (Validator.instance.validatePassword(str)) {
            _isValidPassword = true;
            _errorPassword = null;
          } else {
            _isValidPassword = false;
          }
          _password = str;
        },
        errorText: _errorPassword,
        onSubmitted: (String str) => _signUp(),
      );
    }

    Widget renderPasswordConfirmField() {
      return EditText(
        key: Key('password-confirm'),
        margin: EdgeInsets.only(top: 24.0),
        textInputAction: TextInputAction.next,
        textLabel: _localization!.trans('PASSWORD_CONFIRM'),
        textHint: _localization!.trans('PASSWORD_CONFIRM_HINT'),
        isSecret: true,
        textStyle: TextStyle(
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color),
        hasChecked: _passwordConfirm != null &&
            _passwordConfirm != '' &&
            _passwordConfirm == _password,
        onChanged: (String str) {
          _passwordConfirm = str;
          if (str == _password) {
            _errorPasswordConfirm = null;
          }
          ;
        },
        errorText: _errorPasswordConfirm,
        onSubmitted: (String str) => _signUp(),
      );
    }

    Widget renderDisplayNameField() {
      return EditText(
        key: Key('display-name'),
        margin: EdgeInsets.only(top: 24.0),
        textInputAction: TextInputAction.next,
        textLabel: _localization!.trans('DISPLAY_NAME'),
        textHint: _localization!.trans('DISPLAY_NAME_HINT'),
        textStyle: TextStyle(
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color),
        hasChecked: _isValidDisplayName,
        onChanged: (String str) {
          if (Validator.instance.validateNicknameOrName(str)) {
            _isValidDisplayName = true;
            _errorDisplayName = null;
          } else {
            _isValidDisplayName = false;
          }
          _displayName = str;
        },
        errorText: _errorDisplayName,
        onSubmitted: (String str) => _signUp(),
      );
    }

    Widget renderNameField() {
      return EditText(
        key: Key('name'),
        margin: EdgeInsets.only(top: 24.0),
        textInputAction: TextInputAction.next,
        textLabel: _localization!.trans('NAME'),
        textHint: _localization!.trans('NAME_HINT'),
        textStyle: TextStyle(
            color: Theme.of(context).inputDecorationTheme.labelStyle!.color),
        hasChecked: _isValidName,
        onChanged: (String str) {
          if (Validator.instance.validateNicknameOrName(str)) {
            _isValidName = true;
            _errorName = null;
          } else {
            _isValidName = false;
          }
          _name = str;
        },
        errorText: _errorName,
        onSubmitted: (String str) => _signUp(),
      );
    }

    Widget renderSignUpButton() {
      return Button(
        key: Key('button-sign-up'),
        isLoading: _isRegistering,
        onPress: () => _signUp(),
        margin: EdgeInsets.only(top: 36.0, bottom: 48.0),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
        borderColor: Colors.white,
        backgroundColor: Asset.Colors.main,
        text: _localization!.trans('SIGN_UP'),
        width: MediaQuery.of(context).size.width / 2 - 64,
        height: 56.0,
      );
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
        elevation: 0.0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.displayLarge!.color,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding:
                  const EdgeInsets.only(top: 44.0, left: 60.0, right: 60.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    renderSignUpText(),
                    renderEmailField(),
                    renderPasswordField(),
                    renderPasswordConfirmField(),
                    renderDisplayNameField(),
                    renderNameField(),
                    renderSignUpButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
