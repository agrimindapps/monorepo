import { Component, createSignal, createEffect, onMount, Show, For } from 'solid-js';
import { createStore } from 'solid-js/store';
import './DetalheDefensivos.css';

// Types - Migrados do Clean Architecture Flutter
interface DefensivoDetailsModel {
  caracteristicas: Record<string, any>;
  diagnosticos: any[];
  informacoes: Record<string, any>;
}

interface LoadingState {
  dataLoading: boolean;
  ttsOperation: boolean;
  searchOperation: boolean;
  navigationOperation: boolean;
  favoriteOperation: boolean;
}

interface AppState {
  defensivo: DefensivoDetailsModel;
  isLoading: boolean;
  hasError: boolean;
  errorMessage: string;
  isPremiumAd: boolean;
  isFavorite: boolean;
  fontSize: number;
  searchCultura: string;
  diagnosticosFiltered: any[];
  selectedTabIndex: number;
  isDark: boolean;
  loadingStates: LoadingState;
}

// Interfaces abstratas migradas do Flutter
interface ITtsService {
  speak(text: string): Promise<void>;
  stop(): Promise<void>;
  isPlaying: boolean;
}

interface IFavoriteService {
  isFavorite(collection: string, itemId: string): Promise<boolean>;
  toggleFavorite(collection: string, itemId: string): Promise<boolean>;
  removeFavorite(collection: string, itemId: string): Promise<void>;
}

