# Hydrated Riverpod

[![pub package](https://img.shields.io/pub/v/riverpod_hydrated.svg)](https://pub.dev/packages/riverpod_hydrated)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI](https://github.com/danielmaques/riverpod_hydrated/workflows/CI/badge.svg)](https://github.com/danielmaques/riverpod_hydrated/actions)
[![codecov](https://codecov.io/gh/danielmaques/riverpod_hydrated/branch/main/graph/badge.svg)](https://codecov.io/gh/danielmaques/riverpod_hydrated)
[![Pub Points](https://img.shields.io/pub/points/riverpod_hydrated)](https://pub.dev/packages/riverpod_hydrated/score)
[![Pub Popularity](https://img.shields.io/pub/popularity/riverpod_hydrated)](https://pub.dev/packages/riverpod_hydrated)

An extension for Riverpod that automatically persists and restores the state of your notifiers using Hive as the storage backend.

Inspired by [hydrated_bloc](https://pub.dev/packages/hydrated_bloc), but built specifically for Riverpod.

## ✨ Features

- 🔄 **Automatic persistence**: Saves and restores state automatically
- 🏗️ **Familiar API**: Use `build()` like regular Riverpod, just call `hydrate()`
- 🗄️ **Hive backend**: Efficient and reliable local storage
- 🛡️ **Error handling**: Gracefully handles serialization errors
- 🔒 **Thread-safe**: Operations synchronized with `synchronized`
- ⚡ **Built-in debounce**: Optimize frequent writes
- 🧹 **Easy cleanup**: Methods to clear persisted state
- 🎯 **In-memory cache**: Avoid race conditions on async writes

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  riverpod_hydrated: ^0.1.0
  riverpod: ^3.0.3  # or flutter_riverpod for Flutter
```

For **Flutter**, you also need `path_provider` to get the documents directory:

```yaml
dependencies:
  path_provider: ^2.1.3  # Flutter only
```

> **💡 Note**: `hive_ce` is already included as a dependency of `riverpod_hydrated`, you don't need to add it!

Then run:

```bash
dart pub get  # or flutter pub get
```

## 🚀 Quick Start

### 1. Configure storage (only once in main)

**For Flutter:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_hydrated/riverpod_hydrated.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get directory for storage
  final appDir = await getApplicationDocumentsDirectory();
  
  // Initialize storage
  final storage = await HiveHydratedStorage.build(
    storageDirectory: appDir.path,
  );
  HydratedStorage.instance = storage;

  runApp(const ProviderScope(child: MyApp()));
}
```

**For pure Dart:**

```dart
import 'dart:io';
import 'package:riverpod_hydrated/riverpod_hydrated.dart';
import 'package:riverpod/riverpod.dart';

Future<void> main() async {
  // Initialize storage
  final storage = await HiveHydratedStorage.build(
    storageDirectory: Directory.current.path,
  );
  HydratedStorage.instance = storage;

  final container = ProviderContainer();
  // ... your code
}
```

### 2. Create a hydrated notifier

```dart
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_hydrated/riverpod_hydrated.dart';

class CounterNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0; // Restore state or fall back to 0

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;

  // How to serialize
  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  // How to deserialize
  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

// Provider
final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);
```

### 3. Use it as usual

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

**Done!** State now persists automatically. Close and reopen the app—the counter will still be there! 🎉

## 📚 Advanced Examples

### Complex state with classes

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

### With Freezed/json_serializable

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
      return null; // If it fails, fall back to the initial state
    }
  }
}
```

### Multiple instances (multi-account)

```dart
class UserSessionNotifier extends HydratedNotifier<SessionData> {
  UserSessionNotifier(this.userId);
  
  final String userId;
  
  @override
  String? get storageKeySuffix => userId; // Unique key per user

  @override
  SessionData build() => hydrate() ?? SessionData.empty();
  
  // ... toJson/fromJson
}

// Usage
final user1Session = NotifierProvider<UserSessionNotifier, SessionData>(
  () => UserSessionNotifier('user-123'),
);

final user2Session = NotifierProvider<UserSessionNotifier, SessionData>(
  () => UserSessionNotifier('user-456'),
);
```

### Debounce to optimize performance

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

### With AutoDispose

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

### Custom error handling

```dart
class SafeNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    
    // Log to analytics
    analytics.logError(error, stackTrace);
    
    // Show a snackbar to the user
    showErrorSnackbar('Error saving data');
  }

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}
```

### Observability hook

```dart
class TrackedNotifier extends HydratedNotifier<int> {
  @override
  int build() => hydrate() ?? 0;

  void increment() => state++;

  @override
  void onPersist(Map<String, dynamic> json) {
    // Send event to analytics
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

## 🔧 Useful Methods

### Clear persisted state

```dart
// Clear state for a specific notifier
await ref.read(counterProvider.notifier).clear();

// Clear the entire storage
await HydratedStorage.instance?.clear();
```

### Custom storage keys

```dart
class MyNotifier extends HydratedNotifier<int> {
  // Option 1: Override completely
  @override
  String get storageKey => 'my_custom_key';

  // Option 2: Add a suffix (becomes 'MyNotifier:suffix')
  @override
  String? get storageKeySuffix => 'user_${userId}';

  // Option 3: Change separator (becomes 'MyNotifier-suffix')
  @override
  String get storageKeySeparator => '-';
  
  // ...
}
```

## ⚙️ Advanced Configuration

### Custom storage backend

```dart
class MyCustomStorage implements HydratedStorage {
  @override
  dynamic read(String key) {
    // Implement reading
  }

  @override
  Future<void> write(String key, dynamic value) async {
    // Implement writing
  }

  // ... other methods
}

// Use
HydratedStorage.instance = MyCustomStorage();
```

### Custom Hive box

```dart
final storage = await HiveHydratedStorage.build(
  storageDirectory: appDir.path,
  boxName: 'my_custom_box', // Custom name
);
```

### Encrypted storage

For sensitive data, you can enable AES-256 encryption:

```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get or generate encryption key
  const secureStorage = FlutterSecureStorage();
  var encryptionKeyString = await secureStorage.read(key: 'hive_key');
  
  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(key: 'hive_key', value: base64UrlEncode(key));
    encryptionKeyString = base64UrlEncode(key);
  }
  
  final encryptionKey = base64Url.decode(encryptionKeyString);
  
  final appDir = await getApplicationDocumentsDirectory();
  final storage = await HiveHydratedStorage.build(
    storageDirectory: appDir.path,
    encrypted: true,
    encryptionKey: encryptionKey,
  );
  HydratedStorage.instance = storage;
  
  runApp(const ProviderScope(child: MyApp()));
}
```

> **⚠️ Important**: Store your encryption key securely using `flutter_secure_storage` or similar. If you lose the key, you lose access to all persisted data!

## 🎯 Best Practices

### ✅ DO

```dart
// ✅ Use hydrate() in build()
@override
int build() => hydrate() ?? 0;

// ✅ Provide a fallback with ??
@override
UserState build() => hydrate() ?? UserState.initial();

// ✅ Handle errors in fromJson
@override
User? fromJson(Map<String, dynamic> json) {
  try {
    return User.fromJson(json);
  } catch (e) {
    return null; // Falls back to initial state
  }
}

// ✅ Use debounce for fast-changing state
@override
Duration get writeDebounce => const Duration(milliseconds: 300);
```

### ❌ DON'T

```dart
// ❌ Don't skip hydrate()
@override
int build() => 0; // Previous state will be lost!

// ❌ Don't do heavy work in toJson/fromJson
@override
Map<String, dynamic>? toJson(State state) {
  await heavyComputation(); // ❌ toJson is synchronous!
  return state.toJson();
}

// ❌ Don't persist sensitive data without encryption
@override
Map<String, dynamic>? toJson(State state) {
  return {'password': state.password}; // ❌ Not secure!
}
```

## 🐛 Troubleshooting

### State is not persisting

1. Make sure `HydratedStorage.instance` was initialized in `main()`
2. Be sure to call `hydrate()` in `build()`
3. Verify `toJson()` returns a valid Map
4. Confirm dispose is being called

### Error "HydratedStorage is not initialized"

You forgot to initialize storage in `main()`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDir = await getApplicationDocumentsDirectory();
  final storage = await HiveHydratedStorage.build(
    storageDirectory: appDir.path,
  );
  HydratedStorage.instance = storage; // ← Don't forget!
  
  runApp(MyApp());
}
```

### Issues with isolates

Hive does not support multiple isolates on the same box. If you see warnings about "MULTI-ISOLATE RISK", consider:
- Using different boxes per isolate
- Using `IsolatedHive` in tests
- Running tests in single-isolate mode

## 📊 Comparison with other solutions

| Feature | riverpod_hydrated | shared_preferences | hydrated_bloc |
|---------|-------------------|-------------------|---------------|
| Auto-persist | ✅ | ❌ | ✅ |
| Type-safe | ✅ | ❌ | ✅ |
| Debounce | ✅ | ❌ | ❌ |
| Riverpod integration | ✅ | ❌ | ❌ |
| Zero boilerplate | ✅ | ❌ | ✅ |

## 🤝 Contributing

Contributions are welcome! Please open an issue or PR.

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Thanks

Inspired by:
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) - for the elegant API
- [riverpod](https://pub.dev/packages/riverpod) - for the great state management
- [hive](https://pub.dev/packages/hive_ce) - for fast, reliable storage

---

Made with ❤️ for the Flutter/Riverpod community
