import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/forgotPassword.dart';
import 'package:messaging_ui/screen_routes.dart';
import 'package:messaging_ui/signUp.dart';
import 'package:messaging_ui/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:messaging_ui/widgets/title.dart';

class SignInPage extends StatefulWidget {
  static const String route = '/signin';

  const SignInPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
  };
  bool isLoading = false;
  Map<String, Object>? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkUserAuthentication();
  }

  void _checkUserAuthentication() async {
    if (await CoreService().isUserAuthenticated) {
      Navigator.pushReplacementNamed(context, ScreenRoutes.chat);
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result = await CoreService().apiService.signIn(
          controllers['username']!.text,
          encodePassword(controllers['password']!.text),
        );

    if (result == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        ScreenRoutes.chat,
        (_) => false,
      );
    } else {
      setState(() {
        errorMessage = result;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _entryField(String title, String type, {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(
            height: 3,
          ),
          TextFormField(
            controller: controllers[type],
            obscureText: isPassword,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Theme.of(context).focusColor,
                filled: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.titleNotEmpty(title);
              }
              return null;
            },
            onFieldSubmitted: (_) {
              _signIn();
            },
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Column(
      children: [
        MouseRegion(
          cursor:
              isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: Column(
            children: [
              GestureDetector(
                onTap: isLoading ? null : _signIn,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: isLoading
                          ? [Colors.grey.shade400, Colors.grey.shade400]
                          : [const Color(0xfffbb448), const Color(0xfff7892b)],
                    ),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        Text(
                          AppLocalizations.of(context)!.login,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  color: const Color.fromARGB(255, 33, 33, 33)),
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 10),
              if (errorMessage != null && errorMessage!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    errorMessage!['code'] != null
                        ? AppLocalizations.of(context)!
                            .authFail(errorMessage!['code']!)
                        : AppLocalizations.of(context)!.authFailNoCode,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 40,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(thickness: 1, color: Colors.grey),
            ),
          ),
          Text(AppLocalizations.of(context)!.or,
              style: TextStyle(color: Colors.grey.shade800)),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(thickness: 1, color: Colors.grey),
            ),
          ),
          const SizedBox(
            width: 40,
          ),
        ],
      ),
    );
  }

  Widget _facebookButton() {
    return Container(
      height: 50,
      width: 250,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: const Text('f',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff2872ba),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: Text(AppLocalizations.of(context)!.facebook,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const RegisterPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 120,
        padding: const EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.doNotHaveAccount,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.register,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: const Color(0xfff79c4f)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(AppLocalizations.of(context)!.email, 'username'),
        _entryField(AppLocalizations.of(context)!.password, 'password',
            isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Form(
      key: _formKey,
      child: SizedBox(
          height: height,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .1),
                  title(),
                  const SizedBox(height: 50),
                  _emailPasswordWidget(),
                  const SizedBox(height: 20),
                  _submitButton(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage()));
                      },
                      child: Text(AppLocalizations.of(context)!.forgotPassword,
                          style: Theme.of(context).textTheme.displaySmall),
                    ),
                  ),
                  _divider(),
                  _facebookButton(),
                  SizedBox(height: height * .055),
                  _createAccountLabel(),
                ],
              ),
            ),
          )),
    ));
  }
}
