// EXEMPLO DE INTEGRAÇÃO - NÃO USAR EM PRODUÇÃO
// Este arquivo demonstra como integrar a funcionalidade LGPD Export
// em seu aplicativo Flutter existente

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports da feature LGPD Export
import 'di/data_export_dependencies.dart';
import 'presentation/widgets/data_export_tile.dart';
import 'presentation/pages/data_export_page.dart';

// =============================================
// 1. INTEGRAÇÃO NO MAIN.dart
// =============================================

class ExampleMainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Seus providers existentes...
        // ...

        // Adicionar providers do Data Export
        ...DataExportDependencies.providers,
      ],
      child: MaterialApp(
        title: 'App Receituagro',
        home: ExampleSettingsPage(),
        // Suas rotas existentes...
        routes: {
          '/data-export': (context) => DataExportPage(),
          // outras rotas...
        },
      ),
    );
  }
}

// =============================================
// 2. INTEGRAÇÃO NA PÁGINA DE CONFIGURAÇÕES
// =============================================

class ExampleSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
      ),
      body: ListView(
        children: [
          // Suas seções de configurações existentes...
          _buildAccountSection(),
          _buildNotificationSettings(),
          _buildAppearanceSettings(),

          // Seção LGPD Export
          SizedBox(height: 24),
          DataExportSection(),

          // Outras seções...
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Conta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Perfil'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Alterar Senha'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Notificações',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: SwitchListTile(
            secondary: Icon(Icons.notifications_outlined),
            title: Text('Receber Notificações'),
            subtitle: Text('Alertas sobre novos conteúdos'),
            value: true,
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Aparência',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('Tema'),
            subtitle: Text('Claro, escuro ou automático'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Sobre',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Sobre o App'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.privacy_tip_outlined),
                title: Text('Política de Privacidade'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}

// =============================================
// 3. ALTERNATIVA: INTEGRAÇÃO COMO TILE SIMPLES
// =============================================

class SimpleIntegrationExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurações')),
      body: ListView(
        children: [
          // Suas configurações existentes...

          // Adicionar apenas o tile da exportação
          ListTile(
            leading: Icon(Icons.download_outlined),
            title: Text('Exportar Meus Dados'),
            subtitle: Text('Baixar cópia dos dados pessoais'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DataExportPage()),
              );
            },
          ),

          // Resto das configurações...
        ],
      ),
    );
  }
}

// =============================================
// 4. PUBSPEC.yaml DEPENDENCIES (ADICIONAR)
// =============================================

/*
dependencies:
  flutter:
    sdk: flutter

  # Suas dependências existentes...

  # Dependências para LGPD Export
  provider: ^6.0.5
  shared_preferences: ^2.2.0
  path_provider: ^2.1.0
  permission_handler: ^11.0.1

dev_dependencies:
  # Suas dependências de dev existentes...
*/

// =============================================
// 5. ANDROID PERMISSIONS (android/app/src/main/AndroidManifest.xml)
// =============================================

/*
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" android:tools:ignore="ScopedStorage"/>
*/