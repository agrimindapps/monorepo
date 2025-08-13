// Package imports:
import 'package:get/get.dart';

class EspacosTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'pt_BR': {
          // Títulos e navegação
          'espacos.titulo': 'Espaços',
          'espacos.voltar_tooltip': 'Voltar',
          'espacos.adicionar_tooltip': 'Adicionar espaço',

          // Formulários
          'espacos.novo_espaco': 'Novo Espaço',
          'espacos.editar_espaco': 'Editar Espaço',
          'espacos.nome_espaco': 'Nome do espaço',
          'espacos.nome_obrigatorio': 'Nome do espaço *',
          'espacos.nome_hint': 'Ex: Sala de estar, Varanda...',
          'espacos.descricao': 'Descrição (opcional)',
          'espacos.descricao_hint': 'Descreva o espaço...',

          // Botões
          'espacos.salvar': 'Salvar',
          'espacos.cancelar': 'Cancelar',
          'espacos.criar': 'Criar',
          'espacos.editar': 'Editar',
          'espacos.remover': 'Remover',
          'espacos.confirmar': 'Confirmar',

          // Diálogos
          'espacos.confirmar_remocao': 'Confirmar Remoção',
          'espacos.mensagem_remocao':
              'Tem certeza que deseja remover o espaço "@nome"?',

          // Estados vazios
          'espacos.nenhum_espaco': 'Nenhum espaço cadastrado',
          'espacos.descricao_vazio':
              'Comece criando seu primeiro espaço para organizar suas plantas',
          'espacos.criar_primeiro': 'Criar primeiro espaço',

          // Contadores
          'espacos.planta_singular': 'planta',
          'espacos.planta_plural': 'plantas',
          'espacos.nenhuma_planta': 'Nenhuma planta',

          // Validações
          'espacos.campo_obrigatorio': 'Este campo é obrigatório',
          'espacos.nome_obrigatorio_validacao': 'Nome do espaço é obrigatório',
          'espacos.nome_minimo': 'Nome deve ter pelo menos 2 caracteres',
          'espacos.nome_maximo': 'Nome deve ter no máximo 30 caracteres',
          'espacos.nome_duplicado': 'Já existe um espaço com esse nome',
          'espacos.dados_invalidos': 'Dados inválidos',

          // Mensagens de sucesso/erro
          'espacos.criado_sucesso': 'Espaço "@nome" criado com sucesso!',
          'espacos.atualizado_sucesso': 'Espaço atualizado com sucesso!',
          'espacos.removido_sucesso': 'Espaço "@nome" removido com sucesso!',
          'espacos.erro_criar': 'Erro ao criar espaço: @erro',
          'espacos.erro_atualizar': 'Erro ao atualizar espaço: @erro',
          'espacos.erro_remover': 'Erro ao remover espaço: @erro',
          'espacos.erro_carregar': 'Erro ao carregar espaços: @erro',
          'espacos.plantas_no_espaco':
              'Este espaço possui @quantidade planta(s). Remova as plantas primeiro.',

          // Títulos de feedback
          'espacos.atencao': 'Atenção',
          'espacos.sucesso': 'Sucesso',
          'espacos.erro': 'Erro',

          // Tipos de espaços pré-definidos
          'espacos.tipos.jardim': 'Jardim',
          'espacos.tipos.sala': 'Sala',
          'espacos.tipos.quarto': 'Quarto',
          'espacos.tipos.cozinha': 'Cozinha',
          'espacos.tipos.varanda': 'Varanda',
          'espacos.tipos.banheiro': 'Banheiro',
          'espacos.tipos.escritorio': 'Escritório',
          'espacos.tipos.garagem': 'Garagem',

