// Dart imports:
import 'dart:convert';

dynamic layouts = jsonDecode(jsonEncode([
  {
    'widget': 'listtile',
    'conditions': [
      {'operator': 'eq', 'field': 'estornado', 'value': true}
    ],
    'title': {
      'align': 'center',
      'value': 'Estorno - \$descricaocompoperromaneio nº \$numseqromaneio',
      'fields': ['descricaocompoperromaneio', 'numseqromaneio'],
      'mask': [
        {'field': 'numseqromaneio', 'type': '000000'}
      ],
      'font_size': 16,
      'font_weight': 'bold'
    }
  },
  {
    'widget': 'divider',
    'conditions': [
      {'operator': 'eq', 'field': 'estornado', 'value': true}
    ],
  },
  {
    'widget': 'listtile',
    'conditions': [
      {'operator': 'eq', 'field': 'estornado', 'value': true}
    ],
    'title': {
      'align': 'left',
      'value': 'ESTORNADO - Data',
      'font_size': 14,
      'font_weight': 'bold',
      'color': '#FF0000'
    },
    'subtitle': {
      'align': 'left',
      'value': '\$dataestornoromaneio - \$horaestornoromaneio',
      'fields': ['dataestornoromaneio', 'horaestornoromaneio'],
      'font_size': 14,
      'font_weight': 'normal',
      'color': '#FF0000'
    }
  },
  {
    'widget': 'divider',
    'conditions': [
      {'operator': 'eq', 'field': 'estornado', 'value': true}
    ]
  },
  {
    'widget': 'listtile',
    'conditions': [
      {'operator': 'eq', 'field': 'estornado', 'value': true}
    ],
    'title': {
      'align': 'left',
      'value': 'ESTORNADO - Motivo',
      'font_size': 14,
      'font_weight': 'bold',
      'color': '#FF0000'
    },
    'subtitle': {
      'align': 'left',
      'value': '\$motivoestornoromaneio',
      'fields': ['motivoestornoromaneio'],
      'font_size': 14,
      'font_weight': 'normal',
      'color': '#FF0000'
    }
  },
  {
    'widget': 'listtile',
    'conditions': [
      {'operator': 'eq', 'field': 'estornado', 'value': false}
    ],
    'title': {
      'align': 'center',
      'value': '\$descricaocompoperromaneio nº \$numseqromaneio',
      'fields': ['descricaocompoperromaneio', 'numseqromaneio'],
      'mask': [
        {'field': 'numseqromaneio', 'type': '000000'}
      ],
      'font_size': 16,
      'font_weight': 'bold'
    }
  },
  {'widget': 'divider'},
  {
    'widget': 'listtile',
    'title': {
      'align': 'left',
      'value': 'Data',
      'font_size': 14,
      'font_weight': 'bold'
    },
    'subtitle': {
      'align': 'left',
      'value': '\$datalancromaneio \$horalancromaneio',
      'fields': ['datalancromaneio', 'horalancromaneio'],
      'font_size': 14,
      'font_weight': 'normal'
    }
  },
  {'widget': 'divider'},
  {
    'widget': 'listtile',
    'title': {
      'align': 'left',
      'value': 'Empresa',
      'font_size': 14,
      'font_weight': 'bold'
    },
    'subtitle': {
      'align': 'left',
      'value': '\$empresa.razaosocialempresa',
      'fields': ['empresa.razaosocialempresa'],
      'font_size': 14,
      'font_weight': 'normal'
    }
  },
  {'widget': 'divider'},
  {
    'widget': 'listtile',
    'title': {
      'align': 'left',
      'value': 'Entidade',
      'font_size': 14,
      'font_weight': 'bold'
    },
    'subtitle': {
      'align': 'left',
      'value': '\$cliente.razaosocialcliente',
      'fields': ['cliente.razaosocialcliente'],
      'font_size': 14,
      'font_weight': 'normal'
    }
  },
  {'widget': 'divider'},
  {
    'widget': 'listtile',
    'title': {
      'align': 'left',
      'value': 'Propriedade',
      'font_size': 14,
      'font_weight': 'bold'
    },
    'subtitle': {
      'align': 'left',
      'value':
          '\$cliente.razaosocialidentificadorcliente - \$cliente.enderecocliente - \$cliente.nomecidadecliente - \$cliente.siglaestadocliente',
      'fields': [
        'cliente.razaosocialidentificadorcliente',
        'cliente.enderecocliente',
        'cliente.nomecidadecliente',
        'cliente.siglaestadocliente'
      ],
      'font_size': 14,
      'font_weight': 'normal'
    }
  },
  {'widget': 'divider'},
  {
    'widget': 'listtile',
    'title': {
      'align': 'left',
      'value': 'Produto',
      'font_size': 14,
      'font_weight': 'bold'
    },
    'subtitle': {
      'widget': 'row',
      'main_alignment': 'spaceBetween',
      'widgets': [
        {
          'widget': 'text',
          'value': '\$descricaoproduto',
          'fields': ['descricaoproduto'],
          'font_size': 14,
          'font_weight': 'normal'
        },
        {
          'widget': 'text',
          'value': '\$pesoliquidoromaneio Kg',
          'fields': ['pesoliquidoromaneio'],
          'mask': [
            {'field': 'pesoliquidoromaneio', 'type': ',###'}
          ],
          'font_size': 14,
          'font_weight': 'normal'
        }
      ]
    }
  }
]));
