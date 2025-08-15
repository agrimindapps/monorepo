import { Component, createSignal, createEffect, onMount, Show, For } from 'solid-js';
import { createStore } from 'solid-js/store';
import './DetalhePragas.css';

// Types - Migrados do modelo Flutter
interface InfoItem {
  titulo: string;
  descricao: string;
}

interface PragaUnica {
  idReg: string;
  nomeComum: string;
  nomeCientifico: string;
  tipoPraga: string; // '1' = Inseto, '2' = Doença, '3' = Planta
  descricao: string;
  biologia: string;
  sintomas: string;
  ocorrencia: string;
  sinonimias: string;
  nomesVulgares: string;
  imagem: string;
  infoPraga: InfoItem[];
  infoPlanta: InfoItem[];
  infoFlores: InfoItem[];
  infoFrutos: InfoItem[];
  infoFolhas: InfoItem[];
}

interface PragaDetailsModel {
  praga: PragaUnica;
  diagnosticos: any[];
  isFavorite: boolean;
  fontSize: number;
  // Computed properties
  descricaoFormatada: string;
  biologiaFormatada: string;
  sintomasFormatados: string;
  ocorrenciaFormatada: string;
  sinonomiasFormatadas: string;
  nomesVulgaresFormatados: string;
  temSinonimias: boolean;
  temNomesVulgares: boolean;
  temDescricao: boolean;
  temBiologia: boolean;
  temSintomas: boolean;
  temOcorrencia: boolean;
}

interface AppState {
  praga: PragaUnica | null;
  diagnosticos: any[];
  isPragaLoaded: boolean;
  isFavorite: boolean;
  isTtsSpeaking: boolean;
  fontSize: number;
  isDark: boolean;
  isLoading: boolean;
  selectedTabIndex: number;
  searchCultura: string;
  filteredDiagnosticos: any[];
}

