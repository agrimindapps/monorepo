# Documentação do `AppRatingService`

O `AppRatingService` é um serviço que facilita a integração de funcionalidades de avaliação do aplicativo, utilizando a biblioteca `rate_my_app`. Ele permite configurar quando e como solicitar que o usuário avalie o aplicativo, além de gerenciar o estado da avaliação.

## 1. Propósito

O principal objetivo do `AppRatingService` é:
- Gerenciar a lógica para solicitar avaliações dos usuários de forma não intrusiva.
- Abrir a página do aplicativo na loja de aplicativos (Google Play Store ou Apple App Store).
- Controlar a frequência e as condições para exibir o diálogo de avaliação.

## 2. Inicialização

O `AppRatingService` é instanciado fornecendo os IDs da loja de aplicativos e parâmetros de configuração para o comportamento do diálogo de avaliação.

```dart
import 'package:core/src/infrastructure/services/app_rating_service.dart';

final appRatingService = AppRatingService(
  appStoreId: '123456789', // Opcional para iOS
  googlePlayId: 'com.example.yourapp', // Opcional para Android
  minDays: 7, // Mínimo de dias antes de mostrar o diálogo
  minLaunches: 10, // Mínimo de lançamentos antes de mostrar o diálogo
  remindDays: 7, // Dias para esperar se o usuário escolher "Mais Tarde"
  remindLaunches: 10, // Lançamentos para esperar se o usuário escolher "Mais Tarde"
);

// É importante chamar init() antes de usar outros métodos
await appRatingService.init();
```

**Parâmetros do Construtor:**
- `appStoreId`: ID do aplicativo na Apple App Store (obrigatório para iOS).
- `googlePlayId`: ID do pacote do aplicativo na Google Play Store (obrigatório para Android).
- `minDays`: Número mínimo de dias desde a instalação do aplicativo antes que o diálogo de avaliação possa ser exibido.
- `minLaunches`: Número mínimo de vezes que o aplicativo foi iniciado antes que o diálogo de avaliação possa ser exibido.
- `remindDays`: Número de dias para esperar antes de perguntar novamente se o usuário selecionou "Talvez mais tarde".
- `remindLaunches`: Número de lançamentos para esperar antes de perguntar novamente se o usuário selecionou "Talvez mais tarde".

## 3. Funcionalidades Principais

### 3.1. `init()`

Inicializa a instância interna da biblioteca `rate_my_app`. Deve ser chamado antes de qualquer outra operação.

```dart
await appRatingService.init();
```

### 3.2. `showRatingDialog({context})`

Exibe o diálogo de avaliação do aplicativo se as condições configuradas (`minDays`, `minLaunches`, etc.) forem atendidas. Retorna `true` se o diálogo foi exibido, `false` caso contrário.

**Parâmetros:**
- `context`: O `BuildContext` necessário para exibir o diálogo.

Exemplo:

```dart
// Em algum lugar na sua UI, por exemplo, após um certo número de interações ou ao iniciar o app
if (await appRatingService.canShowRatingDialog()) {
  await appRatingService.showRatingDialog(context: context);
}
```

### 3.3. `openAppStore()`

Abre diretamente a página do aplicativo na loja de aplicativos correspondente (Google Play Store ou Apple App Store). Retorna `true` se a loja foi aberta com sucesso, `false` caso contrário.

Exemplo:

```dart
// Por exemplo, em um botão "Avaliar" dentro das configurações do app
ElevatedButton(
  onPressed: () async {
    await appRatingService.openAppStore();
  },
  child: const Text('Avaliar na Loja'),
)
```

### 3.4. `canShowRatingDialog()`

Verifica se as condições para exibir o diálogo de avaliação foram atendidas (dias mínimos, lançamentos mínimos, etc.). Retorna `true` se o diálogo pode ser exibido, `false` caso contrário.

Exemplo:

```dart
bool canShow = await appRatingService.canShowRatingDialog();
if (canShow) {
  print('É hora de pedir uma avaliação!');
}
```

### 3.5. `incrementUsageCount()`

Este método é fornecido pela interface, mas a biblioteca `rate_my_app` gerencia automaticamente a contagem de lançamentos do aplicativo. Chamá-lo manualmente não é geralmente necessário, mas pode ser usado para forçar um incremento se a lógica de "lançamento" for diferente no seu app.

```dart
await appRatingService.incrementUsageCount();
```

### 3.6. `markAsRated()`

Marca o aplicativo como já avaliado pelo usuário, impedindo que o diálogo de avaliação seja exibido novamente. Isso é útil se o usuário avaliar o app por outro meio (ex: diretamente na loja).

```dart
await appRatingService.markAsRated();
```

### 3.7. `hasUserRated()`

Verifica se o usuário já avaliou o aplicativo ou se escolheu nunca mais ser perguntado. Retorna `true` se o usuário já avaliou ou recusou, `false` caso contrário.

```dart
bool rated = await appRatingService.hasUserRated();
if (rated) {
  print('Usuário já avaliou ou não quer mais ser perguntado.');
}
```

### 3.8. `setMinimumUsageCount(int count)`

Este método é parte da interface, mas a configuração de `minLaunches` é definida no construtor do `AppRatingService` e não pode ser alterada em tempo de execução pela biblioteca `rate_my_app`.

### 3.9. `resetRatingPreferences()`

Redefine todas as preferências de avaliação do usuário, fazendo com que o diálogo de avaliação possa ser exibido novamente como se o aplicativo tivesse sido instalado pela primeira vez. Útil para testes ou para permitir que o usuário reconsidere.

```dart
await appRatingService.resetRatingPreferences();
print('Preferências de avaliação resetadas.');
```
