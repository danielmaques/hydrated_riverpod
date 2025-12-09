# Hydrated Riverpod

[![pub package](https://img.shields.io/pub/v/hydrated_riverpod.svg)](https://pub.dev/packages/hydrated_riverpod)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Uma extensão do Riverpod que automaticamente persiste e restaura o estado dos seus notifiers usando Hive como backend de armazenamento.

## Features

- 🔄 **Persistência automática**: Salva e restaura o estado automaticamente
- 🏗️ **Compatível com Riverpod**: Funciona com `Notifier` e `AutoDisposeNotifier`
- 🗄️ **Backend Hive**: Usa Hive para armazenamento local eficiente
- 🛡️ **Tratamento de erros**: Lida graciosamente com erros de serialização/desserialização
- 🔒 **Thread-safe**: Operações de armazenamento sincronizadas
- 🧹 **Limpeza fácil**: Métodos para limpar estado persistido

## Getting started

### 1. Adicione a dependência

```yaml
dependencies:
  hydrated_riverpod: ^1.0.0
  riverpod: ^3.0.3
  hive_ce: ^2.6.0
  path_provider: ^2.1.3  # Para Flutter
```

### 2. Configure o armazenamento

```dart
import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Para Flutter
  final appDir = await getApplicationDocumentsDirectory();
  final storage = await HiveHydratedStorage.build(
    storageDirectory: appDir.path,
  );

  // Para Dart puro
  // final storage = await HiveHydratedStorage.build(
  //   storageDirectory: Directory.current.path,
  // );

  HydratedStorage.instance = storage;

  runApp(const MyApp());
}
```

## Usage

Chame `hydrate()` no início do `build()` para restaurar o estado persistido (ele retorna `null` quando não há nada salvo).

### Criando um notifier hidratado

```dart
import 'package:riverpod/riverpod.dart';
import 'package:hydrated_riverpod/hydrated_riverpod.dart';

class CounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  void decrement() => state--;

  // Serialização para JSON
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  // Desserialização do JSON
  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

// Provider
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
```

### Usando com AutoDispose

```dart
class TempCounterNotifier extends AutoDisposeHydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  // Serialização
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}
```

### Limpar estado persistido

```dart
// Em um notifier
await clear(); // Limpa apenas este notifier

// Globalmente
await HydratedStorage.instance?.clear(); // Limpa tudo
```

### Tratamento de erros

```dart
class SafeCounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  void onError(Object error, StackTrace stackTrace) {
    // Lidar com erros de serialização/desserialização
    print('Erro de persistência: $error');
    super.onError(error, stackTrace);
  }

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) {
    try {
      return json['value'] as int?;
    } catch (e) {
      // Retorna null para usar estado inicial
      return null;
    }
  }
}
```

### Chaves de armazenamento customizadas

```dart
class CustomKeyNotifier extends HydratedNotifier<String> {
  @override
  String get storageKey => 'my_custom_key'; // sobrescreve tudo

  @override
  String? get storageKeySuffix => userId; // vira runtimeType:userId
  final String userId;

  @override
  String build() => hydrate() ?? 'Hello World';

  @override
  Map<String, dynamic>? toJson(String state) => {'text': state};

  @override
  String? fromJson(Map<String, dynamic> json) => json['text'] as String?;
}
```

### Debounce e observabilidade

```dart
class DebouncedCounter extends HydratedNotifier<int> {
  @override
  Duration get writeDebounce => const Duration(milliseconds: 100);

  @override
  void onPersist(Map<String, dynamic> json) {
    // Envie para um logger/analytics, se quiser
  }

  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}
```

### Isolates e Hive

Hive não é seguro para múltiplos isolates usando a mesma box. Em testes, rode em single-isolate ou use `IsolatedHive`. Caso contrário, você verá avisos de “HIVE MULTI-ISOLATE RISK DETECTED”.

## Exemplo completo

Veja o [exemplo completo](example/) para uma aplicação Flutter funcional.

## Additional information

### Arquitetura

O pacote usa mixins para adicionar funcionalidade de persistência aos seus notifiers:

- `HydratedMixin`: Para `Notifier`
- `AutoDisposeHydratedMixin`: Para `AutoDisposeNotifier`

### Backend de armazenamento

Por padrão, usa Hive como backend, mas a interface `HydratedStorage` permite implementar outros backends se necessário.

### Considerações de performance

- A serialização/desserialização acontece apenas quando necessário
- Operações de escrita são sincronizadas para evitar condições de corrida
- O estado é salvo automaticamente quando o notifier é disposed

### Limitações

- O estado deve ser serializável para JSON
- Funciona apenas com notifiers (não com providers simples)

## Contributing

Contribuições são bem-vindas! Por favor, leia as [diretrizes de contribuição](CONTRIBUTING.md) antes de submeter um PR.

## Issues

Encontrou um bug? [Abra uma issue](https://github.com/seu-usuario/hydrated_riverpod/issues) no GitHub.

## License

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.
