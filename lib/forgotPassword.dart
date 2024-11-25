import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/signIn.dart';
import 'package:messaging_ui/widgets/title.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String route = '/forgot_password';

  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'username': TextEditingController(),
  };

  bool isLoading = false;
  bool? success;

  Future<void> _forgotPword() async {
    setState(() {
      isLoading = true;
      success = null;
    });
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await CoreService().apiService.forgotPword(
          controllers['username']!.text,
        );
    setState(() {
      success = result;
    });

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
              _forgotPword();
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
          child: GestureDetector(
            onTap: isLoading ? null : _forgotPword,
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
                    AppLocalizations.of(context)!.resetPword,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: const Color.fromARGB(255, 33, 33, 33)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (success != null && !success!)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              border: Border.all(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              AppLocalizations.of(context)!.error,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.red),
            ),
          ),
        if (success != null && success!)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(color: Colors.blue, width: 1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              AppLocalizations.of(context)!.resetPwordSuccess,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.blue),
            ),
          ),
      ],
    );
  }

  Widget _backToSignIn() {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignInPage()));
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 250,
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.backToSignin,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.deepOrange),
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
                    _backToSignIn(),
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
