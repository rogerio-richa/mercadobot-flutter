import 'package:flutter/material.dart';
import 'package:messaging_ui/core/core_service.dart';
import 'package:messaging_ui/main.dart';
import 'package:messaging_ui/screen_routes.dart';
import 'package:messaging_ui/theme/app_theme.dart';
import 'package:messaging_ui/widgets/top_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String route = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'first_name': TextEditingController(),
    'last_name': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final firstName = await CoreService().apiService.firstName;
    final lastName = await CoreService().apiService.lastName;

    if (firstName != null) {
      controllers['first_name']!.text = firstName;
    }

    if (lastName != null) {
      controllers['last_name']!.text = lastName;
    }
  }

  Future<void> _saveProfile() async {
    await CoreService().apiService.updateProfile(
        controllers['first_name']!.text.trim(),
        controllers['last_name']!.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated)),
    );
  }

  Future<void> _showSignOutConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmSignOut,
              style: Theme.of(context).textTheme.displaySmall),
          content: Text(AppLocalizations.of(context)!.signOutAreYouSure),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(AppLocalizations.of(context)!.signOut,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _signOut();
    }
  }

  Future<void> _signOut() async {
    await CoreService().apiService.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
      ScreenRoutes.signin,
      (_) => false,
    );
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
              _saveProfile();
            },
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _saveProfile,
          child: Container(
            width: MediaQuery.of(context).size.width - 250,
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
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)],
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.save,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: const Color.fromARGB(255, 33, 33, 33)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _signOutButton() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showSignOutConfirmation,
          child: Container(
            width: MediaQuery.of(context).size.width - 250,
            padding: const EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.bottomCenter,
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
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)],
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.signOut,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: const Color.fromARGB(255, 33, 33, 33)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SizedBox(
            height: height,
            child: Stack(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SingleChildScrollView(
                      child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _entryField(AppLocalizations.of(context)!.firstName,
                          'first_name'),
                      _entryField(
                          AppLocalizations.of(context)!.lastName, 'last_name'),
                      const SizedBox(height: 20),
                      _submitButton(),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.darkMode,
                            style: Theme.of(context).textTheme.displaySmall),
                        value: CoreService()
                                .themeService
                                .themeModeNotifier
                                .value ==
                            ThemeMode.dark,
                        onChanged: (bool value) {
                          setState(() {
                            CoreService().themeService.toggleTheme();
                          });
                        },
                        secondary: const Icon(Icons.brightness_6),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.text_increase,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.adjustTextSize,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Slider(
                        value: AppThemes.textScaleFactor,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        label: AppThemes.textScaleFactor.toStringAsFixed(1),
                        onChanged: (double value) {
                          setState(() {
                            AppThemes.textScaleFactor = value;
                            CoreService().apiService.setScaleFactor(value);
                          });
                          myAppKey.currentState?.restartApp();
                        },
                      ),
                      _signOutButton()
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