const DetalhePragasPage: Component<{ pragaId?: string }> = (props) => {
  // Estado reativo - migrado do controller Flutter
  const [state, setState] = createStore<AppState>({
    praga: null,
    diagnosticos: [],
    isPragaLoaded: false,
    isFavorite: false,
    isTtsSpeaking: false,
    fontSize: 16,
    isDark: false,
    isLoading: true,
    selectedTabIndex: 0,
    searchCultura: '',
    filteredDiagnosticos: [],
  });

  // Computed properties - migradas do PragaDetailsModel
  const pragaDetails = () => {
    if (!state.praga) return null;
    
    const formatText = (text?: string) => {
      if (!text) return '';
      text = text.trim();
      return text.isEmpty || text === '-' ? '' : text;
    };

    return {
      praga: state.praga,
      diagnosticos: state.diagnosticos,
      isFavorite: state.isFavorite,
      fontSize: state.fontSize,
      descricaoFormatada: formatText(state.praga.descricao),
      biologiaFormatada: formatText(state.praga.biologia),
      sintomasFormatados: formatText(state.praga.sintomas),
      ocorrenciaFormatada: formatText(state.praga.ocorrencia),
      sinonomiasFormatadas: formatText(state.praga.sinonimias),
      nomesVulgaresFormatados: formatText(state.praga.nomesVulgares),
      temSinonimias: formatText(state.praga.sinonimias).length > 0,
      temNomesVulgares: formatText(state.praga.nomesVulgares).length > 0,
      temDescricao: formatText(state.praga.descricao).length > 0,
      temBiologia: formatText(state.praga.biologia).length > 0,
      temSintomas: formatText(state.praga.sintomas).length > 0,
      temOcorrencia: formatText(state.praga.ocorrencia).length > 0,
    } as PragaDetailsModel;
  };

  // Funções de carregamento - migradas do controller
  const loadPragaData = async (pragaId: string) => {
    setState('isLoading', true);

    try {
      // Carregamento com retry e error recovery simulado
      const praga = await loadPragaById(pragaId);
      
      if (praga) {
        setState('praga', praga);
        setState('isPragaLoaded', true);
        await loadSecondaryData(pragaId);
      } else {
        throw new Error('Não foi possível carregar dados da praga');
      }
    } catch (error) {
      console.error('Falha no carregamento da praga:', error);
      setState('isPragaLoaded', false);
    } finally {
      setState('isLoading', false);
    }
  };

  const loadSecondaryData = async (pragaId: string) => {
    // Carregamento paralelo de dados secundários
    await Promise.all([
      loadFavoriteStatus(pragaId),
      loadDiagnosticos(pragaId),
    ]);
  };

  // Mock das funções de carregamento
  const loadPragaById = async (id: string): Promise<PragaUnica | null> => {
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return {
      idReg: id,
      nomeComum: 'Lagarta-do-cartucho',
      nomeCientifico: 'Spodoptera frugiperda',
      tipoPraga: '1', // Inseto
      descricao: 'A lagarta-do-cartucho é uma das principais pragas do milho e outras gramíneas. Causa danos significativos principalmente no cartucho das plantas jovens.',
      biologia: 'Inseto holometábolo com ciclo de vida de aproximadamente 30 dias. A fêmea deposita ovos em massas na face inferior das folhas.',
      sintomas: 'Furos circulares nas folhas, presença de excrementos escuros no cartucho, destruição do ponto de crescimento em plantas jovens.',
      ocorrencia: 'Ocorre principalmente durante os meses mais quentes e secos, entre setembro e março.',
      sinonimias: 'Laphygma frugiperda, Prodenia frugiperda',
      nomesVulgares: 'Lagarta-militar, lagarta-do-milho, curuquerê-do-milho',
      imagem: '/assets/images/pragas/spodoptera_frugiperda.jpg',
      infoPraga: [
        { titulo: 'Ordem', descricao: 'Lepidoptera' },
        { titulo: 'Família', descricao: 'Noctuidae' },
        { titulo: 'Hospedeiros', descricao: 'Milho, sorgo, arroz, cana-de-açúcar' },
        { titulo: 'Danos', descricao: 'Desfolha, destruição do cartucho' },
      ],
      infoPlanta: [],
      infoFlores: [],
      infoFrutos: [],
      infoFolhas: [],
    };
  };

  const loadFavoriteStatus = async (id: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 300));
    setState('isFavorite', false); // Mock
  };

  const loadDiagnosticos = async (id: string): Promise<void> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    
    const mockDiagnosticos = [
      {
        idReg: '1',
        cultura: 'Milho',
        nomeDefensivo: 'Dipel WP',
        nomeComum: 'Lagarta-do-cartucho',
        dosagem: '1,0 kg/ha',
        fkIdDefensivo: 'def001',
      },
      {
        idReg: '2',
        cultura: 'Sorgo',
        nomeDefensivo: 'Tracer 240 SC',
        nomeComum: 'Lagarta-do-cartucho',
        dosagem: '0,15 L/ha',
        fkIdDefensivo: 'def002',
      },
    ];
    
    setState('diagnosticos', mockDiagnosticos);
    setState('filteredDiagnosticos', mockDiagnosticos);
  };

  // Funções de ação - migradas do controller
  const toggleFavorite = async () => {
    if (!state.praga) return;
    
    try {
      await new Promise(resolve => setTimeout(resolve, 300));
      setState('isFavorite', !state.isFavorite);
    } catch (error) {
      console.error('Erro ao alternar favorito:', error);
    }
  };

  const handleTtsAction = (text: string) => {
    if (state.isTtsSpeaking) {
      stopTts();
    } else {
      speakText(text);
    }
  };

  const speakText = (text: string) => {
    if (!text.trim()) return;
    
    if ('speechSynthesis' in window) {
      setState('isTtsSpeaking', true);
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.onend = () => setState('isTtsSpeaking', false);
      speechSynthesis.speak(utterance);
    }
  };

  const stopTts = () => {
    if ('speechSynthesis' in window) {
      speechSynthesis.cancel();
      setState('isTtsSpeaking', false);
    }
  };

  const filterDiagnostico = (searchText: string) => {
    setState('searchCultura', searchText);
    
    if (!searchText) {
      setState('filteredDiagnosticos', state.diagnosticos);
    } else {
      const filtered = state.diagnosticos.filter(diagnostico => 
        diagnostico.cultura?.toLowerCase().includes(searchText.toLowerCase())
      );
      setState('filteredDiagnosticos', filtered);
    }
  };

  const showDiagnosticDialog = (diagnosticData: any) => {
    // Simula o DiagnosticApplicationDialog do Flutter
    const dialogContent = `
      Defensivo: ${diagnosticData.nomeDefensivo}
      Cultura: ${diagnosticData.cultura}
      Dosagem: ${diagnosticData.dosagem}
    `;
    
    if (confirm(`Ver mais detalhes?\n\n${dialogContent}`)) {
      // Navegar para detalhes do diagnóstico
      console.log('Navegando para diagnóstico:', diagnosticData.idReg);
    }
  };

  const showCommentDialog = () => {
    const comentario = prompt('Digite seu comentário sobre esta praga:', '');
    if (comentario && comentario.trim()) {
      console.log('Comentário adicionado:', comentario);
    }
  };

  const getPragaTypeDisplayName = (tipoPraga: string) => {
    switch (tipoPraga) {
      case '1': return 'Inseto';
      case '2': return 'Doença';
      case '3': return 'Planta';
      default: return 'Praga';
    }
  };

  // Lifecycle
  onMount(() => {
    if (props.pragaId) {
      loadPragaData(props.pragaId);
    }
  });

  return (
    <div class={`detalhe-pragas-page ${state.isDark ? 'dark' : 'light'}`}>
      <div class="page-container">
        {/* Header - Migrado do _buildModernHeader */}
        <header class="modern-header">
          <div class="header-content">
            <div class="header-left">
              <button class="back-button" onClick={() => history.back()}>
                <i class="icon-arrow-left"></i>
              </button>
              <div class="header-info">
                <h1 class="header-title">
                  {state.praga ? state.praga.nomeComum : 'Detalhes da Praga'}
                </h1>
                <span class="header-subtitle">
                  {state.praga?.nomeCientifico || 'Informações completas'}
                </span>
              </div>
            </div>
            
            <Show when={state.isPragaLoaded}>
              <div class="header-actions">
                <button 
                  class={`favorite-button ${state.isFavorite ? 'active' : ''}`}
                  onClick={toggleFavorite}
                >
                  <i class={state.isFavorite ? 'icon-favorite' : 'icon-favorite-border'}></i>
                </button>
              </div>
            </Show>
          </div>
        </header>

        {/* Content Area */}
        <main class="main-content">
          <Show 
            when={!state.isLoading}
            fallback={<LoadingWidget message="Carregando dados da praga..." />}
          >
            <Show 
              when={state.isPragaLoaded}
              fallback={<ErrorWidget message="Não foi possível carregar os dados da praga" />}
            >
              <div class="tabs-container">
                <TabsSection 
                  selectedTab={state.selectedTabIndex}
                  onTabChange={(index) => setState('selectedTabIndex', index)}
                  isDark={state.isDark}
                />
                
                <div class="tab-content">
                  <Show when={state.selectedTabIndex === 0}>
                    <InformacoesTab 
                      pragaDetails={pragaDetails()}
                      isDark={state.isDark}
                      onTtsAction={handleTtsAction}
                      isTtsSpeaking={state.isTtsSpeaking}
                    />
                  </Show>
                  
                  <Show when={state.selectedTabIndex === 1}>
                    <DiagnosticoTab 
                      diagnosticos={state.filteredDiagnosticos}
                      searchCultura={state.searchCultura}
                      onFilter={filterDiagnostico}
                      onDiagnosticClick={showDiagnosticDialog}
                      isDark={state.isDark}
                    />
                  </Show>
                  
                  <Show when={state.selectedTabIndex === 2}>
                    <ComentariosTab isDark={state.isDark} />
                  </Show>
                </div>
              </div>
            </Show>
          </Show>
        </main>

        {/* Floating Action Button - Só aparece na aba de comentários */}
        <Show when={state.isPragaLoaded && state.selectedTabIndex === 2}>
          <button class="floating-action-button" onClick={showCommentDialog}>
            <i class="icon-add"></i>
          </button>
        </Show>
      </div>
    </div>
  );
};

