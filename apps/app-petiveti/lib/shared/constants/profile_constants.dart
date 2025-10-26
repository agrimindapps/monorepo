import 'package:flutter/material.dart';

/// Constants for the profile page layout, dimensions, and styling
class ProfileConstants {
  ProfileConstants._();
  static const EdgeInsets pageContentPadding = EdgeInsets.all(16.0);
  static const EdgeInsets profileHeaderPadding = EdgeInsets.all(20.0);
  static const EdgeInsets menuTitlePadding = EdgeInsets.only(left: 4, bottom: 8);
  static const EdgeInsets premiumBadgePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 4);
  static const EdgeInsets logoutButtonPadding = EdgeInsets.symmetric(vertical: 12);
  static const double avatarRadius = 40.0;
  static const double avatarImageSize = 80.0;
  static const double aboutIconSize = 64.0;
  static const double profileHeaderBorderRadius = 16.0;
  static const double avatarBorderRadius = 40.0;
  static const double premiumBadgeBorderRadius = 12.0;
  static const double profileNameFontSize = 20.0;
  static const double profileEmailFontSize = 14.0;
  static const double premiumTextFontSize = 12.0;
  static const FontWeight profileNameFontWeight = FontWeight.bold;
  static const FontWeight premiumTextFontWeight = FontWeight.bold;
  static const double avatarBackgroundOpacity = 0.2;
  static const double gradientEndOpacity = 0.8;
  static const double emailTextOpacity = 0.9;
  static const double headerTopSpacing = 32.0;
  static const double sectionSpacing = 24.0;
  static const double logoutTopSpacing = 32.0;
  static const double versionBottomSpacing = 16.0;

  static const double avatarToNameSpacing = 12.0;
  static const double nameToEmailSpacing = 4.0;
  static const double emailToPremiumSpacing = 8.0;
  static const String appName = 'PetiVeti';
  static const String defaultAppVersion = '1.0.0';
  static const String defaultUserName = 'Usuário';
  static const String defaultUserEmail = 'email@exemplo.com';
  static const String financialSectionTitle = 'Financeiro';
  static const String settingsSectionTitle = 'Configurações';
  static const String supportSectionTitle = 'Suporte';
  static const String expensesMenuTitle = 'Controle de Despesas';
  static const String subscriptionMenuTitle = 'Assinaturas';
  static const String notificationsMenuTitle = 'Notificações';
  static const String themeMenuTitle = 'Tema';
  static const String languageMenuTitle = 'Idioma';
  static const String backupMenuTitle = 'Backup e Sincronização';
  static const String helpMenuTitle = 'Central de Ajuda';
  static const String supportMenuTitle = 'Contatar Suporte';
  static const String aboutMenuTitle = 'Sobre o App';
  static const String premiumBadgeText = 'PREMIUM';
  static const String logoutButtonText = 'Sair da Conta';
  static const String logoutDialogTitle = 'Confirmar Logout';
  static const String logoutDialogContent = 'Deseja realmente sair da sua conta?';
  static const String logoutConfirmText = 'Sair';
  static const String cancelButtonText = 'Cancelar';
  static const String okButtonText = 'OK';
  static const String comingSoonContent = 'Esta funcionalidade estará disponível em breve!';
  static const String notificationsSettingsTitle = 'Configurações de Notificação';
  static const String themeSettingsTitle = 'Configurações de Tema';
  static const String languageSettingsTitle = 'Configurações de Idioma';
  static const String backupSettingsTitle = 'Backup e Sincronização';
  static const String helpTitle = 'Central de Ajuda';
  static const String supportContactTitle = 'Contatar Suporte';
  static const String supportContactInfo = 'Email: suporte@petiveti.com\nTelefone: (11) 99999-9999';
  static const String aboutDescription = 'App completo para cuidados veterinários';
  static const String aboutTechnology = 'Desenvolvido com Flutter';
  static const String expensesRoute = '/expenses';
  static const String subscriptionRoute = '/subscription';
  static const String loginRoute = '/login';
  static const String logoutSemanticLabel = 'Sair da conta do usuário';
  static const String logoutSemanticHint = 'Faz logout e retorna para a tela de login';
  static const String profilePhotoSemanticLabel = 'Foto do perfil do usuário';
  static const String defaultAvatarSemanticLabel = 'Avatar padrão do usuário';
  static const String supportContactSemanticLabel = 'Informações de contato do suporte';
  
  static String menuItemSemanticHint(String title) => 'Navegar para $title';
  static String versionText(String version) => 'Versão $version';
}

/// Color constants for the profile page
class ProfileColors {
  ProfileColors._();
  static const Color avatarBackgroundWhite = Colors.white;
  static const Color profileNameColor = Colors.white;
  static const Color profileEmailColor = Colors.white;
  static const Color avatarIconColor = Colors.white;
  static const Color premiumBadgeBackground = Colors.amber;
  static const Color premiumBadgeText = Colors.black;
  static const Color versionTextColor = Colors.grey;
}

/// Icon constants for the profile page
class ProfileIcons {
  ProfileIcons._();
  static const IconData expensesIcon = Icons.receipt_long;
  static const IconData subscriptionIcon = Icons.star;
  static const IconData notificationsIcon = Icons.notifications;
  static const IconData themeIcon = Icons.palette;
  static const IconData languageIcon = Icons.language;
  static const IconData backupIcon = Icons.cloud_sync;
  static const IconData helpIcon = Icons.help;
  static const IconData supportIcon = Icons.support_agent;
  static const IconData aboutIcon = Icons.info;
  static const IconData logoutIcon = Icons.logout;
  static const IconData defaultPersonIcon = Icons.person;
  static const IconData menuArrowIcon = Icons.chevron_right;
  static const IconData appIcon = Icons.pets;
}
