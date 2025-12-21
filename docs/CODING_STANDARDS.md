# Coding Standards - Manage Your Logistic

## General Principles

1. **KISS** - Keep It Simple, Stupid
2. **DRY** - Don't Repeat Yourself
3. **SOLID** - Follow SOLID principles
4. **Clean Code** - Write self-documenting code

## Dart/Flutter Specific

### Naming Conventions

```dart
// Classes: PascalCase
class UserModel {}
class AuthService {}

// Files: snake_case
user_model.dart
auth_service.dart

// Variables & functions: camelCase
String userName = 'John';
void fetchUserData() {}

// Constants: lowerCamelCase
const int maxRetries = 3;
const String apiBaseUrl = 'https://...';

// Private members: _prefixed
String _privateField;
void _privateMethod() {}
```

### File Organization

```dart
// 1. Imports (grouped)
import 'dart:async';                    // Dart
import 'dart:io';

import 'package:flutter/material.dart'; // Flutter
import 'package:flutter/services.dart';

import 'package:riverpod/riverpod.dart'; // Packages

import '../models/user_model.dart';      // Relative imports

// 2. Class declaration
class MyClass {
  // 3. Constants
  static const int maxValue = 100;
  
  // 4. Fields
  final String name;
  int _privateCounter = 0;
  
  // 5. Constructor
  MyClass({required this.name});
  
  // 6. Public methods
  void publicMethod() {}
  
  // 7. Private methods
  void _privateMethod() {}
}
```

### Widget Best Practices

```dart
// ✅ GOOD: Use const constructors
const Text('Hello')
const SizedBox(height: 16)

// ❌ BAD: Unnecessary rebuilds
Text('Hello')
SizedBox(height: 16)

// ✅ GOOD: Extract widgets for readability
Widget _buildHeader() {
  return Container(...);
}

// ✅ GOOD: Use named parameters
Text(
  'Hello',
  style: TextStyle(fontSize: 16),
  textAlign: TextAlign.center,
)

// ✅ GOOD: Proper StatefulWidget lifecycle
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize
  }
  
  @override
  void dispose() {
    // Clean up controllers, listeners
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## Code Quality Standards

### 1. Validation

```dart
// ✅ GOOD: Use validators utility
validator: Validators.validateEmail,

// ❌ BAD: Inline validation
validator: (value) {
  if (value == null || !value.contains('@')) {
    return 'Invalid email';
  }
}
```

### 2. Error Handling

```dart
// ✅ GOOD: Specific error types
try {
  await service.fetchData();
} on NetworkException {
  // Handle network error
} on AuthException {
  // Handle auth error
} catch (e) {
  // Handle unknown error
}

// ✅ GOOD: Use Failures for business logic
Future<Either<Failure, User>> login() async {
  try {
    final user = await _auth.signIn();
    return Right(user);
  } catch (e) {
    return Left(AuthFailure.fromException(e));
  }
}
```

### 3. Null Safety

```dart
// ✅ GOOD: Use nullability correctly
String? nullableString;
String nonNullableString = 'value';

// ✅ GOOD: Null-aware operators
final name = user?.name ?? 'Guest';
final length = text?.length;

// ✅ GOOD: Late initialization (use sparingly)
late final String userId;

@override
void initState() {
  super.initState();
  userId = widget.user.id;
}
```

### 4. Async/Await

```dart
// ✅ GOOD: Proper async handling
Future<void> fetchData() async {
  try {
    final data = await service.getData();
    setState(() => _data = data);
  } catch (e) {
    // Handle error
  }
}

// ✅ GOOD: Check mounted before setState
if (mounted) {
  setState(() => _isLoading = false);
}

// ✅ GOOD: Use FutureBuilder/StreamBuilder
StreamBuilder<List<Item>>(
  stream: itemsStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView(...);
    }
    return LoadingSkeleton();
  },
)
```

## Security Standards

### Input Validation

```dart
// ✅ ALWAYS sanitize user input
final sanitizedEmail = Validators.sanitizeInput(email).toLowerCase().trim();
final sanitizedName = Validators.sanitizeInput(name).trim();