// Componentes auxiliares
const LoadingWidget: Component<{ message?: string }> = (props) => (
  <div class="loading-widget">
    <div class="loading-spinner"></div>
    <Show when={props.message}>
      <p class="loading-message">{props.message}</p>
    </Show>
  </div>
);

const ErrorWidget: Component<{ message: string; onRetry?: () => void }> = (props) => (
  <div class="error-widget">
    <i class="error-icon icon-error"></i>
    <p class="error-message">{props.message}</p>
    <Show when={props.onRetry}>
      <button class="retry-button" onClick={props.onRetry}>
        Tentar novamente
      </button>
    </Show>
  </div>
);

// Tab Section Component
const TabsSection: Component<{
  selectedTab: number;
  onTabChange: (index: number) => void;
  isDark: boolean;
}> = (props) => {
  const tabs = [
    { icon: 'icon-info', text: 'Info' },
    { icon: 'icon-search', text: 'Diagnóstico' },
    { icon: 'icon-comment', text: 'Comentários' },
  ];

  return (
    <div class="tabs-section">
      <div class={`tab-bar ${props.isDark ? 'dark' : 'light'}`}>
        <For each={tabs}>
          {(tab, index) => (
            <button
              class={`tab ${props.selectedTab === index() ? 'active' : ''}`}
              onClick={() => props.onTabChange(index())}
            >
              <i class={tab.icon}></i>
              <Show when={props.selectedTab === index()}>
                <span class="tab-text">{tab.text}</span>
              </Show>
            </button>
          )}
        </For>
      </div>
    </div>
  );
};

