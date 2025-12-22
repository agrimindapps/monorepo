import '../../domain/entities/document_type.dart';
import '../models/legal_document_model.dart';
import '../models/legal_section_model.dart';

/// Data source for Cookies Policy content
class CookiesPolicyDataSource {
  /// Last update date for the cookies policy document
  static const String lastUpdateDate = '2024-12-20';

  /// Cookies Policy raw content
  static const Map<String, dynamic> _cookiesPolicyContent = {
    'sections': [
      {
        'title': 'Sobre Cookies e Tecnologias',
        'content':
            '''O Plantis utiliza tecnologias de armazenamento local e cookies para melhorar sua experiência e garantir o funcionamento adequado do aplicativo.

Este documento explica quais tecnologias utilizamos, como funcionam e como você pode gerenciá-las.''',
      },
      {
        'title': 'O Que São Cookies',
        'content': '''**Cookies** são pequenos arquivos de texto armazenados no seu dispositivo que permitem ao aplicativo:

• Lembrar suas preferências e configurações
• Manter você autenticado entre sessões
• Analisar como você usa o aplicativo
• Melhorar a performance e experiência

**Tecnologias Locais** incluem:
• SharedPreferences (Android/iOS)
• LocalStorage (Web)
• Cache de dados
• Banco de dados local (Drift/SQLite)''',
      },
      {
        'title': 'Cookies Que Utilizamos',
        'content': '''**1. Cookies Estritamente Necessários**
Essenciais para o funcionamento do app:

• **Token de Autenticação**: Mantém você conectado
• **Preferências de Usuário**: Tema, idioma, configurações
• **Estado da Sessão**: Dados temporários durante uso
• **Cache de Imagens**: Performance e economia de dados

**2. Cookies de Funcionalidade**
Melhoram sua experiência:

• **Tutorial Completado**: Não mostrar novamente
• **Filtros e Ordenação**: Lembrar suas preferências
• **Notificações**: Configurações de lembretes
• **Layout**: Grid/Lista, visualização preferida

**3. Cookies Analíticos (Opcionais)**
Nos ajudam a melhorar o app:

• **Firebase Analytics**: Uso anonimizado do app
• **Crashlytics**: Relatórios de erros
• **Performance Monitoring**: Velocidade de carregamento
• **Eventos de Uso**: Features mais utilizadas

**Importante:** Dados analíticos são completamente anonimizados e não identificam você pessoalmente.''',
      },
      {
        'title': 'Cookies de Terceiros',
        'content': '''O Plantis pode utilizar serviços de terceiros que estabelecem seus próprios cookies:

**Firebase (Google)**
• Analytics e métricas de uso
• Autenticação e segurança
• Cloud storage e sincronização
• [Política do Firebase](https://firebase.google.com/support/privacy)

**RevenueCat**
• Gerenciamento de assinaturas
• Validação de compras in-app
• [Política da RevenueCat](https://www.revenuecat.com/privacy)

**Google Sign-In / Apple Sign-In**
• Autenticação social
• Políticas das respectivas plataformas

**Importante:** Não temos controle sobre cookies de terceiros. Consulte as políticas de privacidade deles.''',
      },
      {
        'title': 'Duração dos Cookies',
        'content': '''**Cookies de Sessão:**
• Temporários, deletados ao fechar o app
• Exemplo: Estado de navegação, formulários

**Cookies Persistentes:**
• Permanecem até serem deletados
• Duração típica: 30 dias a 1 ano
• Exemplos: Token de login, preferências

**Você pode limpar todos os cookies através:**
• Configurações do App → Limpar Cache
• Excluir e reinstalar o aplicativo
• Configurações do dispositivo''',
      },
      {
        'title': 'Como Gerenciar Cookies',
        'content': '''**No Aplicativo:**

1. **Desabilitar Analytics**
   • Acesse Configurações → Privacidade
   • Desative "Compartilhar Dados de Uso"
   • Analytics e crash reports serão desabilitados

2. **Limpar Cache Local**
   • Configurações → Armazenamento
   • Limpar cache de imagens
   • Limpar dados temporários

3. **Logout**
   • Remove token de autenticação
   • Mantém dados locais sincronizados

**No Dispositivo (iOS):**
• Ajustes → Geral → Armazenamento do iPhone
• Selecione Plantis → Limpar Dados

**No Dispositivo (Android):**
• Configurações → Apps → Plantis
• Armazenamento → Limpar Cache/Dados

**No Navegador (Web):**
• Configurações do navegador → Privacidade
• Limpar cookies do site plantis.app''',
      },
      {
        'title': 'Cookies Necessários vs Opcionais',
        'content': '''**Não Podemos Funcionar Sem:**
✅ Token de autenticação
✅ Preferências básicas do app
✅ Cache de dados sincronizados
✅ Estado de navegação

**Você Pode Desabilitar:**
❌ Google Analytics
❌ Firebase Crashlytics
❌ Performance Monitoring

**Como Desabilitar:**
Acesse **Configurações → Privacidade → Compartilhamento de Dados**

**Nota:** Desabilitar analytics reduz nossa capacidade de melhorar o app, mas não afeta funcionalidades principais.''',
      },
      {
        'title': 'Segurança dos Dados',
        'content': '''**Proteções Implementadas:**

• **Criptografia**: Todos os dados sensíveis são criptografados
• **HTTPS**: Comunicação segura com servidores
• **Token Seguro**: Autenticação com refresh automático
• **Local Security**: Armazenamento local protegido pelo sistema

**Dados NÃO Armazenados em Cookies:**
❌ Senhas (nunca armazenadas localmente)
❌ Dados de pagamento (gerenciados por Apple/Google)
❌ Informações bancárias
❌ Documentos pessoais''',
      },
      {
        'title': 'Seus Direitos',
        'content': '''Você tem direito a:

✅ **Saber**: Quais cookies utilizamos (descrito acima)
✅ **Acessar**: Ver dados armazenados localmente
✅ **Deletar**: Limpar cookies a qualquer momento
✅ **Optar por Não Participar**: Desabilitar analytics
✅ **Exportar**: Baixar seus dados (Configurações → Exportar)

**Para exercer seus direitos:**
• Use as configurações do app
• Ou entre em contato: privacy@plantis.app''',
      },
      {
        'title': 'Conformidade LGPD/GDPR',
        'content': '''**Lei Geral de Proteção de Dados (LGPD)**
Estamos em conformidade com a LGPD brasileira:

• Consentimento explícito para analytics
• Transparência sobre uso de dados
• Direito de exclusão garantido
• Base legal para processamento

**General Data Protection Regulation (GDPR)**
Para usuários europeus:

• Cookies essenciais baseados em legítimo interesse
• Analytics requer consentimento ativo
• Direito ao esquecimento implementado
• Transferência internacional conforme regulamentos''',
      },
      {
        'title': 'Atualizações Desta Política',
        'content': '''Esta Política de Cookies pode ser atualizada periodicamente para refletir mudanças nas tecnologias que utilizamos.

**Quando Atualizamos:**
• Mudanças em serviços de terceiros
• Novas funcionalidades do app
• Alterações regulatórias
• Melhorias de segurança

**Como Você Será Notificado:**
• Notificação in-app
• Email (para mudanças significativas)
• Data de atualização no topo desta página

**Última Atualização:** $lastUpdateDate''',
      },
      {
        'title': 'Contato',
        'content': '''Para dúvidas sobre esta Política de Cookies:

• **Email**: privacy@plantis.app
• **Assunto**: "Política de Cookies"

Respondemos em até 5 dias úteis.''',
      },
    ],
  };

  /// Get Cookies Policy document model
  LegalDocumentModel getCookiesPolicy() {
    final sections = (_cookiesPolicyContent['sections'] as List)
        .map((s) => LegalSectionModel.fromMap(s as Map<String, dynamic>))
        .toList();

    return LegalDocumentModel(
      id: DocumentType.cookiesPolicy.id,
      type: DocumentType.cookiesPolicy,
      title: DocumentType.cookiesPolicy.displayName,
      lastUpdated: DateTime.parse(lastUpdateDate),
      sections: sections,
    );
  }
}