const DetalheDefensivosPage: Component<{ defensivoId?: string }> = (props) => {
  // Estado reativo - migrado do DetalhesDefensivosController
  const [state, setState] = createStore<AppState>({
    defensivo: {
      caracteristicas: {},
      diagnosticos: [],
      informacoes: {},
    },
    isLoading: true,
    hasError: false,
    errorMessage: '',
    isPremiumAd: false,
    isFavorite: false,
    fontSize: 14,
    searchCultura: '',
    diagnosticosFiltered: [],
    selectedTabIndex: 0,
    isDark: false,
    loadingStates: {
      dataLoading: false,
      ttsOperation: false,
      searchOperation: false,
      navigationOperation: false,
      favoriteOperation: false,
    },
  });

  // Timer para debounce da busca
  let searchDebounceTimer: number | undefined;
  const debounceDelay = 300;

  // Mock services - implementações das interfaces
  const ttsService: ITtsService = {
    isPlaying: false,
    async speak(text: string) {
      if ('speechSynthesis' in window) {
        const utterance = new SpeechSynthesisUtterance(text);
        speechSynthesis.speak(utterance);
      }
    },
    async stop() {
      if ('speechSynthesis' in window) {
        speechSynthesis.cancel();
      }
    }
  };

  const favoriteService: IFavoriteService = {
    async isFavorite(collection: string, itemId: string): Promise<boolean> {
      const key = `${collection}_${itemId}`;
      return localStorage.getItem(key) === 'true';
    },
    
    async toggleFavorite(collection: string, itemId: string): Promise<boolean> {
      const key = `${collection}_${itemId}`;
      const current = localStorage.getItem(key) === 'true';
      const newValue = !current;
      localStorage.setItem(key, newValue.toString());
      return newValue;
    },
    
    async removeFavorite(collection: string, itemId: string): Promise<void> {
      const key = `${collection}_${itemId}`;
      localStorage.removeItem(key);
    }
  };

  // Utility functions
  const formatText = (text?: string): string => {
    if (!text) return 'Não disponível';
    return text.trim() || 'Não disponível';
  };

  const isEmpty = (obj: any): boolean => {
    if (!obj) return true;
    if (Array.isArray(obj)) return obj.length === 0;
    if (typeof obj === 'object') return Object.keys(obj).length === 0;
    return false;
  };

  // LoadingStateManager equivalent functions
  const executeOperation = async (
    operationType: keyof LoadingState,
    operation: () => Promise<void>,
    options: {
      loadingMessage?: string;
      successMessage?: string;
      errorMessage?: string;
    } = {}
  ) => {
    setState('loadingStates', operationType, true);
    
    try {
      await operation();
      if (options.successMessage) {
        console.log(options.successMessage);
      }
    } catch (error) {
      console.error(options.errorMessage || 'Erro na operação:', error);
      setState('hasError', true);
      setState('errorMessage', options.errorMessage || 'Erro inesperado');
    } finally {
      setState('loadingStates', operationType, false);
    }
  };

  // Use Cases - migrados do Flutter
  const loadDefensivoData = async () => {
    if (!props.defensivoId) return;

    await executeOperation('dataLoading', async () => {
      setState('isLoading', true);
      setState('hasError', false);

      // Simula carregamento de dados do defensivo
      await new Promise(resolve => setTimeout(resolve, 1500));

      const mockDefensivo: DefensivoDetailsModel = {
        caracteristicas: {
          idReg: props.defensivoId,
          nomeComum: 'Roundup Original',
          nomeTecnico: 'Glifosato',
          fabricante: 'Bayer CropScience',
          ingredienteAtivo: 'Glifosato 480g/L',
          toxico: 'Classe IV - Pouco Tóxico',
          inflamavel: 'Não inflamável',
          corrosivo: 'Não corrosivo',
          classAmbiental: 'Classe III - Produto perigoso',
          classeAgronomica: 'Herbicida sistêmico',
          formulacao: 'Concentrado solúvel (SL)',
          modoAcao: 'Herbicida sistêmico, não seletivo',
          mapa: '1548901',
          vencimento: '24 meses',
        },
        diagnosticos: [
          {
            idReg: 'diag001',
            cultura: 'Soja',
            praga: 'Plantas daninhas',
            dosagem: '3,0 L/ha',
            vazaoTerrestre: '200 L/ha',
            vazaoAerea: 'Não recomendada',
            intervaloAplicacao: 'Aplicação única',
            intervaloSeguranca: '7 dias',
          },
          {
            idReg: 'diag002',
            cultura: 'Milho',
            praga: 'Ervas daninhas',
            dosagem: '2,5 L/ha',
            vazaoTerrestre: '200 L/ha',
            vazaoAerea: 'Não recomendada',
            intervaloAplicacao: 'Aplicação única',
            intervaloSeguranca: '7 dias',
          },
        ],
        informacoes: {
          tecnologia: 'Aplicar preferencialmente nas primeiras horas da manhã ou final da tarde. Evitar aplicação em condições de vento forte. Utilizar equipamentos de proteção individual adequados.',
          observacoes: 'Produto sistêmico de ação total. Não aplicar em culturas não seletivas. Respeitar o período de carência.',
        },
      };

      setState('defensivo', mockDefensivo);
      setState('diagnosticosFiltered', mockDefensivo.diagnosticos);
      setState('isLoading', false);

      // Carrega status do favorito
      const favoriteStatus = await favoriteService.isFavorite('favDefensivos', props.defensivoId);
      setState('isFavorite', favoriteStatus);
    }, {
      loadingMessage: 'Carregando defensivo...',
      errorMessage: 'Erro ao carregar defensivo'
    });
  };

  // Ações do Controller
  const toggleFavorite = async () => {
    if (!hasValidDefensivoData()) return;

    await executeOperation('favoriteOperation', async () => {
      const idReg = state.defensivo.caracteristicas.idReg?.toString() || '';
      const newStatus = await favoriteService.toggleFavorite('favDefensivos', idReg);
      setState('isFavorite', newStatus);
    }, {
      errorMessage: 'Erro ao alterar favorito'
    });
  };

  const toggleTts = (text: string) => {
    if (state.loadingStates.ttsOperation) {
      stopTts();
    } else {
      startTts(text);
    }
  };

  const startTts = async (text: string) => {
    if (!text.trim()) return;

    await executeOperation('ttsOperation', async () => {
      const formattedText = formatText(text).trim();
      await ttsService.speak(formattedText);
    }, {
      loadingMessage: 'Iniciando narração...',
      errorMessage: 'Erro no TTS'
    });
  };

  const stopTts = async () => {
    await executeOperation('ttsOperation', async () => {
      await ttsService.stop();
    });
  };

  const filtraDiagnostico = (text: string) => {
    if (searchDebounceTimer) {
      clearTimeout(searchDebounceTimer);
    }

    if (!text) {
      setState('loadingStates', 'searchOperation', false);
      resetDiagnosticoFilter();
      return;
    }

    setState('loadingStates', 'searchOperation', true);
    setState('searchCultura', text);

    searchDebounceTimer = setTimeout(() => {
      performSearch(text);
    }, debounceDelay);
  };

  const performSearch = async (text: string) => {
    await executeOperation('searchOperation', async () => {
      const filtered = state.defensivo.diagnosticos.filter(diagnostico =>
        diagnostico.cultura?.toLowerCase().includes(text.toLowerCase())
      );
      setState('diagnosticosFiltered', filtered);
    }, {
      successMessage: 'Busca concluída',
      errorMessage: 'Erro na busca'
    });
  };

  const resetDiagnosticoFilter = () => {
    setState('diagnosticosFiltered', state.defensivo.diagnosticos);
    setState('searchCultura', '');
  };

  const navigateToDiagnostic = (data: any) => {
    const diagnosticId = data.idReg;
    if (!diagnosticId?.toString().trim()) {
      console.error('Erro: idReg não encontrado nos dados:', data);
      return;
    }

    executeOperation('navigationOperation', async () => {
      console.log('Navegando para diagnóstico:', diagnosticId);
      // Implementar navegação
    }, {
      loadingMessage: 'Navegando...',
      errorMessage: 'Erro na navegação para diagnóstico'
    });
  };

  const retryLoad = () => {
    setState('hasError', false);
    setState('errorMessage', '');
    loadDefensivoData();
  };

  const hasValidDefensivoData = (): boolean => {
    return !isEmpty(state.defensivo.caracteristicas);
  };

  const showCommentDialog = () => {
    const defensivoName = state.defensivo.caracteristicas.nomeComum || 'Defensivo';
    const comentario = prompt(`Adicionar comentário sobre ${defensivoName}:`, '');
    if (comentario?.trim()) {
      console.log('Comentário adicionado:', comentario);
    }
  };

  // Lifecycle
  onMount(() => {
    if (props.defensivoId) {
      loadDefensivoData();
    }
  });

  return (
    <div class={`detalhe-defensivos-page ${state.isDark ? 'dark' : 'light'}`}>
      <div class="page-container">
        {/* Modern Header */}
        <header class="modern-header">
          <div class="header-content">
            <div class="header-left">
              <button class="back-button" onClick={() => history.back()}>
                <i class="icon-arrow-left"></i>
              </button>
              <div class="header-info">
                <h1 class="header-title">
                  {state.defensivo.caracteristicas.nomeComum || 'Detalhes do Defensivo'}
                </h1>
                <span class="header-subtitle">
                  {state.defensivo.caracteristicas.fabricante || 'Informações completas'}
                </span>
              </div>
            </div>
            
            <Show when={hasValidDefensivoData() && !state.isLoading}>
              <div class="header-actions">
                <button 
                  class={`favorite-button ${state.isFavorite ? 'active' : ''} ${state.loadingStates.favoriteOperation ? 'loading' : ''}`}
                  onClick={toggleFavorite}
                  disabled={state.loadingStates.favoriteOperation}
                >
                  <i class={state.isFavorite ? 'icon-favorite' : 'icon-favorite-border'}></i>
                </button>
              </div>
            </Show>
          </div>
        </header>

        {/* Content Area */}
        <main class="main-content">
          <Show when={state.isLoading}>
            <LoadingState />
          </Show>
          
          <Show when={state.hasError}>
            <ErrorState 
              message={state.errorMessage}
              onRetry={retryLoad}
              onBack={() => history.back()}
            />
          </Show>
          
          <Show when={!state.isLoading && !state.hasError}>
            <div class="content-wrapper">
              <TabsSection 
                selectedTab={state.selectedTabIndex}
                onTabChange={(index) => setState('selectedTabIndex', index)}
                isDark={state.isDark}
              />
              
              <div class="tab-content-container">
                <Show when={state.selectedTabIndex === 0}>
                  <InformacoesTab 
                    caracteristicas={state.defensivo.caracteristicas}
                    isDark={state.isDark}
                  />
                </Show>
                
                <Show when={state.selectedTabIndex === 1}>
                  <DiagnosticoTab 
                    diagnosticos={state.diagnosticosFiltered}
                    searchCultura={state.searchCultura}
                    isSearching={state.loadingStates.searchOperation}
                    onFilter={filtraDiagnostico}
                    onDiagnosticClick={navigateToDiagnostic}
                    isDark={state.isDark}
                  />
                </Show>
                
                <Show when={state.selectedTabIndex === 2}>
                  <AplicacaoTab 
                    informacoes={state.defensivo.informacoes}
                    isTtsSpeaking={state.loadingStates.ttsOperation}
                    onTtsToggle={toggleTts}
                    isDark={state.isDark}
                  />
                </Show>
                
                <Show when={state.selectedTabIndex === 3}>
                  <ComentariosTab isDark={state.isDark} />
                </Show>
              </div>
            </div>
          </Show>
        </main>

        {/* Floating Action Button - Só aparece na aba de comentários */}
        <Show when={!state.isLoading && !state.hasError && hasValidDefensivoData() && state.selectedTabIndex === 3}>
          <button class="floating-action-button" onClick={showCommentDialog}>
            <i class="icon-add"></i>
          </button>
        </Show>
      </div>
    </div>
  );
};

