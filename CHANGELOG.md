## 0.1.2

### Added
- **🔀 State Migration System**: Automatic versioning and migration support for breaking changes
  - New `version` getter to define current state structure version (defaults to 1)
  - New `migrate(json, fromVersion)` method for handling data migrations
  - Version is automatically saved with state as `__version__` field
  - Migrations are applied automatically when loading older state
  - Multi-step migration support for upgrading across multiple versions
  - Backward compatible: default version is 1, no migration needed for existing apps

### Fixed
- **🐛 Critical**: Fixed `AutoDisposeHydratedNotifier` to correctly work with Riverpod 3.x
  - Note: In Riverpod 3.x, AutoDispose is a property of the provider, not the notifier
  - Both `HydratedNotifier` and `AutoDisposeHydratedNotifier` now extend `Notifier<State>` correctly
  - All existing code continues to work without changes
- **🐛 Critical**: Fixed race condition in dispose that could prevent state from being persisted
  - `ref.onDispose()` is now async and properly awaits write completion
  - Added `_flushPendingAsync()` method that ensures async writes complete before disposal
  - Fixes issues with state loss during hot reload and rapid dispose scenarios
  - Particularly important for AutoDispose notifiers and debounced writes

### Changed
- Internal implementation now uses separate mixins for better code organization
  - `HydratedMixinBase<State>` for regular `Notifier<State>`
  - `AutoDisposeHydratedMixin<State>` for AutoDispose support
  - Both mixins include full migration support and all features

---

## 0.1.1

### Improvements & Refactoring

**API Changes:**
- 🔐 Simplified encryption API in `HiveHydratedStorage.build()`
  - Replaced `encryptionCipher` parameter with `encrypted` (boolean) and `encryptionKey` (List<int>)
  - `encryptionKey` is now required only when `encrypted` is true
  - Added validation to throw `ArgumentError` when encryption is enabled without a key

**Example App:**
- 📁 Refactored example application structure for better organization
  - Extracted models to `lib/models/`
  - Extracted providers/notifiers to `lib/providers/`
  - Extracted widgets to `lib/widgets/`
  - Extracted pages to `lib/pages/`
  - Created barrel files for easier imports

**Documentation:**
- 📚 Updated README with new encryption API examples

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