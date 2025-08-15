import { Component, createSignal, createEffect, onMount, Show } from 'solid-js';
import { createStore } from 'solid-js/store';
import './DetalheDiagnostico.css';

// Types - Migrados do modelo Flutter
interface DiagnosticoDetailsModel {
  idReg: string;
  nomeDefensivo: string;
  nomePraga: string;
  nomeCientifico: string;
  cultura: string;
  ingredienteAtivo: string;
  toxico: string;
  classAmbiental: string;
  classeAgronomica: string;
  formulacao: string;
  modoAcao: string;
  mapa: string;
  dosagem: string;
  vazaoTerrestre: string;
  vazaoAerea: string;
  intervaloAplicacao: string;
  intervaloSeguranca: string;
  tecnologia: string;
}

interface LoadingState {
  isLoading: boolean;
  isLoadingDiagnostic: boolean;
  isLoadingFavorite: boolean;
  isLoadingPremium: boolean;
  isLoadingTts: boolean;
}

interface AppState {
  diagnostico: DiagnosticoDetailsModel;
  isPremium: boolean;
  isFavorite: boolean;
  isTtsSpeaking: boolean;
  fontSize: number;
  isDark: boolean;
  loading: LoadingState;
}

const DetalheDiagnosticoPage: Component<{ diagnosticoId?: string }> = (props) => {
  // Estado reativo - migrado do controller Flutter
  const [state, setState] = createStore<AppState>({
    diagnostico: {
      idReg: '',
      nomeDefensivo: '',
      nomePraga: '',
      nomeCientifico: '',
      cultura: '',
      ingredienteAtivo: '',
      toxico: '',
      classAmbiental: '',
      classeAgronomica: '',
      formulacao: '',
      modoAcao: '',
      mapa: '',
      dosagem: '',
      vazaoTerrestre: '',
      vazaoAerea: '',
      intervaloAplicacao: '',
      intervaloSeguranca: '',
      tecnologia: '',
    },
    isPremium: false,
    isFavorite: false,
    isTtsSpeaking: false,
    fontSize: 14,
    isDark: false,
    loading: {
      isLoading: false,
      isLoadingDiagnostic: false,
      isLoadingFavorite: false,
      isLoadingPremium: false,
      isLoadingTts: false,
    },
  });

  // Funções de carregamento - migradas do controller
  const loadDiagnosticoData = async (diagnosticoId: string) => {
    setState('loading', 'isLoading', true);
    setState('loading', 'isLoadingDiagnostic', true);
    setState('loading', 'isLoadingFavorite', true);
    setState('loading', 'isLoadingPremium', true);

    try {
      // Simulação do carregamento paralelo do Flutter
      const [diagnosticData, favoriteStatus, premiumStatus] = await Promise.all([
        loadDiagnosticData(diagnosticoId),
        loadFavoriteStatus(diagnosticoId),
        loadPremiumStatus(),
      ]);

      if (diagnosticData) {
        setState('diagnostico', diagnosticData);
      }
      
      setState('isFavorite', favoriteStatus);
      setState('isPremium', premiumStatus);
      
    } catch (error) {
      console.error('Erro ao carregar dados:', error);
    } finally {
      setState('loading', 'isLoading', false);
      setState('loading', 'isLoadingDiagnostic', false);
      setState('loading', 'isLoadingFavorite', false);
      setState('loading', 'isLoadingPremium', false);
    }
  };

  // Mock das funções de carregamento
  const loadDiagnosticData = async (id: string): Promise<DiagnosticoDetailsModel | null> => {
    // Simula carregamento do banco de dados
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    return {
      idReg: id,
      nomeDefensivo: 'Defensivo Exemplo',
      nomePraga: 'Praga Exemplo',
      nomeCientifico: 'Exemplo scientificus',
      cultura: 'Soja',
      ingredienteAtivo: 'Exemplo 100g/L',
      toxico: 'Classe III',
      classAmbiental: 'Classe II',
      classeAgronomica: 'Fungicida',
      formulacao: 'Suspensão concentrada',
      modoAcao: 'Sistêmico',
      mapa: '12345-67',
      dosagem: '1,5 L/ha',
      vazaoTerrestre: '200 L/ha',
      vazaoAerea: '30 L/ha',
      intervaloAplicacao: '14 dias',
      intervaloSeguranca: '30 dias',
      tecnologia: 'Aplicar via pulverização foliar, preferencialmente no início da manhã ou final da tarde. Utilizar equipamentos de proteção individual adequados.',
    };
  };

  const loadFavoriteStatus = async (id: string): Promise<boolean> => {
    await new Promise(resolve => setTimeout(resolve, 500));
    return false; // Mock
  };

  const loadPremiumStatus = async (): Promise<boolean> => {
    await new Promise(resolve => setTimeout(resolve, 300));
    return true; // Mock - assumindo usuário premium para mostrar conteúdo
  };

  // Funções de ação - migradas do controller
  const toggleFavorite = async () => {
    setState('loading', 'isLoadingFavorite', true);
    try {
      // Simula toggle do favorito
      await new Promise(resolve => setTimeout(resolve, 500));
      setState('isFavorite', !state.isFavorite);
    } catch (error) {
      console.error('Erro ao alternar favorito:', error);
    } finally {
      setState('loading', 'isLoadingFavorite', false);
    }
  };

  const compartilhar = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Recomendação de Diagnóstico',
          text: `Defensivo: ${state.diagnostico.nomeDefensivo}\nPraga: ${state.diagnostico.nomePraga}\nCultura: ${state.diagnostico.cultura}`,
        });
      } catch (error) {
        console.error('Erro ao compartilhar:', error);
      }
    } else {
      // Fallback para navegadores que não suportam Web Share API
      navigator.clipboard.writeText(
        `Recomendação de Diagnóstico\n\nDefensivo: ${state.diagnostico.nomeDefensivo}\nPraga: ${state.diagnostico.nomePraga}\nCultura: ${state.diagnostico.cultura}`
      );
    }
  };

  const toggleTts = (text: string) => {
    if (state.isTtsSpeaking) {
      stopTts();
    } else {
      startTts(text);
    }
  };

  const startTts = (text: string) => {
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

  // Lifecycle - equivalente ao onInit do Flutter
  onMount(() => {
    if (props.diagnosticoId) {
      loadDiagnosticoData(props.diagnosticoId);
    }
  });

  return (
    <div class={`detalhe-diagnostico-page ${state.isDark ? 'dark' : 'light'}`}>
      <div class="page-container">
        {/* Header - Migrado do _buildModernHeader */}
        <header class="modern-header">
          <div class="header-content">
            <div class="header-left">
              <button class="back-button" onClick={() => history.back()}>
                <i class="icon-arrow-left"></i>
              </button>
              <div class="header-info">
                <h1 class="header-title">Diagnóstico</h1>
                <span class="header-subtitle">Detalhes do diagnóstico</span>
              </div>
            </div>
            
            <Show when={state.isPremium}>
              <div class="header-actions">
                <button 
                  class={`favorite-button ${state.isFavorite ? 'active' : ''}`}
                  onClick={toggleFavorite}
                  disabled={state.loading.isLoadingFavorite}
                >
                  <i class={state.isFavorite ? 'icon-favorite' : 'icon-favorite-border'}></i>
                </button>
                <button class="share-button" onClick={compartilhar}>
                  <i class="icon-share"></i>
                </button>
              </div>
            </Show>
          </div>
        </header>

        {/* Content Area */}
        <main class="main-content">
          <Show 
            when={!state.loading.isLoading}
            fallback={<div class="loading-indicator">Carregando...</div>}
          >
            <Show 
              when={state.isPremium}
              fallback={<PremiumGate />}
            >
              <div class="content-sections">
                <ImageSection diagnostico={state.diagnostico} isDark={state.isDark} />
                <InfoSection diagnostico={state.diagnostico} isDark={state.isDark} />
                <DiagnosticSection diagnostico={state.diagnostico} isDark={state.isDark} />
                <ApplicationSection 
                  diagnostico={state.diagnostico} 
                  isDark={state.isDark}
                  isTtsSpeaking={state.isTtsSpeaking}
                  onToggleTts={toggleTts}
                />
              </div>
            </Show>
          </Show>
        </main>
      </div>
    </div>
  );
};

