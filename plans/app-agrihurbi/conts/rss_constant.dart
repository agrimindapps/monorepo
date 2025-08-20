class RssFeedModel {
  final String label;
  final String url;
  final bool extractHtml;

  const RssFeedModel({
    required this.label,
    required this.url,
    required this.extractHtml,
  });
}

final List<RssFeedModel> linksRSSAgroConstant = [
  const RssFeedModel(
    label: 'CanalRural',
    url: 'https://www.canalrural.com.br/agricultura/feed/',
    extractHtml: true,
  ),
  const RssFeedModel(
    label: 'Safras e Cifras',
    url: 'https://safrasecifras.com.br/feed/',
    extractHtml: false,
  ),
  // RssFeedModel(
  //   label: 'Agricultura Horizonte',
  //   url: 'https://www.agricolahorizonte.com.br/feed/',
  //   extractHtml: false,
  // ),
  // RssFeedModel(
  //   label: 'Globo Rural',
  //   url: 'https://pox.globo.com/rss/globorural/',
  //   extractHtml: false,
  // ),
  // RssFeedModel(
  //   label: 'A Granja Total',
  //   url: 'https://agranjatotalagro.com.br/feed/',
  //   extractHtml: false,
  // ),
  // RssFeedModel(
  //   label: 'CNN Brasil',
  //   url: 'https://www.cnnbrasil.com.br/tudo-sobre/agronegocio/feed/',
  //   extractHtml: false,
  // ),
  const RssFeedModel(
    label: 'Money Times',
    url: 'https://www.moneytimes.com.br/tag/agronegocio/feed/',
    extractHtml: false,
  ),
  // RssFeedModel(
  //   label: 'Veja',
  //   url: 'https://veja.abril.com.br/noticias-sobre/agronegocio/feed',
  //   extractHtml: false,
  // ),
  const RssFeedModel(
    label: 'Forbes',
    url: 'https://forbes.com.br/forbesagro/feed/',
    extractHtml: true,
  ),
];

final List<RssFeedModel> linksRSSPecuariaConstant = [
  const RssFeedModel(
    label: 'CanalRural',
    url: 'https://www.canalrural.com.br/pecuaria/feed/',
    extractHtml: true,
  ),
  const RssFeedModel(
    label: 'Portal DBO',
    url: 'https://portaldbo.com.br/feed/',
    extractHtml: true,
  ),
  const RssFeedModel(
    label: 'CNN Brasil',
    url: 'https://www.cnnbrasil.com.br/tudo-sobre/pecuaria/feed/',
    extractHtml: true,
  ),
];
