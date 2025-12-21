# Architecture Overview - Manage Your Logistic

## System Architecture

This application follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (Screens, Widgets, Providers)      │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│      Business Logic Layer           │
│    (Services, Use Cases)            │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Data Layer                  │
│  (Firebase, Local Storage)          │
└─────────────────────────────────────┘
```

## Project Structure

```
lib/
├── core/                    # Core functionality (app-wide)
│   ├── config/             # Configuration & constants
│   │   └── security_constants.dart
│   ├── errors/             # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── security/           # Security features
│   │   └── rate_limiter.dart
│   └── utils/              # Utilities
│       └── validators.dart
│
├── models/                 # Data models
│   ├── user_model.dart
│   ├── item_model.dart
│   └── stock_*.dart
│
├── providers/              # Riverpod providers (state management)
│   ├── auth_provider.dart
│   ├── item_provider.dart
│   └── stock_provider.dart
│
├── screens/                # UI screens
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   └── ...
│
├── services/               # Business logic & data access
│   ├── auth_service.dart
│   ├── item_service.dart
│   └── stock_service.dart
│
├── utils/                  # General utilities
│   ├── app_logger.dart
│   └── responsive_utils.dart
│
├── widgets/                # Reusable widgets
│   ├── empty_state_widget.dart
│   └── loading_skeleton.dart
│
└── main.dart              # App entry point
```

## Key Design Patterns

### 1. Repository Pattern (Ready for Implementation)
```dart
// Abstract repository interface
abstract class ItemRepository {
  Future<List<Item>> getItems();
  Future<Item> getItemById(String id);
  Future<void> createItem(Item item);
}

// Implementation (Firebase)
class ItemRepositoryImpl implements ItemRepository {
  final FirebaseFirestore _firestore;
  
  @override
  Future<List<Item>> getItems() async {
    // Firebase implementation
  }
}
```

### 2. Provider Pattern (State Management)
Using **Riverpod** for dependency injection and state management:

```dart
// Service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// State provider
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.asyncMap(...);
});
```

### 3. Model-View-ViewModel (MVVM)
- **Model**: Data models (`lib/models/`)
- **View**: Screens and widgets (`lib/screens/`, `lib/widgets/`)
- **ViewModel**: Providers (`lib/providers/`)

## Data Flow

### Example: User Login Flow

```
1. User enters credentials
   ↓
2. LoginScreen validates input (Validators)
   ↓
3. LoginScreen calls AuthService.login()
   ↓
4. AuthService:
   - Sanitizes input
   - Checks rate limiting
   - Calls Firebase Auth
   - Records attempt
   ↓
5. On success: Updates AuthStateProvider
   ↓
6. UI automatically updates (Riverpod)
```

### Example: Item CRUD Flow

```
1. User action (create/update/delete)
   ↓
2. Screen calls ItemService
   ↓
3. ItemService validates data
   ↓
4. ItemService interacts with Firestore
   ↓
5. StreamProvider detects changes
   ↓
6. UI automatically updates
```

## Security Architecture

### Multi-Layer Security

```
┌─────────────────────────────────────┐
│  1. Client-Side Validation          │
│     (Validators utility)             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  2. Rate Limiting                   │
│     (LoginRateLimiter)              │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  3. Firebase Auth                   │
│     (Email/Password)                │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│  4. Firestore Security Rules        │
│     (Role-based access)             │
└─────────────────────────────────────┘
```

### Security Features

1. **Password Validation**
   - Minimum 8 characters
   - Requires uppercase, lowercase, number
   - Strength meter in UI

2. **Rate Limiting**
   - Max 5 login attempts per 15 minutes
   - 30-minute lockout after max attempts
   - Per-email tracking

3. **Input Sanitization**
   - All user inputs are sanitized
   - XSS prevention
   - Null byte removal

4. **Firestore Security Rules**
   - Role-based access (admin, supervisor, staff)
   - Data validation (e.g., no negative stock)
   - Audit trail (immutable stock moves)

## State Management

Using **Riverpod** for:
- Dependency injection
- State management
- Reactive UI updates

### Provider Types Used

```dart
// 1. Provider - For read-only objects
final authServiceProvider = Provider<AuthService>(...);

// 2. StreamProvider - For streams
final itemsStreamProvider = StreamProvider<List<Item>>(...);

// 3. StateProvider - For simple state
final searchQueryProvider = StateProvider<String>(...);

// 4. FutureProvider - For async operations
final userDataProvider = FutureProvider<UserModel>(...);
```

## Error Handling Strategy

### Failure Hierarchy

```
Failure (abstract)
├── ServerFailure
├── NetworkFailure
├── AuthFailure
├── ValidationFailure
├── CacheFailure
├── PermissionFailure
├── NotFoundFailure
├── BusinessFailure
└── UnknownFailure
```

### Error Flow

```
Exception (Data Layer)
    ↓
Catch & Convert to Failure
    ↓
Return to Service/Repository
    ↓
UI displays user-friendly message
```

## Testing Strategy

### Test Pyramid

```
        ┌─────────┐
        │   E2E   │  (Future)
        ├─────────┤
        │ Widget  │  (Examples created)
        ├─────────┤
        │  Unit   │  (Examples created)
        └─────────┘
```

### Test Coverage Goals

- **Unit Tests**: 70%+ for core logic
- **Widget Tests**: Key user flows
- **Integration Tests**: Critical paths

## Firebase Architecture

### Collections Structure

```
firestore/
├── users/
│   └── {userId}
│       ├── uid
│       ├── email
│       ├── name
│       └── role
│
├── items/
│   └── {itemId}
│       ├── name
│       ├── sku
│       ├── barcode
│       └── ...
│
├── stock_levels/
│   └── {levelId}
│       ├── itemId
│       ├── locationId
│       ├── qty
│       └── ...
│
└── stock_moves/
    └── {moveId}
        ├── itemId
        ├── qty
        ├── type (inbound/outbound)
        ├── userId
        └── timestamp
```

## Performance Optimizations

1. **Firestore Queries**
   - Indexed queries for fast retrieval
   - Limited results with pagination
   - Real-time listeners only where needed

2. **Widget Rebuilds**
   - `const` constructors where possible
   - `select` in Riverpod for granular updates
   - Proper use of `Keys` for list items

3. **Loading States**
   - Skeleton screens for better UX
   - Shimmer animations
   - Progressive loading

## Future Architecture Considerations

### Planned Improvements

1. **Offline Support**
   - Local database (Hive/Drift)
   - Sync mechanism
   - Conflict resolution

2. **Microservices**
   - Cloud Functions for heavy operations
   - Background jobs
   - Email notifications

3. **Analytics**
   - Firebase Analytics integration
   - User behavior tracking
   - Performance monitoring

4. **CI/CD**
   - Automated testing
   - Continuous deployment
   - Build automation

## Best Practices Enforced

✅ Separation of concerns  
✅ Dependency injection  
✅ Error handling with Failures  
✅ Input validation & sanitization  
✅ Security-first approach  
✅ Consistent code style  
✅ Documentation  
✅ Testability  

For implementation details, see [CODING_STANDARDS.md](CODING_STANDARDS.md).