// Componente Premium Gate - migrado do _buildPremiumGate
const PremiumGate: Component = () => (
  <div class="premium-gate">
    <div class="premium-card">
      <h2>Detalhes do Diagnóstico</h2>
      <p>Este recurso está disponível apenas para assinantes premium.</p>
      <button class="premium-button" onClick={() => window.location.href = '/assinaturas'}>
        <i class="icon-diamond"></i>
        Desbloquear Agora
      </button>
    </div>
  </div>
);

// Seções migradas dos componentes Flutter
const ImageSection: Component<{ diagnostico: DiagnosticoDetailsModel; isDark: boolean }> = (props) => (
  <section class="image-section">
    <div class={`image-card ${props.isDark ? 'dark' : 'light'}`}>
      <div class="image-container">
        <img 
          src={`/assets/images/bigsize/${props.diagnostico.nomeCientifico}.jpg`}
          alt={props.diagnostico.nomePraga}
          class="praga-image"
          onError={(e) => {
            e.currentTarget.src = '/assets/images/placeholder.png';
          }}
        />
      </div>
      <div class="image-info">
        <h3 class="praga-name">{props.diagnostico.nomePraga}</h3>
        <p class="defensivo-cultura">{props.diagnostico.nomeDefensivo} - {props.diagnostico.cultura}</p>
      </div>
    </div>
  </section>
);

