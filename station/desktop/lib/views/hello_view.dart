import 'package:flutter/material.dart';
import 'package:family_photo_desktop/l10n/app_localizations.dart';

class HelloView extends StatelessWidget {
  const HelloView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.resetComplete)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.hello),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.currentLanguage(
              Localizations.localeOf(context).languageCode,
            )),
          ],
        ),
      ),
    );
  }
}