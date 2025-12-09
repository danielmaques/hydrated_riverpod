# Contributing to Hydrated Riverpod

Thanks for considering a contribution to Hydrated Riverpod! 🎉

## 🚀 How to Contribute

### 1. Fork and Clone

```bash
git clone https://github.com/<your-username>/hydrated_riverpod.git
cd hydrated_riverpod
dart pub get
```

### 2. Create a Branch

```bash
git checkout -b feature/my-feature
# or
git checkout -b fix/my-bug-fix
```

### 3. Make Your Changes

- Follow the existing code style
- Add tests for new functionality
- Update documentation when needed

### 4. Run Tests

```bash
# Run all tests
dart test

# Run specific tests
dart test test/hydrated_riverpod_test.dart

# With coverage
dart test --coverage=coverage
```

### 5. Check Lint

```bash
dart analyze
dart format .
```

### 6. Commit and Push

```bash
git add .
git commit -m "feat: add new feature X"
git push origin feature/my-feature
```

### 7. Open a Pull Request

- Clearly describe what your PR does
- Reference related issues
- Wait for review

## 📝 Commit Standards

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new functionality
- `fix:` bug fix
- `docs:` documentation changes
- `test:` add or update tests
- `refactor:` code refactor
- `style:` formatting, semicolons, etc.
- `chore:` build, CI, and other maintenance

**Examples:**
```
feat: add support for migrations
fix: fix race condition in debounce
docs: update README with Freezed example
test: add tests for custom storage keys
```

## 🧪 Writing Tests

All new code should include tests:

```dart
test('should describe what it does', () async {
  // Arrange
  final storage = InMemoryHydratedStorage();
  HydratedStorage.instance = storage;

  // Act
  // ... your code

  // Assert
  expect(result, expected);
});
```

## 📖 Documentation

- Add dartdoc comments for public APIs
- Update README.md when needed
- Include usage examples when appropriate

```dart
/// Does something useful.
///
/// Example:
/// ```dart
/// final result = doSomething();
/// print(result); // Output: something
/// ```
void doSomething() { }
```

## 🐛 Reporting Bugs

When reporting bugs, include:

1. **Package version**
2. **Dart/Flutter version**
3. **Steps to reproduce**
4. **Expected behavior** vs **actual behavior**
5. **Logs** or relevant stack traces

## 💡 Suggesting Features

Before suggesting a feature:

1. Check if an issue already exists
2. Explain the **problem** it solves
3. Describe the **proposed solution**
4. Consider **alternatives**

## ⚠️ What NOT to Do

- ❌ Commit `pubspec.lock` (it is ignored)
- ❌ Add unnecessary dependencies
- ❌ Break the public API without discussion
- ❌ Submit massive PRs (split them up)
- ❌ Ignore reviewer feedback

## 📋 PR Checklist

Before submitting, verify:

- [ ] Tests pass (`dart test`)
- [ ] Lint passes (`dart analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (for features/fixes)
- [ ] Examples working

## 🎯 Areas That Need Help

We always appreciate help with:

- 📝 Improving documentation
- 🧪 Adding more tests
- 🐛 Fixing bugs
- 🌐 Translating documentation
- ✨ Implementing pending features

See the [issues labeled "good first issue"](https://github.com/danielmaques/hydrated_riverpod/labels/good%20first%20issue).

## 📞 Questions?

- Open a [Discussion](https://github.com/danielmaques/hydrated_riverpod/discussions)
- Comment on an existing issue
- Reach out via the email on the profile

## 📜 Code of Conduct

Be respectful and professional. We do not tolerate:
- Harassment or discrimination
- Offensive language
- Trolling or personal attacks

## 🙏 Thank You!

Every contribution, no matter how small, is valuable. Thanks for helping improve Hydrated Riverpod!

---

**Happy coding!** 🚀
