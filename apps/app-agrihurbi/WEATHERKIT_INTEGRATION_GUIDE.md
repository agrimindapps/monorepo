# 🌤️ WeatherKit REST API - Guia de Integração

## 📋 Visão Geral

A **WeatherKit REST API** da Apple fornece dados meteorológicos precisos e em tempo real para qualquer plataforma (iOS, Android, Web, Backend) via HTTP REST.

**Vantagens:**
- ✅ **Multiplataforma**: Funciona em qualquer linguagem/plataforma
- ✅ **Dados confiáveis**: Qualidade Apple com dados do Dark Sky
- ✅ **Previsões precisas**: Até 10 dias de previsão
- ✅ **Tier gratuito generoso**: 500.000 chamadas/mês
- ✅ **Sem SDK necessário**: REST API puro

---

## 🔑 Requisitos

### 1. Apple Developer Account
- **Obrigatório**: Apple Developer Program ($99/ano)
- Acesse: [developer.apple.com](https://developer.apple.com)

### 2. Configuração no Portal

#### Passo 1: Criar Service ID
1. Acesse [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources)
2. Services IDs → Criar novo
3. Nome: `AgriHurbi WeatherKit Service`
4. Identifier: `br.com.agrimind.agrihurbi.weatherkit`
5. ✅ Ativar WeatherKit

#### Passo 2: Criar API Key
1. Keys → Criar nova chave
2. Nome: `WeatherKit API Key`
3. ✅ Habilitar WeatherKit
4. Registrar
5. **Baixar arquivo `.p8`** (salvar com segurança!)
6. Anotar:
   - **Key ID** (ex: ABC123DEF4)
   - **Team ID** (ex: XYZ987654)

---

## 🌐 Endpoints da API

### Base URL
```
https://weatherkit.apple.com/api/v1
```

### 1. Obter Dados Meteorológicos
```http
GET /weather/{language}/{latitude}/{longitude}
```

**Parâmetros:**
- `language`: Código do idioma (ex: `pt-BR`, `en-US`)
- `latitude`: Latitude em graus decimais
- `longitude`: Longitude em graus decimais

**Query Parameters:**
- `dataSets` (obrigatório): Conjuntos de dados desejados
  - `currentWeather`: Condições atuais
  - `forecastHourly`: Previsão horária (próximas 240h)
  - `forecastDaily`: Previsão diária (próximos 10 dias)
  - `weatherAlerts`: Alertas meteorológicos
  - Pode combinar: `currentWeather,forecastDaily,forecastHourly`

- `timezone`: Fuso horário IANA (ex: `America/Sao_Paulo`)
- `currentAsOf`: Timestamp ISO 8601 para dados atuais
- `dailyStart`: Data início previsão diária (ISO 8601)
- `dailyEnd`: Data fim previsão diária (ISO 8601)
- `hourlyStart`: Data início previsão horária (ISO 8601)
- `hourlyEnd`: Data fim previsão horária (ISO 8601)

**Exemplo:**
```http
GET /weather/pt-BR/-23.550520/-46.633308?dataSets=currentWeather,forecastDaily&timezone=America/Sao_Paulo
```

### 2. Verificar Disponibilidade
```http
GET /availability/{latitude}/{longitude}
```

Retorna quais conjuntos de dados estão disponíveis para a localização.

---

## 🔐 Autenticação JWT

### Geração de Token

A API requer um **JSON Web Token (JWT)** assinado com ES256 (ECDSA SHA-256).

#### Header JWT
```json
{
  "alg": "ES256",
  "kid": "{KEY_ID}",
  "id": "{TEAM_ID}.{SERVICE_ID}"
}
```

#### Payload JWT
```json
{
  "iss": "{TEAM_ID}",
  "iat": 1705410000,
  "exp": 1705413600,
  "sub": "{SERVICE_ID}"
}
```

**Campos:**
- `alg`: Algoritmo (sempre `ES256`)
- `kid`: Key ID da chave .p8
- `id`: `{TEAM_ID}.{SERVICE_ID}`
- `iss`: Team ID (issuer)
- `iat`: Timestamp de criação (issued at)
- `exp`: Timestamp de expiração (máx 1 hora)
- `sub`: Service ID (subject)

### Exemplo Dart/Flutter

```dart
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

String generateWeatherKitToken({
  required String teamId,
  required String serviceId,
  required String keyId,
  required String privateKey,
}) {
  final jwt = JWT(
    {
      'iss': teamId,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(minutes: 50)).millisecondsSinceEpoch ~/ 1000,
      'sub': serviceId,
    },
    header: {
      'alg': 'ES256',
      'kid': keyId,
      'id': '$teamId.$serviceId',
    },
  );

  return jwt.sign(
    ECPrivateKey(privateKey),
    algorithm: JWTAlgorithm.ES256,
  );
}
```

### Uso no Request

```http
Authorization: Bearer {JWT_TOKEN}
```

---

## 📊 Estrutura de Dados

### Current Weather (Condições Atuais)

```json
{
  "currentWeather": {
    "name": "CurrentWeather",
    "metadata": {
      "attributionURL": "https://...",
      "expireTime": "2024-01-16T11:00:00Z",
      "latitude": -23.550520,
      "longitude": -46.633308,
      "readTime": "2024-01-16T10:30:00Z",
      "reportedTime": "2024-01-16T10:00:00Z",
      "units": "m",
      "version": 1
    },
    "asOf": "2024-01-16T10:00:00Z",
    "cloudCover": 0.27,
    "cloudCoverLowAltPct": 0.15,
    "cloudCoverMidAltPct": 0.08,
    "cloudCoverHighAltPct": 0.04,
    "conditionCode": "PartlyCloudy",
    "daylight": true,
    "humidity": 0.72,
    "precipitationIntensity": 0.0,
    "pressure": 1015.2,
    "pressureTrend": "rising",
    "temperature": 22.5,
    "temperatureApparent": 21.8,
    "temperatureDewPoint": 17.3,
    "uvIndex": 5,
    "visibility": 24000,
    "windDirection": 245,
    "windGust": 28.5,
    "windSpeed": 18.3
  }
}
```

**Campos Principais:**
- `temperature`: Temperatura (°C no sistema métrico)
- `temperatureApparent`: Sensação térmica (°C)
- `temperatureDewPoint`: Ponto de orvalho (°C)
- `humidity`: Umidade relativa (0.0-1.0, 1.0 = 100%)
- `pressure`: Pressão atmosférica (mbar/hPa)
- `pressureTrend`: Tendência (`rising`, `falling`, `steady`)
- `windSpeed`: Velocidade do vento (km/h)
- `windGust`: Rajadas de vento (km/h)
- `windDirection`: Direção do vento (graus, 0-360)
- `uvIndex`: Índice UV (0-11+)
- `visibility`: Visibilidade (metros)
- `cloudCover`: Cobertura de nuvens (0.0-1.0)
- `precipitationIntensity`: Intensidade de precipitação (mm/h)
- `conditionCode`: Código da condição (ver lista abaixo)
- `daylight`: Se é dia (`true`/`false`)

### Hourly Forecast (Previsão Horária)

```json
{
  "forecastHourly": {
    "name": "HourlyForecast",
    "metadata": {...},
    "hours": [
      {
        "forecastStart": "2024-01-16T11:00:00Z",
        "cloudCover": 0.31,
        "conditionCode": "PartlyCloudy",
        "daylight": true,
        "humidity": 0.68,
        "precipitationAmount": 0.0,
        "precipitationChance": 0.15,
        "precipitationIntensity": 0.0,
        "precipitationType": "clear",
        "pressure": 1015.5,
        "pressureTrend": "rising",
        "snowfallIntensity": 0.0,
        "temperature": 23.2,
        "temperatureApparent": 22.5,
        "temperatureDewPoint": 17.1,
        "uvIndex": 6,
        "visibility": 25000,
        "windDirection": 240,
        "windGust": 30.2,
        "windSpeed": 19.5
      }
      // ... até 240 horas (10 dias)
    ]
  }
}
```

**Campos Adicionais:**
- `precipitationChance`: Probabilidade de precipitação (0.0-1.0)
- `precipitationAmount`: Quantidade de precipitação (mm)
- `precipitationType`: Tipo (`clear`, `rain`, `snow`, `sleet`, `hail`, `mixed`)
- `snowfallIntensity`: Intensidade de neve (mm/h)

### Daily Forecast (Previsão Diária)

```json
{
  "forecastDaily": {
    "name": "DailyForecast",
    "metadata": {...},
    "days": [
      {
        "forecastStart": "2024-01-16T00:00:00Z",
        "forecastEnd": "2024-01-17T00:00:00Z",
        "conditionCode": "PartlyCloudy",
        "maxUvIndex": 7,
        "moonPhase": "waxingCrescent",
        "moonrise": "2024-01-16T08:30:00Z",
        "moonset": "2024-01-16T21:15:00Z",
        "precipitationAmount": 0.0,
        "precipitationChance": 0.10,
        "precipitationType": "clear",
        "snowfallAmount": 0.0,
        "solarMidnight": "2024-01-16T00:45:00Z",
        "solarNoon": "2024-01-16T12:45:00Z",
        "sunrise": "2024-01-16T06:45:00Z",
        "sunriseCivil": "2024-01-16T06:20:00Z",
        "sunriseNautical": "2024-01-16T05:50:00Z",
        "sunriseAstronomical": "2024-01-16T05:20:00Z",
        "sunset": "2024-01-16T18:30:00Z",
        "sunsetCivil": "2024-01-16T18:55:00Z",
        "sunsetNautical": "2024-01-16T19:25:00Z",
        "sunsetAstronomical": "2024-01-16T19:55:00Z",
        "temperatureMax": 28.5,
        "temperatureMin": 18.2,
        "daytimeForecast": {
          "forecastStart": "2024-01-16T06:00:00Z",
          "forecastEnd": "2024-01-16T18:00:00Z",
          "cloudCover": 0.35,
          "conditionCode": "PartlyCloudy",
          "humidity": 0.65,
          "precipitationAmount": 0.0,
          "precipitationChance": 0.05,
          "precipitationType": "clear",
          "snowfallAmount": 0.0,
          "windDirection": 225,
          "windSpeed": 20.5
        },
        "overnightForecast": {
          "forecastStart": "2024-01-16T18:00:00Z",
          "forecastEnd": "2024-01-17T06:00:00Z",
          "cloudCover": 0.22,
          "conditionCode": "MostlyClear",
          "humidity": 0.75,
          "precipitationAmount": 0.0,
          "precipitationChance": 0.02,
          "precipitationType": "clear",
          "snowfallAmount": 0.0,
          "windDirection": 230,
          "windSpeed": 15.3
        },
        "restOfDayForecast": null
      }
      // ... até 10 dias
    ]
  }
}
```

**Campos Exclusivos Diários:**
- `moonPhase`: Fase da lua
  - `new`: Lua nova
  - `waxingCrescent`: Crescente
  - `firstQuarter`: Quarto crescente
  - `waxingGibbous`: Gibosa crescente
  - `full`: Lua cheia
  - `waningGibbous`: Gibosa minguante
  - `lastQuarter`: Quarto minguante
  - `waningCrescent`: Minguante
- `sunrise`/`sunset`: Nascer/pôr do sol
- `moonrise`/`moonset`: Nascer/pôr da lua
- `solarNoon`/`solarMidnight`: Meio-dia/meia-noite solar
- `temperatureMax`/`temperatureMin`: Temperaturas máxima/mínima
- `daytimeForecast`: Previsão para o dia
- `overnightForecast`: Previsão para a noite

### Weather Alerts (Alertas)

```json
{
  "weatherAlerts": {
    "alerts": [
      {
        "countryCode": "BR",
        "description": "Heavy rainfall expected",
        "effectiveTime": "2024-01-16T18:00:00Z",
        "expireTime": "2024-01-17T06:00:00Z",
        "issuedTime": "2024-01-16T12:00:00Z",
        "metadata": {...},
        "severity": "severe",
        "source": "INMET",
        "urgency": "expected"
      }
    ],
    "detailsUrl": "https://...",
    "metadata": {...}
  }
}
```

**Severity Levels:**
- `minor`: Impacto mínimo
- `moderate`: Impacto moderado
- `severe`: Impacto severo
- `extreme`: Impacto extremo

---

## 🎨 Códigos de Condição (conditionCode)

### Céu Limpo/Nuvens
- `Clear`: Limpo
- `MostlyClear`: Maioria limpo
- `PartlyCloudy`: Parcialmente nublado
- `MostlyCloudy`: Maioria nublado
- `Cloudy`: Nublado
- `Haze`: Névoa seca
- `Fog`: Neblina
- `Smoke`: Fumaça
- `Dust`: Poeira

### Vento
- `Breezy`: Brisa
- `Windy`: Ventoso
- `Blizzard`: Nevasca com vento forte
- `BlowingSnow`: Neve soprada

### Chuva
- `Drizzle`: Garoa
- `Rain`: Chuva
- `Showers`: Pancadas de chuva
- `HeavyRain`: Chuva forte
- `ScatteredShowers`: Pancadas esparsas

### Neve
- `Flurries`: Flocos de neve leves
- `Snow`: Neve
- `SnowShowers`: Pancadas de neve
- `HeavySnow`: Neve pesada
- `ScatteredSnowShowers`: Pancadas esparsas de neve

### Mista
- `Sleet`: Granizo/chuva congelante
- `Hail`: Granizo
- `FreezingDrizzle`: Garoa congelante
- `FreezingRain`: Chuva congelante
- `MixedRainfall`: Precipitação mista
- `MixedRainAndSleet`: Chuva e granizo
- `MixedRainAndSnow`: Chuva e neve
- `MixedSleetAndSnow`: Granizo e neve

### Tempestades
- `Thunderstorm`: Tempestade
- `IsolatedThunderstorms`: Tempestades isoladas
- `ScatteredThunderstorms`: Tempestades esparsas
- `SevereThunderstorm`: Tempestade severa
- `Tornado`: Tornado
- `Hurricane`: Furacão
- `TropicalStorm`: Tempestade tropical

### Temperatura Extrema
- `Hot`: Calor extremo
- `Frigid`: Frio extremo

---

## 📈 Limites e Quotas

### Tier Gratuito
- **500.000 chamadas/mês**
- **Rate limit**: ~100 requests/minuto
- Sem custo adicional até o limite

### Tier Pago
- Após 500k chamadas: $0.001 por chamada adicional
- Volume discount disponível

### Best Practices
1. **Cache de dados**: Armazenar localmente por 30-60 min
2. **Batch requests**: Combinar `dataSets` quando possível
3. **Previsão**: Usar `forecastDaily` em vez de múltiplos `currentWeather`
4. **Monitoramento**: Acompanhar uso no Apple Developer Portal

---

## 🛠️ Exemplo de Implementação Flutter/Dart

### 1. Dependências (pubspec.yaml)

```yaml
dependencies:
  dio: ^5.4.0
  dart_jsonwebtoken: ^2.12.0
  flutter_dotenv: ^5.1.0
```

### 2. Configuração (.env)

```env
WEATHERKIT_TEAM_ID=ABC123XYZ
WEATHERKIT_SERVICE_ID=br.com.agrimind.agrihurbi.weatherkit
WEATHERKIT_KEY_ID=DEF456GHI
WEATHERKIT_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIGT....\n-----END PRIVATE KEY-----
```

### 3. JWT Generator

```dart
// lib/core/services/weatherkit_jwt_service.dart
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherKitJWTService {
  String generateToken() {
    final teamId = dotenv.env['WEATHERKIT_TEAM_ID']!;
    final serviceId = dotenv.env['WEATHERKIT_SERVICE_ID']!;
    final keyId = dotenv.env['WEATHERKIT_KEY_ID']!;
    final privateKey = dotenv.env['WEATHERKIT_PRIVATE_KEY']!;

    final jwt = JWT(
      {
        'iss': teamId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(Duration(minutes: 50)).millisecondsSinceEpoch ~/ 1000,
        'sub': serviceId,
      },
      header: {
        'alg': 'ES256',
        'kid': keyId,
        'id': '$teamId.$serviceId',
      },
    );

    return jwt.sign(
      ECPrivateKey(privateKey),
      algorithm: JWTAlgorithm.ES256,
    );
  }
}
```

### 4. API Client

```dart
// lib/features/weather/data/datasources/weatherkit_datasource.dart
import 'package:dio/dio.dart';

class WeatherKitDataSource {
  final Dio _dio;
  final WeatherKitJWTService _jwtService;

  static const String _baseUrl = 'https://weatherkit.apple.com/api/v1';

  WeatherKitDataSource(this._dio, this._jwtService);

  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
    String language = 'pt-BR',
    String timezone = 'America/Sao_Paulo',
  }) async {
    final token = _jwtService.generateToken();

    final response = await _dio.get(
      '$_baseUrl/weather/$language/$latitude/$longitude',
      queryParameters: {
        'dataSets': 'currentWeather',
        'timezone': timezone,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getForecast({
    required double latitude,
    required double longitude,
    String language = 'pt-BR',
    String timezone = 'America/Sao_Paulo',
    List<String> dataSets = const ['currentWeather', 'forecastDaily', 'forecastHourly'],
  }) async {
    final token = _jwtService.generateToken();

    final response = await _dio.get(
      '$_baseUrl/weather/$language/$latitude/$longitude',
      queryParameters: {
        'dataSets': dataSets.join(','),
        'timezone': timezone,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data as Map<String, dynamic>;
  }
}
```

---

## ✅ Checklist de Implementação

### Setup Inicial
- [ ] Criar Apple Developer Account
- [ ] Criar Service ID no portal
- [ ] Gerar API Key (.p8)
- [ ] Anotar Team ID, Service ID, Key ID
- [ ] Adicionar dependências no pubspec.yaml

### Desenvolvimento
- [ ] Criar service para geração de JWT
- [ ] Implementar datasource WeatherKit
- [ ] Estender WeatherMeasurementEntity com novos campos
- [ ] Criar mappers (API response → Entity)
- [ ] Implementar cache local (30-60 min)
- [ ] Adicionar error handling
- [ ] Logging de chamadas API

### Testes
- [ ] Testar geração de JWT
- [ ] Testar chamadas à API
- [ ] Validar mapeamento de dados
- [ ] Testar cache
- [ ] Testar diferentes localizações
- [ ] Monitorar quota de uso

### Produção
- [ ] Configurar variáveis de ambiente
- [ ] Implementar rate limiting
- [ ] Monitoramento de erros
- [ ] Analytics de uso
- [ ] Documentação para time

---

## 📚 Recursos

- [WeatherKit REST API Docs](https://developer.apple.com/documentation/weatherkitrestapi/)
- [Apple Developer Portal](https://developer.apple.com/account)
- [JWT.io - Debugger](https://jwt.io)
- [dart_jsonwebtoken package](https://pub.dev/packages/dart_jsonwebtoken)

---

**Criado em**: 2026-01-16  
**Versão**: 1.0  
**Status**: ✅ Pronto para implementação