const InfoSection: Component<{ diagnostico: DiagnosticoDetailsModel; isDark: boolean }> = (props) => (
  <section class="info-section">
    <div class={`info-card ${props.isDark ? 'dark' : 'light'}`}>
      <div class="card-header">
        <i class="icon-info"></i>
        <h3>Defensivos</h3>
      </div>
      <div class="card-content">
        <InfoItem label="Ingrediente Ativo" value={props.diagnostico.ingredienteAtivo} icon="icon-flask" />
        <InfoItem label="Toxicologia" value={props.diagnostico.toxico} icon="icon-skull" />
        <InfoItem label="Classe Ambiental" value={props.diagnostico.classAmbiental} icon="icon-leaf" />
        <InfoItem label="Classe Agronômica" value={props.diagnostico.classeAgronomica} icon="icon-tractor" />
        <InfoItem label="Formulação" value={props.diagnostico.formulacao} icon="icon-flask-vial" />
        <InfoItem label="Modo de Ação" value={props.diagnostico.modoAcao} icon="icon-bolt" />
        <InfoItem label="Reg. MAPA" value={props.diagnostico.mapa} icon="icon-card" />
      </div>
    </div>
  </section>
);

const DiagnosticSection: Component<{ diagnostico: DiagnosticoDetailsModel; isDark: boolean }> = (props) => (
  <section class="diagnostic-section">
    <div class={`diagnostic-card ${props.isDark ? 'dark' : 'light'}`}>
      <div class="card-header">
        <i class="icon-clipboard-check"></i>
        <h3>Diagnóstico</h3>
      </div>
      <div class="card-content">
        <InfoItem label="Dosagem" value={props.diagnostico.dosagem} icon="icon-flask" />
        <InfoItem label="Vazão Terrestre" value={props.diagnostico.vazaoTerrestre} icon="icon-tractor" />
        <InfoItem label="Vazão Aérea" value={props.diagnostico.vazaoAerea} icon="icon-plane" />
        <InfoItem label="Intervalo de Aplicação" value={props.diagnostico.intervaloAplicacao} icon="icon-clock" />
        <InfoItem label="Intervalo de Segurança" value={props.diagnostico.intervaloSeguranca} icon="icon-shield" />
      </div>
    </div>
  </section>
);

const ApplicationSection: Component<{ 
  diagnostico: DiagnosticoDetailsModel; 
  isDark: boolean;
  isTtsSpeaking: boolean;
  onToggleTts: (text: string) => void;
}> = (props) => (
  <section class="application-section">
    <div class={`application-card ${props.isDark ? 'dark' : 'light'}`}>
      <div class="card-header">
        <div class="header-left">
          <i class="icon-file"></i>
          <h3>Modo de Aplicação</h3>
        </div>
        <button 
          class={`tts-button ${props.isTtsSpeaking ? 'speaking' : ''}`}
          onClick={() => props.onToggleTts(props.diagnostico.tecnologia)}
        >
          <i class={props.isTtsSpeaking ? 'icon-pause' : 'icon-volume-high'}></i>
        </button>
      </div>
      <div class="card-content">
        <p class="technology-text">
          {props.diagnostico.tecnologia || 'Não há informações'}
        </p>
      </div>
    </div>
  </section>
);

const InfoItem: Component<{ label: string; value: string; icon: string }> = (props) => (
  <div class="info-item">
    <div class="info-icon">
      <i class={props.icon}></i>
    </div>
    <div class="info-content">
      <span class="info-label">{props.label}</span>
      <span class="info-value">{props.value || 'Não há informações'}</span>
    </div>
  </div>
);

export default DetalheDiagnosticoPage;