// Componentes auxiliares
const LoadingState: Component = () => (
  <div class="loading-state">
    <div class="loading-container">
      <div class="loading-spinner-container">
        <div class="loading-spinner"></div>
      </div>
      <h3 class="loading-title">Carregando detalhes...</h3>
      <p class="loading-subtitle">Aguarde enquanto buscamos as informações</p>
    </div>
  </div>
);

const ErrorState: Component<{
  message: string;
  onRetry: () => void;
  onBack: () => void;
}> = (props) => (
  <div class="error-state">
    <div class="error-container">
      <div class="error-icon-container">
        <i class="icon-error"></i>
      </div>
      <h3 class="error-title">Erro ao carregar detalhes</h3>
      <p class="error-message">{props.message}</p>
      <div class="error-actions">
        <button class="retry-button" onClick={props.onRetry}>
          <i class="icon-refresh"></i>
          Tentar novamente
        </button>
        <button class="back-button" onClick={props.onBack}>
          <i class="icon-arrow-left"></i>
          Voltar
        </button>
      </div>
    </div>
  </div>
);

// Tab Section Component
const TabsSection: Component<{
  selectedTab: number;
  onTabChange: (index: number) => void;
  isDark: boolean;
}> = (props) => {
  const tabs = [
    { icon: 'icon-info', text: 'Informações' },
    { icon: 'icon-search', text: 'Diagnóstico' },
    { icon: 'icon-apply', text: 'Aplicação' },
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
              <span class="tab-text">{tab.text}</span>
            </button>
          )}
        </For>
      </div>
    </div>
  );
};

