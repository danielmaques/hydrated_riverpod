## 0.2.0

### New Features

- 🔐 **Optional encryption support** - Added `encrypted` and `encryptionKey` parameters to `HiveHydratedStorage.build()` for AES-256 encryption

### API Changes

- `HiveHydratedStorage.build()` now accepts:
  - `encrypted: bool` (default: `false`) - Enable/disable encryption
  - `encryptionKey: List<int>?` - 32-byte key (required when `encrypted: true`)

---

## 0.1.0

### Initial Beta Release


**Features:**
- ✨ Automatic state persistence and restoration for Riverpod notifiers
- 🏗️ Support for both `Notifier` and `AutoDisposeNotifier`
- 🗄️ Hive-based storage backend with in-memory cache
- ⚡ Built-in debounce support for write optimization
- 🔒 Thread-safe operations using `synchronized` package
- 🎯 Flexible storage key customization with suffix support
- 🛡️ Graceful error handling with `onError` and `onPersist` hooks
- 📊 Deep equality checking to avoid unnecessary writes

**API:**
- `HydratedNotifier<State>` - Base class for persistent notifiers
- `AutoDisposeHydratedNotifier<State>` - Auto-dispose variant
- `hydrate()` - Method to restore persisted state
- `toJson()` / `fromJson()` - Serialization methods
- `clear()` - Clear persisted state
- `HiveHydratedStorage` - Hive implementation of storage

**Breaking Changes:**
- None (initial release)

**Known Issues:**
- Hive is not safe for multi-isolate use with the same box
- Write debounce may cause state loss if app is force-killed during debounce window

---

For migration guides and detailed documentation, see [README.md](README.md).