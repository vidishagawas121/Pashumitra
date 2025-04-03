import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings')),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('language')),
            trailing: _buildLanguageDropdown(context, languageProvider),
          ),
          const Divider(),
          // Add more settings here as needed
        ],
      ),
    );
  }
  
  Widget _buildLanguageDropdown(BuildContext context, LanguageProvider languageProvider) {
    return DropdownButton<String>(
      value: languageProvider.locale.languageCode,
      underline: Container(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          languageProvider.changeLanguage(Locale(newValue));
        }
      },
      items: <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(
          value: 'en',
          child: Text(context.tr('english')),
        ),
        DropdownMenuItem<String>(
          value: 'mr',
          child: Text(context.tr('marathi')),
        ),
      ],
    );
  }
} 