// Informações Tab Component
const InformacoesTab: Component<{
  caracteristicas: Record<string, any>;
  isDark: boolean;
}> = (props) => (
  <div class="informacoes-tab">
    <div class="scroll-content">
      <InfoCard caracteristicas={props.caracteristicas} isDark={props.isDark} />
      <ClassificacaoCard caracteristicas={props.caracteristicas} isDark={props.isDark} />
    </div>
  </div>
);

const InfoCard: Component<{
  caracteristicas: Record<string, any>;
  isDark: boolean;
}> = (props) => (
  <div class={`info-card ${props.isDark ? 'dark' : 'light'}`}>
    <div class="card-header">
      <div class="header-content">
        <i class="icon-info"></i>
        <span>Informações Técnicas</span>
      </div>
    </div>
    <div class="card-content">
      <InfoItem
        label="Ingrediente Ativo"
        value={props.caracteristicas.ingredienteAtivo}
        icon="icon-flask"
        isDark={props.isDark}
      />
      <InfoItem
        label="Nome Técnico"
        value={props.caracteristicas.nomeTecnico}
        icon="icon-tag"
        isDark={props.isDark}
      />
      <InfoItem
        label="Toxicologia"
        value={props.caracteristicas.toxico}
        icon="icon-skull"
        isDark={props.isDark}
      />
      <InfoItem
        label="Inflamável"
        value={props.caracteristicas.inflamavel}
        icon="icon-fire"
        isDark={props.isDark}
      />
      <InfoItem
        label="Corrosivo"
        value={props.caracteristicas.corrosivo}
        icon="icon-droplet"
        isDark={props.isDark}
      />
    </div>
  </div>
);