// Informações Tab Component
const InformacoesTab: Component<{
  pragaDetails: PragaDetailsModel | null;
  isDark: boolean;
  onTtsAction: (text: string) => void;
  isTtsSpeaking: boolean;
}> = (props) => {
  if (!props.pragaDetails) return <div>Dados não disponíveis</div>;

  const details = props.pragaDetails;

  return (
    <div class="informacoes-tab">
      <div class="scroll-content">
        {/* Imagem da Praga */}
        <Show when={details.praga.imagem}>
          <PragaImageSection praga={details.praga} isDark={props.isDark} />
        </Show>

        {/* Informações específicas por tipo */}
        <TypeSpecificInfo praga={details.praga} isDark={props.isDark} onTtsAction={props.onTtsAction} />

        {/* Cards de informações condicionais */}
        <Show when={details.temDescricao}>
          <InfoCard
            title="Descrição"
            icon="icon-description"
            content={details.descricaoFormatada}
            isDark={props.isDark}
            isTtsSpeaking={props.isTtsSpeaking}
            onTtsAction={() => props.onTtsAction(details.descricaoFormatada)}
          />
        </Show>

        <Show when={details.temBiologia}>
          <InfoCard
            title="Biologia"
            icon="icon-science"
            content={details.biologiaFormatada}
            isDark={props.isDark}
            isTtsSpeaking={props.isTtsSpeaking}
            onTtsAction={() => props.onTtsAction(details.biologiaFormatada)}
          />
        </Show>

        <Show when={details.temSintomas}>
          <InfoCard
            title="Sintomas"
            icon="icon-medical"
            content={details.sintomasFormatados}
            isDark={props.isDark}
            isTtsSpeaking={props.isTtsSpeaking}
            onTtsAction={() => props.onTtsAction(details.sintomasFormatados)}
          />
        </Show>

        <Show when={details.temOcorrencia}>
          <InfoCard
            title="Ocorrência"
            icon="icon-search"
            content={details.ocorrenciaFormatada}
            isDark={props.isDark}
            isTtsSpeaking={props.isTtsSpeaking}
            onTtsAction={() => props.onTtsAction(details.ocorrenciaFormatada)}
          />
        </Show>

        <Show when={details.temSinonimias}>
          <InfoCard
            title="Sinonímias"
            icon="icon-label"
            content={details.sinonomiasFormatadas}
            isDark={props.isDark}
            isTtsSpeaking={props.isTtsSpeaking}
            onTtsAction={() => props.onTtsAction(details.sinonomiasFormatadas)}
          />
        </Show>

        <Show when={details.temNomesVulgares}>
          <InfoCard
            title="Nomes Vulgares"
            icon="icon-translate"
            content={details.nomesVulgaresFormatados}
            isDark={props.isDark}
            isTtsSpeaking={props.isTtsSpeaking}
            onTtsAction={() => props.onTtsAction(details.nomesVulgaresFormatados)}
          />
        </Show>
      </div>
    </div>
  );
};

