---
mode: agent
---
Por favor, analise e melhore apenas o conteúdo do arquivo fornecido (não crie novos arquivos). Faça pequenas melhorias e refatorações que deixem o código mais legível, consistente e seguro, mantendo o mesmo comportamento público. Foque em mudanças de baixo risco: renomeações locais, extração de helpers privados, remoção de duplicação simples, melhoria de nomes, ajustes de formatação, pequenas otimizações e melhorias de acessibilidade e internacionalização onde for trivial. Não faça mudanças de arquitetura global, não remova dependências, e não altere contratos públicos (assinaturas de métodos públicos usados externamente).

Requisitos obrigatórios:

Sempre devolva o arquivo completo atualizado pronto para colar no projeto.
No topo, inclua um breve resumo em Português (3–6 linhas) descrevendo todas as mudanças que você fez.
Liste as razões por trás de cada mudança importante (1–2 frases por item).
For cada alteração que afete UI (texto visível), sugira se deveria ir para localização (i18n).
Não introduza códigos não importados: quando adicionar algo, garanta que as importações estejam corretas.
Garantir que recursos (imagens/assets) referenciados permaneçam inalterados, mas com proteção para falhas (onError ou condição).
Priorize clareza de código, nomeação consistente e pequeno reaproveitamento de widgets.
Criterios de segurança (não editar):

Não altere chaves de enum, nomes públicos usados em outras partes da base, nem APIs remotas.
Não remova comentários importantes existentes sem justificativa.
Saída esperada:

O arquivo Dart inteiro atualizado.
Um resumo das mudanças feitas.
Uma lista de sugestões adicionais (não aplicadas) para refatorações maiores ou melhorias de arquitetura.
Comandos sugeridos para validar localmente (analyzer e linter).
Observações para o revisador humano:

Aplique as mudanças em uma branch separada e rode o analyzer/linter.
Se a base usar intl/localization, substitua strings visíveis por chaves apenas se for seguro e trivial.
Use um tom técnico e direto.