const ClassificacaoCard: Component<{
  caracteristicas: Record<string, any>;
  isDark: boolean;
}> = (props) => (
  <div class={`classificacao-card ${props.isDark ? 'dark' : 'light'}`}>
    <div class="card-header">
      <div class="header-content">
        <i class="icon-classification"></i>
        <span>Classificação</span>
      </div>
    </div>
    <div class="card-content">
      <InfoItem
        label="Classe Ambiental"
        value={props.caracteristicas.classAmbiental}
        icon="icon-leaf"
        isDark={props.isDark}
      />
      <InfoItem
        label="Classe Agronômica"
        value={props.caracteristicas.classeAgronomica}
        icon="icon-tractor"
        isDark={props.isDark}
      />
      <InfoItem
        label="Formulação"
        value={props.caracteristicas.formulacao}
        icon="icon-beaker"
        isDark={props.isDark}
      />
      <InfoItem
        label="Modo de Ação"
        value={props.caracteristicas.modoAcao}
        icon="icon-bolt"
        isDark={props.isDark}
      />
      <InfoItem
        label="Reg. MAPA"
        value={props.caracteristicas.mapa}
        icon="icon-card"
        isDark={props.isDark}
      />
    </div>
  </div>
);

const InfoItem: Component<{
  label: string;
  value?: string;
  icon: string;
  isDark: boolean;
}> = (props) => (
  <div class="info-item">
    <div class="icon-container">
      <i class={props.icon}></i>
    </div>
    <div class="content">
      <span class="label">{props.label}</span>
      <span class="value">{props.value || 'Não disponível'}</span>
    </div>
  </div>
);

// Diagnóstico Tab Component
const DiagnosticoTab: Component<{
  diagnosticos: any[];
  searchCultura: string;
  isSearching: boolean;
  onFilter: (search: string) => void;
  onDiagnosticClick: (diagnostic: any) => void;
  isDark: boolean;
}> = (props) => (
  <div class="diagnostico-tab">
    <div class="search-container">
      <div class="search-wrapper">
        <input
          type="text"
          placeholder="Filtrar por cultura..."
          value={props.searchCultura}
          onInput={(e) => props.onFilter(e.currentTarget.value)}
          class="search-input"
        />
        <Show when={props.isSearching}>
          <div class="search-loading">
            <div class="search-spinner"></div>
          </div>
        </Show>
      </div>
    </div>
    
    <div class="diagnosticos-list">
      <For each={props.diagnosticos}>
        {(diagnostico) => (
          <DiagnosticItem 
            diagnostico={diagnostico}
            onClick={() => props.onDiagnosticClick(diagnostico)}
            isDark={props.isDark}
          />
        )}
      </For>
      
      <Show when={props.diagnosticos.length === 0 && !props.isSearching}>
        <div class="empty-state">
          <i class="icon-search"></i>
          <p>Nenhum diagnóstico encontrado</p>
        </div>
      </Show>
    </div>
  </div>
);

const DiagnosticItem: Component<{
  diagnostico: any;
  onClick: () => void;
  isDark: boolean;
}> = (props) => (
  <div 
    class={`diagnostic-item ${props.isDark ? 'dark' : 'light'}`}
    onClick={props.onClick}
  >
    <div class="diagnostic-header">
      <span class="cultura">{props.diagnostico.cultura}</span>
      <span class="dosagem">{props.diagnostico.dosagem}</span>
    </div>
    <div class="diagnostic-body">
      <span class="praga">{props.diagnostico.praga}</span>
      <div class="technical-info">
        <span>Vazão: {props.diagnostico.vazaoTerrestre}</span>
        <span>Intervalo: {props.diagnostico.intervaloSeguranca}</span>
      </div>
    </div>
  </div>
);

// Aplicação Tab Component
const AplicacaoTab: Component<{
  informacoes: Record<string, any>;
  isTtsSpeaking: boolean;
  onTtsToggle: (text: string) => void;
  isDark: boolean;
}> = (props) => (
  <div class="aplicacao-tab">
    <div class="scroll-content">
      <div class={`application-card ${props.isDark ? 'dark' : 'light'}`}>
        <div class="card-header">
          <div class="header-left">
            <i class="icon-apply"></i>
            <h3>Modo de Aplicação</h3>
          </div>
          <button 
            class={`tts-button ${props.isTtsSpeaking ? 'speaking' : ''}`}
            onClick={() => props.onTtsToggle(props.informacoes.tecnologia || '')}
          >
            <i class={props.isTtsSpeaking ? 'icon-pause' : 'icon-volume-up'}></i>
          </button>
        </div>
        <div class="card-content">
          <p class="technology-text">
            {props.informacoes.tecnologia || 'Não há informações de aplicação disponíveis.'}
          </p>
          
          <Show when={props.informacoes.observacoes}>
            <div class="observations">
              <h4>Observações</h4>
              <p>{props.informacoes.observacoes}</p>
            </div>
          </Show>
        </div>
      </div>
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

export default DetalheDefensivosPage;