import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/premium_feature_card.dart';
import '../../../../../core/widgets/tts_button.dart';
import '../../providers/detalhe_defensivo_notifier.dart';

/// Widget para tab de tecnologia com restrição premium
/// Migrated to Riverpod - uses ConsumerWidget
class TecnologiaTabWidget extends ConsumerWidget {
  final String defensivoName;

  const TecnologiaTabWidget({
    super.key,
    required this.defensivoName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detalheDefensivoProvider);

    return state.when(
      data: (data) => data.isPremium ? _buildPremiumContent(context) : _buildFreeContent(context),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erro ao carregar tecnologia')),
    );
  }

  Widget _buildPremiumContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildApplicationInfoSection(
            context,
            'Tecnologia',
            _getTecnologiaContent(),
            Icons.precision_manufacturing_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            context,
            'Embalagens',
            _getEmbalagensContent(),
            Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            context,
            'Manejo Integrado',
            _getManejoIntegradoContent(),
            Icons.integration_instructions_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            context,
            'Manejo de Resistência',
            _getManejoResistenciaContent(),
            Icons.shield_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            context,
            'Precauções Humanas',
            _getPrecaucoesHumanasContent(),
            Icons.person_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            context,
            'Precauções Ambientais',
            _getPrecaucoesAmbientaisContent(),
            Icons.nature_outlined,
          ),
          const SizedBox(height: 24),
          _buildApplicationInfoSection(
            context,
            'Compatibilidade',
            _getCompatibilidadeContent(),
            Icons.compare_arrows_outlined,
          ),
          const SizedBox(height: 80), // Espaço para bottom navigation
        ],
      ),
    );
  }

  Widget _buildFreeContent(BuildContext context) {
    return PremiumFeatureCard(
      title: 'Conteúdo Premium',
      description: 'Desbloqueie recursos exclusivos e tenha acesso completo a todas as funcionalidades do aplicativo',
      onUpgradePressed: () {
        // TODO: Navigate to subscription page
      },
    );
  }

  Widget _buildApplicationInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    const accentColor = Color(0xFF4CAF50); // Verde padrão do app

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.8),
                  accentColor.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: TTSButton(
                    text: content,
                    title: title,
                    iconSize: 18,
                    iconColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(
              content,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTecnologiaContent() {
    return 'MINISTÉRIO DA AGRICULTURA, PECUÁRIA E ABASTECIMENTO - MAPA\n\n'
        'INSTRUÇÕES DE USO:\n\n'
        '$defensivoName é um herbicida à base do ingrediente ativo Indaziflam, indicado para o controle pré-emergente das plantas daninhas nas culturas da cana-de-açúcar (cana planta e cana soca), café e citros.\n\n'
        'MODO DE APLICAÇÃO:\n'
        'Aplicar via pulverização foliar, preferencialmente no início da manhã ou final da tarde. Utilizar equipamentos de proteção individual adequados.\n\n'
        'NÚMERO, ÉPOCA E INTERVALO DE APLICAÇÃO:\n'
        'Cana-de-açúcar: O produto deve ser pulverizado sobre o solo úmido, bem preparado e livre de torrões, em cana-planta e na cana-soca, na pré-emergência da cultura e das plantas daninhas. Aplicar somente em solo médio e pesado.\n\n'
        'Café: o produto deve ser aplicado em pulverização sobre o solo úmido, nas entre fileiras da cultura, na pré-emergência das plantas daninhas.';
  }

  String _getEmbalagensContent() {
    return 'EMBALAGENS DISPONÍVEIS:\n\n'
        '• Frasco plástico de 1 litro\n'
        '• Bombona plástica de 5 litros\n'
        '• Bombona plástica de 20 litros\n'
        '• Tambor plástico de 200 litros\n\n'
        'DESTINAÇÃO ADEQUADA DAS EMBALAGENS:\n'
        'Após o uso correto deste produto, as embalagens devem ser:\n'
        '• Lavadas três vezes (tríplice lavagem)\n'
        '• Armazenadas em local adequado\n'
        '• Devolvidas ao estabelecimento comercial ou posto de recebimento\n\n'
        'NÃO REUTILIZAR EMBALAGENS VAZIAS.\n'
        'Esta embalagem deve ser reciclada em instalação autorizada.';
  }

  String _getManejoIntegradoContent() {
    return 'MANEJO INTEGRADO DE PRAGAS (MIP):\n\n'
        'O $defensivoName deve ser utilizado dentro de um programa de Manejo Integrado de Pragas, que inclui:\n\n'
        '• Monitoramento regular da cultura\n'
        '• Uso de métodos de controle biológico quando possível\n'
        '• Rotação de produtos com diferentes modos de ação\n'
        '• Preservação de inimigos naturais\n'
        '• Práticas culturais adequadas\n\n'
        'RESISTÊNCIA:\n'
        'Para evitar o desenvolvimento de populações resistentes, recomenda-se:\n'
        '• Não repetir aplicações do mesmo produto\n'
        '• Alternar com produtos de diferentes grupos químicos\n'
        '• Respeitar intervalos de aplicação\n'
        '• Monitorar a eficácia do controle';
  }

  String _getManejoResistenciaContent() {
    return 'ESTRATÉGIAS DE MANEJO DE RESISTÊNCIA:\n\n'
        '1. ROTAÇÃO DE MECANISMOS DE AÇÃO:\n'
        '• Alternar produtos com diferentes modos de ação\n'
        '• Não utilizar o mesmo produto consecutivamente\n'
        '• Respeitar janela de aplicação\n\n'
        '2. MONITORAMENTO:\n'
        '• Avaliar eficácia após aplicações\n'
        '• Identificar sinais de perda de eficiência\n'
        '• Comunicar suspeitas de resistência\n\n'
        '3. BOAS PRÁTICAS:\n'
        '• Usar doses recomendadas\n'
        '• Calibrar equipamentos adequadamente\n'
        '• Aplicar em condições climáticas favoráveis\n'
        '• Manter registros de aplicações\n\n'
        '4. MEDIDAS PREVENTIVAS:\n'
        '• Limpeza de equipamentos\n'
        '• Controle de plantas daninhas resistentes\n'
        '• Integração com métodos não químicos';
  }

  String _getPrecaucoesHumanasContent() {
    return 'PRECAUÇÕES DE USO E ADVERTÊNCIAS:\n\n'
        'EQUIPAMENTOS DE PROTEÇÃO INDIVIDUAL (EPI):\n'
        '• Macacão com mangas compridas\n'
        '• Luvas impermeáveis\n'
        '• Botas impermeáveis\n'
        '• Máscara facial ou respirador\n'
        '• Óculos de proteção\n\n'
        'PRECAUÇÕES DURANTE A APLICAÇÃO:\n'
        '• Não comer, beber ou fumar durante o manuseio\n'
        '• Aplicar somente em ausência de ventos fortes\n'
        '• Evitar aplicação em condições de alta temperatura\n'
        '• Manter pessoas e animais afastados da área tratada\n\n'
        'PRIMEIROS SOCORROS:\n'
        '• Em caso de intoxicação, procurar atendimento médico imediato\n'
        '• Levar a embalagem ou rótulo do produto\n'
        '• Centro de Intoxicações: 0800-722-6001\n\n'
        'SINTOMAS DE INTOXICAÇÃO:\n'
        'Náuseas, vômitos, dor de cabeça, tontura.';
  }

  String _getPrecaucoesAmbientaisContent() {
    return 'PRECAUÇÕES AMBIENTAIS:\n\n'
        'PROTEÇÃO DO MEIO AMBIENTE:\n'
        '• Este produto é tóxico para organismos aquáticos\n'
        '• Não contaminar córregos, lagos, açudes, poços e nascentes\n'
        '• Não aplicar em dias de vento forte\n'
        '• Manter distância mínima de 30 metros de corpos d\'água\n\n'
        'DESTINO ADEQUADO DE RESTOS:\n'
        '• Não descartar em esgotos ou corpos d\'água\n'
        '• Não enterrar embalagens ou restos do produto\n'
        '• Utilizar sobras do produto conforme recomendações\n\n'
        'PROTEÇÃO DA FAUNA:\n'
        '• Produto tóxico para abelhas\n'
        '• Não aplicar durante floração\n'
        '• Evitar deriva para vegetação nativa\n'
        '• Proteger organismos benéficos\n\n'
        'RESTRIÇÕES:\n'
        '• Uso restrito a aplicadores treinados\n'
        '• Venda sob receituário agronômico\n'
        '• Registro no MAPA sob número 12345-67';
  }

  String _getCompatibilidadeContent() {
    return 'COMPATIBILIDADE E MISTURAS:\n\n'
        'COMPATIBILIDADE QUÍMICA:\n'
        'O $defensivoName é compatível com:\n'
        '• Adjuvantes recomendados pelo fabricante\n'
        '• Fertilizantes foliares específicos\n'
        '• Outros herbicidas quando recomendado\n\n'
        'INCOMPATIBILIDADES:\n'
        '• Produtos alcalinos (pH > 8,0)\n'
        '• Fertilizantes com cálcio em alta concentração\n'
        '• Produtos à base de cobre\n'
        '• Óleos minerais ou vegetais\n\n'
        'TESTE DE COMPATIBILIDADE:\n'
        'Antes de fazer misturas:\n'
        '1. Preparar pequena quantidade da mistura\n'
        '2. Observar por 30 minutos\n'
        '3. Verificar formação de precipitados ou separação de fases\n'
        '4. Não utilizar em caso de incompatibilidade\n\n'
        'RECOMENDAÇÕES:\n'
        '• Sempre consultar engenheiro agrônomo\n'
        '• Realizar teste prévio em pequena área\n'
        '• Preparar mistura apenas para uso imediato\n'
        '• Agitar constantemente durante aplicação';
  }
}
