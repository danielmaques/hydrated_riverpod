# Hydrated Riverpod

[![pub package](https://img.shields.io/pub/v/hydrated_riverpod.svg)](https://pub.dev/packages/hydrated_riverpod)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Uma extensão do Riverpod que automaticamente persiste e restaura o estado dos seus notifiers usando Hive como backend de armazenamento.

Inspirado no [hydrated_bloc](https://pub.dev/packages/hydrated_bloc), mas feito especificamente para Riverpod.

## ✨ Features

- 🔄 **Persistência automática**: Salva e restaura o estado automaticamente
- 🏗️ **API familiar**: Use `build()` como Riverpod normal, apenas chame `hydrate()`
- 🗄️ **Backend Hive**: Armazenamento local eficiente e confiável
- 🛡️ **Tratamento de erros**: Lida graciosamente com erros de serialização
- 🔒 **Thread-safe**: Operações sincronizadas com `synchronized`
- ⚡ **Debounce integrado**: Otimize escritas frequentes
- 🧹 **Fácil limpeza**: Métodos para limpar estado persistido
- 🎯 **Cache in-memory**: Evita race conditions em writes assíncronos

## 📦 Instalação

Adicione ao seu `pubspec.yaml`:

```yaml
dependencies:
  hydrated_riverpod: ^0.1.0
  riverpod: ^3.0.3  # ou flutter_riverpod para Flutter
```

Para **Flutter**, você também precisa do `path_provider` para obter o diretório de documentos:

```yaml
dependencies:
  path_provider: ^2.1.3  # Apenas para Flutter
```

> **💡 Nota**: `hive_ce` já está incluído como dependência do `hydrated_riverpod`, você não precisa adicioná-lo!

Então rode:

```bash
dart pub get  # ou flutter pub get
```

## 🚀 Quick Start

### 1. Configure o storage (apenas uma vez no main)

**Para Flutter:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obter diretório para storage
  final appDir = await getApplicationDocumentsDirectory();
  
  // Inicializar storage
  final storage = await HiveHydratedStorage.build(
    storageDirectory: appDir.path,
  );
  HydratedStorage.instance = storage;

  runApp(const ProviderScope(child: MyApp()));
}
```

**Para Dart puro:**

```dart
import 'dart:io';
import 'package:hydrated_riverpod/hydrated_riverpod.dart';
import 'package:riverpod/riverpod.dart';

Future<void> main() async {
  // Inicializar storage
  final storage = await HiveHydratedStorage.build(
    storageDirectory: Directory.current.path,
  );
  HydratedStorage.instance = storage;

  final container = ProviderContainer();
  // ... seu código
}
```

### 2. Crie um notifier hidratado

```dart
import 'package:riverpod/riverpod.dart';
import 'package:hydrated_riverpod/hydrated_riverpod.dart';

class CounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0; // Restaura estado ou usa 0 como padrão

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;

  // Como serializar
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  // Como desserializar
  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

// Provider
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
```

### 3. Use normalmente

```dart
class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);

    return Scaffold(
      body: Center(
        child: Text('Counter: $counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**Pronto!** O estado agora persiste automaticamente. Feche e reabra o app - o contador estará lá! 🎉

## 📚 Exemplos Avançados

### Estado complexo com classes

```dart
class TodoNotifier extends HydratedNotifier<List<Todo>> {
  @override
  List<Todo> build() => hydrate() ?? [];

  void addTodo(String title) {
    state = [...state, Todo(id: uuid.v4(), title: title)];
  }

  void toggleTodo(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(done: !todo.done) else todo,
    ];
  }

  @override
  Map<String, dynamic>? toJson(List<Todo> state) {
    return {'todos': state.map((t) => t.toJson()).toList()};
  }

  @override
  List<Todo>? fromJson(Map<String, dynamic> json) {
    final todos = json['todos'] as List?;
    if (todos == null) return null;
    return todos.map((t) => Todo.fromJson(t)).toList();
  }
}
```

### Com Freezed/json_serializable

```dart
@freezed
class UserState with _$UserState {
  const factory UserState({
    required String name,
    required String email,
    required bool isLoggedIn,
  }) = _UserState;

  factory UserState.fromJson(Map<String, dynamic> json) =>
      _$UserStateFromJson(json);
}

class UserNotifier extends HydratedNotifier<UserState> {
  @override
  UserState build() => hydrate() ?? UserState.empty();

  void login(String name, String email) {
    state = state.copyWith(name: name, email: email, isLoggedIn: true);
  }

  void logout() {
    state = UserState.empty();
  }

  @override
  Map<String, dynamic>? toJson(UserState state) => state.toJson();

  @override
  UserState? fromJson(Map<String, dynamic> json) {
    try {
      return UserState.fromJson(json);
    } catch (e) {
      return null; // Se falhar, usa estado inicial
    }
  }
}
```

### Múltiplas instâncias (multi-account)

```dart
class UserSessionNotifier extends HydratedNotifier<SessionData> {
  UserSessionNotifier(this.userId);
  
  final String userId;
  
  @override
  String? get storageKeySuffix => userId; // Chave única por usuário

  @override
  SessionData build() => hydrate() ?? SessionData.empty();
  
  // ... toJson/fromJson
}

// Uso
final user1Session = NotifierProvider<UserSessionNotifier, SessionData>(
  () => UserSessionNotifier('user-123'),
);

final user2Session = NotifierProvider<UserSessionNotifier, SessionData>(
  () => UserSessionNotifier('user-456'),
);
```

### Debounce para otimizar performance

```dart
class SearchQueryNotifier extends HydratedNotifier<String> {
  @override
  Duration get writeDebounce => const Duration(milliseconds: 500);

  @override
  String build() => hydrate() ?? '';

  void setQuery(String query) => state = query;

  @override
  Map<String, dynamic>? toJson(String state) => {'query': state};

  @override
  String? fromJson(Map<String, dynamic> json) => json['query'] as String?;
}
```

### Com AutoDispose

```dart
class TempCounterNotifier extends AutoDisposeHydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

final tempCounterProvider = NotifierProvider.autoDispose<TempCounterNotifier, int>(
  TempCounterNotifier.new,
);
```

### Tratamento de erros customizado

```dart
class SafeNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    
    // Log para analytics
    analytics.logError(error, stackTrace);
    
    // Mostra snackbar para usuário
    showErrorSnackbar('Erro ao salvar dados');
  }

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}
```

### Hook de observabilidade

```dart
class TrackedNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  void onPersist(Map<String, dynamic> json) {
    // Enviar evento para analytics
    analytics.track('state_persisted', properties: {
      'notifier': runtimeType.toString(),
      'value': json['value'],
    });
  }

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}
```

## 🔧 Métodos Úteis

### Limpar estado persistido

```dart
// Limpar estado de um notifier específico
await ref.read(counterProvider.notifier).clear();

// Limpar todo o storage
await HydratedStorage.instance?.clear();
```

### Chaves de storage customizadas

```dart
class MyNotifier extends HydratedNotifier<int> {
  // Opção 1: Sobrescrever completamente
  @override
  String get storageKey => 'my_custom_key';

  // Opção 2: Adicionar sufixo (vira 'MyNotifier:suffix')
  @override
  String? get storageKeySuffix => 'user_${userId}';

  // Opção 3: Mudar separador (vira 'MyNotifier-suffix')
  @override
  String get storageKeySeparator => '-';
  
  // ...
}
```

## ⚙️ Configurações Avançadas

### Custom storage backend

```dart
class MyCustomStorage implements HydratedStorage {
  @override
  dynamic read(String key) {
    // Implementar leitura
  }

  @override
  Future<void> write(String key, dynamic value) async {
    // Implementar escrita
  }

  // ... outros métodos
}

// Usar
HydratedStorage.instance = MyCustomStorage();
```

### Box customizada do Hive

```dart
final storage = await HiveHydratedStorage.build(
  storageDirectory: appDir.path,
  boxName: 'my_custom_box', // Nome customizado
);
```

## 🎯 Boas Práticas

### ✅ DO

```dart
// ✅ Use hydrate() no build()
@override
int build() => hydrate() ?? 0;

// ✅ Forneça fallback com ??
@override
UserState build() => hydrate() ?? UserState.initial();

// ✅ Trate erros em fromJson
@override
User? fromJson(Map<String, dynamic> json) {
  try {
    return User.fromJson(json);
  } catch (e) {
    return null; // Usa estado inicial
  }
}

// ✅ Use debounce para estados que mudam rapidamente
@override
Duration get writeDebounce => const Duration(milliseconds: 300);
```

### ❌ DON'T

```dart
// ❌ Não ignore hydrate()
@override
int build() => 0; // Estado anterior será perdido!

// ❌ Não faça operações pesadas em toJson/fromJson
@override
Map<String, dynamic>? toJson(State state) {
  await heavyComputation(); // ❌ toJson é síncrono!
  return state.toJson();
}

// ❌ Não persista dados sensíveis sem criptografia
@override
Map<String, dynamic>? toJson(State state) {
  return {'password': state.password}; // ❌ Inseguro!
}
```

## 🐛 Troubleshooting

### Estado não está persistindo

1. Verifique se `HydratedStorage.instance` foi inicializado no `main()`
2. Certifique-se de chamar `hydrate()` no `build()`
3. Verifique se `toJson()` está retornando um Map válido
4. Confirme que o dispose está sendo chamado

### Erro "HydratedStorage is not initialized"

Você esqueceu de inicializar o storage no `main()`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDir = await getApplicationDocumentsDirectory();
  final storage = await HiveHydratedStorage.build(
    storageDirectory: appDir.path,
  );
  HydratedStorage.instance = storage; // ← Não esqueça!
  
  runApp(MyApp());
}
```

### Problemas com isolates

Hive não suporta múltiplos isolates na mesma box. Se você vir avisos sobre "MULTI-ISOLATE RISK", considere:
- Usar boxes diferentes por isolate
- Usar `IsolatedHive` em testes
- Executar testes em modo single-isolate

## 📊 Comparação com outras soluções

| Feature | hydrated_riverpod | shared_preferences | hydrated_bloc |
|---------|-------------------|-------------------|---------------|
| Auto-persist | ✅ | ❌ | ✅ |
| Type-safe | ✅ | ❌ | ✅ |
| Debounce | ✅ | ❌ | ❌ |
| Riverpod integration | ✅ | ❌ | ❌ |
| Zero boilerplate | ✅ | ❌ | ✅ |

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, abra uma issue ou PR.

## 📄 License

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

Inspirado por:
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) - pela API elegante
- [riverpod](https://pub.dev/packages/riverpod) - pelo excelente gerenciamento de estado
- [hive](https://pub.dev/packages/hive_ce) - pelo storage rápido e confiável

---

Feito com ❤️ para a comunidade Flutter/Riverpod