// ✅ ALWAYS validate before processing
final emailError = Validators.validateEmail(email);
if (emailError != null) {
  throw ValidationException(errors: {'email': emailError});
}
```

### Password Handling

```dart
// ✅ GOOD: Strong password requirements
Validators.validatePassword(password, requireStrong: true)

// ✅ GOOD: Never log passwords
AppLogger.auth('Login attempt for $email'); // No password!

// ❌ BAD: Logging sensitive data
AppLogger.auth('Login: $email / $password'); // NEVER!
```

### API Keys & Secrets

```dart
// ✅ GOOD: Use environment variables (future)
const apiKey = String.fromEnvironment('API_KEY');

// ✅ GOOD: Use flutter_secure_storage for tokens
await storage.write(key: 'auth_token', value: token);

// ❌ BAD: Hardcoded secrets
const apiKey = 'abc123secret'; // NEVER!
```

## Performance Standards

### Minimize Rebuilds

```dart
// ✅ GOOD: Use const
const Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// ✅ GOOD: Use Riverpod select
final name = ref.watch(userProvider.select((user) => user.name));

// ❌ BAD: Watching entire provider
final user = ref.watch(userProvider); // Rebuilds on any change
```

### Optimize Lists

```dart
// ✅ GOOD: Use ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(items[index]),
)

// ✅ GOOD: Provide keys for list items
ListView.builder(
  itemBuilder: (context, index) {
    return ItemCard(
      key: Key(items[index].id),
      item: items[index],
    );
  },
)
```

### Lazy Loading

```dart
// ✅ GOOD: Pagination for large datasets
Stream<List<Item>> getItems({int limit = 20}) {
  return _firestore
    .collection('items')
    .limit(limit)
    .snapshots()
    .map(...);
}
```

## Testing Standards

### Unit Tests

```dart
group('UserService', () {
  late UserService service;
  
  setUp(() {
    service = UserService();
  });
  
  test('should return user when login succeeds', () async {
    final user = await service.login('test@test.com', 'password');
    expect(user, isNotNull);
    expect(user!.email, 'test@test.com');
  });
});
```

### Widget Tests

```dart
testWidgets('LoginScreen should display email field', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: LoginScreen()),
  );
  
  expect(find.byType(TextFormField), findsNWidgets(2));
});
```

## Documentation Standards

### Class Documentation

```dart
/// Service for managing user authentication.
/// 
/// Handles login, registration, and session management
/// with Firebase Authentication.
class AuthService {
  /// Attempts to login with email and password.
  /// 
  /// Throws [AuthException] if credentials are invalid.
  /// Returns [UserModel] on success.
  Future<UserModel?> login(String email, String password) async {
    // ...
  }
}
```

### Function Documentation

```dart
/// Validates email format.
/// 
/// Returns `null` if valid, error message if invalid.
/// 
/// Example:
/// ```dart
/// final error = Validators.validateEmail('test@example.com');
/// if (error != null) {
///   // Handle error
/// }
/// ```
static String? validateEmail(String? value) {
  // ...
}
```

## Git Commit Standards

### Commit Message Format

```
type(scope): subject

body (optional)
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

### Examples

```bash
feat(auth): add password strength meter

fix(stock): prevent negative stock quantities

docs(readme): update installation instructions

refactor(validators): extract validation logic to utility
```

## Code Review Checklist

Before submitting code:

- [ ] All tests pass (`flutter test`)
- [ ] No analyzer errors (`flutter analyze`)
- [ ] Code is formatted (`dart format .`)
- [ ] No print statements (use AppLogger)
- [ ] Proper error handling
- [ ] Input validation & sanitization
- [ ] Documentation added/updated
- [ ] No hardcoded values
- [ ] Follows naming conventions
- [ ] No TODO comments in production code

## Tools & Linters

### Recommended VS Code Extensions

- Dart
- Flutter
- Error Lens
- GitLens
- Better Comments

### analysis_options.yaml

```yaml
linter:
  rules:
    - avoid_print
    - prefer_const_constructors
    - use_key_in_widget_constructors
    - prefer_final_fields
    - unnecessary_null_checks
```

## References

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://flutter.dev/docs/development/best-practices)
- [Riverpod Documentation](https://riverpod.dev)