          // Espaços padrão configuráveis
          'espacos.padrao.sala_estar.nome': 'Sala de estar',
          'espacos.padrao.sala_estar.descricao': 'Ambiente principal da casa',
          'espacos.padrao.quarto.nome': 'Quarto',
          'espacos.padrao.quarto.descricao': 'Dormitório',
          'espacos.padrao.cozinha.nome': 'Cozinha',
          'espacos.padrao.cozinha.descricao': 'Área de preparo de alimentos',
          'espacos.padrao.varanda.nome': 'Varanda',
          'espacos.padrao.varanda.descricao': 'Área externa coberta',
          'espacos.padrao.jardim.nome': 'Jardim',
          'espacos.padrao.jardim.descricao': 'Área externa com terra',
        },
        'en_US': {
          // Titles and navigation
          'espacos.titulo': 'Spaces',
          'espacos.voltar_tooltip': 'Back',
          'espacos.adicionar_tooltip': 'Add space',

          // Forms
          'espacos.novo_espaco': 'New Space',
          'espacos.editar_espaco': 'Edit Space',
          'espacos.nome_espaco': 'Space name',
          'espacos.nome_obrigatorio': 'Space name *',
          'espacos.nome_hint': 'Ex: Living room, Balcony...',
          'espacos.descricao': 'Description (optional)',
          'espacos.descricao_hint': 'Describe the space...',

          // Buttons
          'espacos.salvar': 'Save',
          'espacos.cancelar': 'Cancel',
          'espacos.criar': 'Create',
          'espacos.editar': 'Edit',
          'espacos.remover': 'Remove',
          'espacos.confirmar': 'Confirm',

          // Dialogs
          'espacos.confirmar_remocao': 'Confirm Removal',
          'espacos.mensagem_remocao':
              'Are you sure you want to remove the space "@nome"?',

          // Empty states
          'espacos.nenhum_espaco': 'No spaces registered',
          'espacos.descricao_vazio':
              'Start by creating your first space to organize your plants',
          'espacos.criar_primeiro': 'Create first space',

          // Counters
          'espacos.planta_singular': 'plant',
          'espacos.planta_plural': 'plants',
          'espacos.nenhuma_planta': 'No plants',

          // Validations
          'espacos.campo_obrigatorio': 'This field is required',
          'espacos.nome_obrigatorio_validacao': 'Space name is required',
          'espacos.nome_minimo': 'Name must have at least 2 characters',
          'espacos.nome_maximo': 'Name must have at most 30 characters',
          'espacos.nome_duplicado': 'A space with this name already exists',
          'espacos.dados_invalidos': 'Invalid data',

          // Success/error messages
          'espacos.criado_sucesso': 'Space "@nome" created successfully!',
          'espacos.atualizado_sucesso': 'Space updated successfully!',
          'espacos.removido_sucesso': 'Space "@nome" removed successfully!',
          'espacos.erro_criar': 'Error creating space: @erro',
          'espacos.erro_atualizar': 'Error updating space: @erro',
          'espacos.erro_remover': 'Error removing space: @erro',
          'espacos.erro_carregar': 'Error loading spaces: @erro',
          'espacos.plantas_no_espaco':
              'This space has @quantidade plant(s). Remove the plants first.',

          // Feedback titles
          'espacos.atencao': 'Warning',
          'espacos.sucesso': 'Success',
          'espacos.erro': 'Error',

          // Pre-defined space types
          'espacos.tipos.jardim': 'Garden',
          'espacos.tipos.sala': 'Living Room',
          'espacos.tipos.quarto': 'Bedroom',
          'espacos.tipos.cozinha': 'Kitchen',
          'espacos.tipos.varanda': 'Balcony',
          'espacos.tipos.banheiro': 'Bathroom',
          'espacos.tipos.escritorio': 'Office',
          'espacos.tipos.garagem': 'Garage',

          // Configurable default spaces
          'espacos.padrao.sala_estar.nome': 'Living Room',
          'espacos.padrao.sala_estar.descricao': 'Main room of the house',
          'espacos.padrao.quarto.nome': 'Bedroom',
          'espacos.padrao.quarto.descricao': 'Sleeping room',
          'espacos.padrao.cozinha.nome': 'Kitchen',
          'espacos.padrao.cozinha.descricao': 'Food preparation area',
          'espacos.padrao.varanda.nome': 'Balcony',
          'espacos.padrao.varanda.descricao': 'Covered outdoor area',
          'espacos.padrao.jardim.nome': 'Garden',
          'espacos.padrao.jardim.descricao': 'Outdoor area with soil',
        },
      };
}