const PragaImageSection: Component<{ praga: PragaUnica; isDark: boolean }> = (props) => (
  <div class={`praga-image-section ${props.isDark ? 'dark' : 'light'}`}>
    <div class="image-header">
      <div class="header-content">
        <i class="icon-image"></i>
        <span>Imagem da {props.praga.tipoPraga === '1' ? 'Inseto' : props.praga.tipoPraga === '2' ? 'Doença' : 'Planta'}</span>
      </div>
    </div>
    <div class="image-content">
      <img 
        src={props.praga.imagem}
        alt={props.praga.nomeComum}
        class="praga-image"
        onError={(e) => {
          e.currentTarget.style.display = 'none';
          e.currentTarget.nextElementSibling!.style.display = 'flex';
        }}
      />
      <div class="image-placeholder" style="display: none;">
        <i class="icon-image-not-supported"></i>
        <span>Imagem não disponível</span>
      </div>
    </div>
  </div>
);

const TypeSpecificInfo: Component<{ 
  praga: PragaUnica; 
  isDark: boolean; 
  onTtsAction: (text: string) => void; 
}> = (props) => {
  const { praga } = props;

  return (
    <div class="type-specific-info">
      {/* Informações para Insetos e Doenças */}
      <Show when={praga.tipoPraga === '1' || praga.tipoPraga === '2'}>
        <Show when={praga.infoPraga.length > 0}>
          <FormattedInfoCard
            title={praga.tipoPraga === '1' ? 'Informações do Inseto' : 'Informações da Doença'}
            icon={praga.tipoPraga === '1' ? 'icon-bug' : 'icon-medical'}
            infoList={praga.infoPraga}
            isDark={props.isDark}
            onTtsAction={props.onTtsAction}
          />
        </Show>
      </Show>

      {/* Informações para Plantas */}
      <Show when={praga.tipoPraga === '3'}>
        <Show when={praga.infoPlanta.length > 0}>
          <FormattedInfoCard
            title="Informações da Planta"
            icon="icon-grass"
            infoList={praga.infoPlanta}
            isDark={props.isDark}
            onTtsAction={props.onTtsAction}
          />
        </Show>

        <Show when={praga.infoFlores.length > 0}>
          <FormattedInfoCard
            title="Informações das Flores"
            icon="icon-flower"
            infoList={praga.infoFlores}
            isDark={props.isDark}
            onTtsAction={props.onTtsAction}
          />
        </Show>

        <Show when={praga.infoFrutos.length > 0}>
          <FormattedInfoCard
            title="Informações dos Frutos"
            icon="icon-eco"
            infoList={praga.infoFrutos}
            isDark={props.isDark}
            onTtsAction={props.onTtsAction}
          />
        </Show>

        <Show when={praga.infoFolhas.length > 0}>
          <FormattedInfoCard
            title="Informações das Folhas"
            icon="icon-park"
            infoList={praga.infoFolhas}
            isDark={props.isDark}
            onTtsAction={props.onTtsAction}
          />
        </Show>
      </Show>
    </div>
  );
};

