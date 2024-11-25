import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/signIn.dart';
import 'package:messaging_ui/widgets/title.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  static const String route = '/register';

  const RegisterPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'username': TextEditingController(),
    'first_name': TextEditingController(),
    'last_name': TextEditingController(),
  };
  bool isLoading = false;
  Map<String, Object>? errorMessage;
  bool? success;

  Future<void> _signUp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      success = null;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result = await CoreService().apiService.signUp(
          controllers['first_name']!.text,
          controllers['last_name']!.text,
          controllers['username']!.text,
        );

    if (result == true) {
      success = true;
    } else {
      setState(() {
        errorMessage = result;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Widget _entryField(String title, String type) {
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
            decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.titleNotEmpty(title);
              }
              if (type == 'username') {
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value.trim().toLowerCase())) {
                  return AppLocalizations.of(context)!.invalidEmailAddress;
                }
              }
              return null;
            },
            onFieldSubmitted: (_) {
              _signUp();
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
            cursor: isLoading
                ? SystemMouseCursors.basic // Default cursor when disabled
                : SystemMouseCursors.click, //
            child: Column(
              children: [
                GestureDetector(
                  onTap: isLoading ? null : _signUp,
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
                            : [
                                const Color(0xfffbb448),
                                const Color(0xfff7892b)
                              ],
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
                          AppLocalizations.of(context)!.register,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  color: const Color.fromARGB(255, 33, 33, 33)),
                        ),
                      ],
                    ),
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
                              .regFail(errorMessage!['code']!)
                          : AppLocalizations.of(context)!.regFailNoCode,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.red),
                    ),
                  ),
                if (success == true)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      border: Border.all(color: Colors.blue, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.regSuccess,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.blue),
                    ),
                  ),
              ],
            )),
      ],
    );
  }

  Widget _signInLabel() {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignInPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.alreadyHaveAccount,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.login,
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
        _entryField(AppLocalizations.of(context)!.firstName, 'first_name'),
        _entryField(AppLocalizations.of(context)!.lastName, 'last_name'),
        _entryField(AppLocalizations.of(context)!.email, 'username'),
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
        child: Stack(
          children: <Widget>[
            Container(
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
                    SizedBox(height: height * .055),
                    _signInLabel(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
