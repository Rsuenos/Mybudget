import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mybudget/core/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final current = themeProv.option;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Tema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              title: const Text('Tema Seçimi'),
              children: [
                ListTile(
                  title: const Text(
                    'Açık (Light)',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: current == AppThemeOption.light
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.light),
                ),
                ListTile(
                  title: const Text(
                    'Koyu (Dark)',
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: current == AppThemeOption.dark
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.dark),
                ),
                ListTile(
                  title: const Text('Renkli'),
                  trailing: current == AppThemeOption.colorful
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.colorful),
                ),
                ListTile(
                  title: const Text('Minimal'),
                  trailing: current == AppThemeOption.minimalist
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.minimalist),
                ),
                ListTile(
                  title: const Text('Neomorfik'),
                  trailing: current == AppThemeOption.neomorphic
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.neomorphic),
                ),
                ListTile(
                  title: const Text('Düz (Flat)'),
                  trailing: current == AppThemeOption.flat
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.flat),
                ),
                ListTile(
                  title: const Text('Material Design'),
                  trailing: current == AppThemeOption.materialDesign
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () =>
                      themeProv.setTheme(AppThemeOption.materialDesign),
                ),
                ListTile(
                  title: const Text('Samsung One UI'),
                  trailing: current == AppThemeOption.samsungOneUI
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.samsungOneUI),
                ),
                ListTile(
                  title: const Text('Theme Bull'),
                  subtitle: const Text('Budget resmi için özel tema'),
                  trailing: current == AppThemeOption.themeBull
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => themeProv.setTheme(AppThemeOption.themeBull),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