const FormattedInfoCard: Component<{
  title: string;
  icon: string;
  infoList: InfoItem[];
  isDark: boolean;
  onTtsAction: (text: string) => void;
}> = (props) => {
  const formatInfoText = () => {
    return props.infoList
      .map(item => `${item.titulo}\n${item.descricao}`)
      .join('\n\n');
  };

  return (
    <div class={`formatted-info-card ${props.isDark ? 'dark' : 'light'}`}>
      <div class="card-header">
        <div class="header-left">
          <i class={`icon ${props.icon}`}></i>
          <h3>{props.title}</h3>
        </div>
        <button class="tts-button" onClick={() => props.onTtsAction(formatInfoText())}>
          <i class="icon-volume-up"></i>
        </button>
      </div>
      <div class="card-content">
        <For each={props.infoList}>
          {(item, index) => (
            <div class={`info-item ${index() > 0 ? 'with-spacing' : ''}`}>
              <Show when={item.titulo}>
                <div class="info-title">{item.titulo}</div>
              </Show>
              <Show when={item.descricao}>
                <div class="info-description">{item.descricao}</div>
              </Show>
            </div>
          )}
        </For>
      </div>
    </div>
  );
};

const InfoCard: Component<{
  title: string;
  icon: string;
  content: string;
  isDark: boolean;
  isTtsSpeaking: boolean;
  onTtsAction: () => void;
}> = (props) => (
  <div class={`info-card ${props.isDark ? 'dark' : 'light'}`}>
    <div class="card-header">
      <div class="header-left">
        <i class={`icon ${props.icon}`}></i>
        <h3>{props.title}</h3>
      </div>
      <button 
        class={`tts-button ${props.isTtsSpeaking ? 'speaking' : ''}`}
        onClick={props.onTtsAction}
      >
        <i class={props.isTtsSpeaking ? 'icon-stop' : 'icon-volume-up'}></i>
      </button>
    </div>
    <div class="card-content">
      <p class="content-text">{props.content}</p>
    </div>
  </div>
);

// Diagnóstico Tab Component
const DiagnosticoTab: Component<{
  diagnosticos: any[];
  searchCultura: string;
  onFilter: (search: string) => void;
  onDiagnosticClick: (diagnostic: any) => void;
  isDark: boolean;
}> = (props) => (
  <div class="diagnostico-tab">
    <div class="search-container">
      <input
        type="text"
        placeholder="Filtrar por cultura..."
        value={props.searchCultura}
        onInput={(e) => props.onFilter(e.currentTarget.value)}
        class="search-input"
      />
    </div>
    
    <div class="diagnosticos-list">
      <For each={props.diagnosticos}>
        {(diagnostico) => (
          <div 
            class={`diagnostico-item ${props.isDark ? 'dark' : 'light'}`}
            onClick={() => props.onDiagnosticClick(diagnostico)}
          >
            <div class="diagnostico-header">
              <span class="cultura">{diagnostico.cultura}</span>
              <span class="dosagem">{diagnostico.dosagem}</span>
            </div>
            <div class="diagnostico-body">
              <span class="defensivo">{diagnostico.nomeDefensivo}</span>
            </div>
          </div>
        )}
      </For>
      
      <Show when={props.diagnosticos.length === 0}>
        <div class="empty-state">
          <i class="icon-search"></i>
          <p>Nenhum diagnóstico encontrado</p>
        </div>
      </Show>
    </div>
  </div>
);

// Comentários Tab Component
const ComentariosTab: Component<{ isDark: boolean }> = (props) => (
  <div class="comentarios-tab">
    <div class="premium-message">
      <i class="icon-diamond"></i>
      <h3>Comentários Premium</h3>
      <p>Os comentários estão disponíveis para usuários premium.</p>
    </div>
  </div>
);

export default DetalhePragasPage;