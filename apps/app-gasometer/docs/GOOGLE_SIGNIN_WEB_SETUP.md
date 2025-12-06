# Configuração do Google Sign-In para Web - GasOMeter

## Problema Identificado

```
DartError: Assertion failed
google_sign_in_web.dart:144
appClientId != null
"ClientID not set. Either set it on a <meta name="google-signin-client_id" content="CLIENT_ID" /> tag, 
or pass clientId when initializing GoogleSignIn"
```

## Causa

O Google Sign-In para Web requer que o **Client ID** seja configurado no arquivo `web/index.html`. Este Client ID é específico para a plataforma Web e precisa ser obtido do Firebase Console.

## Solução

### Passo 1: Habilitar Google Sign-In no Firebase Console

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Selecione o projeto **gasometer-12c83**
3. No menu lateral, vá em **Authentication** > **Sign-in method**
4. Clique em **Google** na lista de provedores
5. Habilite o provedor Google se ainda não estiver habilitado
6. Clique em **Save**

### Passo 2: Obter o Web Client ID

Após habilitar o Google Sign-In, você verá uma seção chamada **Web SDK configuration** com:

- **Web client ID**: `68399647443-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com`
- **Web client secret**: `XXXXXXXXXXXXXXXXXXXXX`

Copie o **Web client ID** completo.

### Passo 3: Atualizar o arquivo web/index.html

O arquivo `apps/app-gasometer/web/index.html` já foi atualizado com um placeholder. Substitua:

```html
<meta name="google-signin-client_id" content="68399647443-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com">
```

Por:

```html
<meta name="google-signin-client_id" content="SEU_CLIENT_ID_REAL_AQUI">
```

### Passo 4: Configurar Origens Autorizadas

Ainda no Firebase Console, na configuração do Google Sign-In:

1. Role até a seção **Authorized domains**
2. Certifique-se de que os seguintes domínios estejam autorizados:
   - `localhost` (para desenvolvimento)
   - `gasometer.agrimind.com.br` (para produção)

Se necessário, adicione-os clicando em **Add domain**.

### Passo 5: Atualizar o google-services.json (Opcional)

Se você também precisa do Google Sign-In no Android, baixe o `google-services.json` atualizado:

1. No Firebase Console, vá em **Project Settings** (ícone de engrenagem)
2. Role até **Your apps**
3. Selecione o app Android
4. Clique em **Download google-services.json**
5. Substitua o arquivo em `apps/app-gasometer/android/app/google-services.json`

## Verificação

Após seguir os passos acima:

1. Limpe o build: `flutter clean`
2. Reconstrua o app: `flutter run -d chrome`
3. Tente fazer login com Google
4. O erro não deve mais aparecer

## Notas Importantes

- **Nunca** commite o Client ID real em repositórios públicos
- Para CI/CD, use variáveis de ambiente ou secrets
- O Client ID da Web é diferente dos Client IDs do Android/iOS
- Cada plataforma (Web, Android, iOS) tem seu próprio Client ID

## Estrutura Atual do Projeto

```
Project: gasometer-12c83
Project Number: 68399647443

Apps configurados:
✓ Web (appId: 1:68399647443:web:6228c3a94f180e60916226)
✓ Android (appId: 1:68399647443:android:e8d019f4262dbc89916226)
✓ iOS (appId: 1:68399647443:ios:d08b01dbe452f2b3916226)
```

## Referências

- [Google Sign-In for Flutter Web](https://pub.dev/packages/google_sign_in_web)
- [Firebase Authentication - Google](https://firebase.google.com/docs/auth/web/google-signin)
- [FlutterFire - Google Sign-In](https://firebase.flutter.dev/docs/auth/social#google)
