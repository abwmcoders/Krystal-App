# Krystal App

A modern, responsive Flutter task management application with comprehensive state management, local persistence, and professional UI/UX patterns.

## 📋 Overview

Krystal is a feature-rich todo application built with Flutter, demonstrating modern app architecture patterns, responsive design, and smooth user experience across all device sizes (mobile, tablet, desktop).

### Key Features
- ✅ **Complete CRUD Operations** - Create, read, update, and delete tasks with instant feedback
- 🎯 **Smart Filtering** - View tasks by status (all, completed, pending, reminders with overdue detection)
- 🔍 **Live Search** - Real-time search with AND semantics across task titles and descriptions
- ⏰ **DateTime Management** - Assign start/end times to tasks with visual time pickers
- 📱 **Fully Responsive** - Optimized layouts for mobile (≤600dp), tablet (600-1200dp), and desktop (≥1200dp)
- 💾 **Local Persistence** - Hive-based database with instant data consistency
- ⚡ **Loading States** - Visual feedback with 3-second simulated delays for all operations
- 🎨 **Professional UI** - Material Design with custom dialogs, smooth animations, and empty states
- 📊 **Task Counters** - Real-time badges showing pending, completed, and overdue task counts

## 🏗️ Architecture

### Overall Structure

```
krystal_app/
├── lib/
│   ├── config/
│   │   ├── responsive/          # Responsive design utilities
│   │   └── theme/               # App theming configuration
│   ├── features/
│   │   └── tasks/
│   │       ├── data/            # Repository pattern & data sources
│   │       ├── domain/          # Domain models (Todo entity)
│   │       └── presentation/    # UI layer
│   │           ├── provider/    # Riverpod state management
│   │           ├── screens/     # Screen components
│   │           └── widgets/     # Reusable UI components
│   └── main.dart                # App entry point
└── pubspec.yaml                 # Dependencies
```

### Design Pattern: Clean Architecture with Riverpod

The app follows **Clean Architecture** principles with three distinct layers:

#### 1. **Domain Layer** (`features/tasks/domain/`)
- **Entity**: `Todo` model with HiveObject serialization
- **Pure business logic** - no dependencies on external frameworks
- Fields: `id`, `title`, `description`, `completed`, `startAt`, `endAt`

#### 2. **Data Layer** (`features/tasks/data/`)
- **Repository Pattern**: `TodosRepository` interface + `HiveRepository` implementation
- **Hive Database**: Local key-value storage with type adapters
- CRUD operations: `addTodo()`, `getTodos()`, `updateTodo()`, `deleteTodo()`, `toggleTodo()`

#### 3. **Presentation Layer** (`features/tasks/presentation/`)
- **State Management**: Riverpod with `StateNotifierProvider`
- **UI Components**: Consumer widgets + ConsumerStatefulWidget
- **Responsive Design**: Device-aware sizing and layouts

### State Management Strategy: Riverpod

#### Core Providers

```dart
// Data Provider
final todosProvider = StateNotifierProvider<TodosNotifier, List<Todo>>()
  → Manages complete list of todos with CRUD operations

// Filter Provider
final selectedFilterTodoProvider = StateProvider<TodoFilter>()
  → Tracks current filter (all, completed, pending, reminders)

// Search Provider
final searchQueryProvider = StateProvider<String>()
  → Stores user's search input with real-time filtering

// Computed Provider
final filteredTodosProvider = Provider<List<Todo>>()
  → Combines filter + search with relevance scoring (AND semantics)

// Loading State Providers
final createLoadingProvider = StateProvider<bool>()
final editLoadingProvider = StateProvider<bool>()
final deleteLoadingProvider = StateProvider<bool>()
final toggleLoadingProvider = StateProvider<String?>()
  → Track operation states with 3-second simulated delays

// Feedback Providers
final errorMessageProvider = StateProvider<String?>()
final successMessageProvider = StateProvider<String?>()
  → Display user feedback messages
```

#### TodosNotifier: The Command Center

```dart
class TodosNotifier extends StateNotifier<List<Todo>> {
  // Each operation (create, edit, delete, toggle):
  // 1. Sets loading state to true
  // 2. Clears previous error messages
  // 3. Delays 3 seconds (simulating network)
  // 4. Executes repository operation
  // 5. Refetches full list for consistency
  // 6. Sets success message
  // 7. Clears success message after 2 seconds
  // 8. Handles errors with descriptive messages
}
```

### Database Architecture: Hive

**Why Hive?**
- ✅ Lightweight, fast local storage
- ✅ Type-safe with adapters
- ✅ Automatic serialization
- ✅ No SQL complexity

**Configuration:**
```dart
// main.dart
await Hive.initFlutter();
Hive.registerAdapter(TodoAdapter());
// Auto-clears corrupted data on startup
```

**Data Consistency Pattern:**
- Operations refetch entire list to ensure consistency
- Prevents stale data and sync issues
- Simple but reliable approach for local-only storage

### Responsive Design System

**ResponsiveUtils** provides device-aware sizing:

```dart
// Breakpoints
mobile: < 600dp   (phones)
tablet: 600-1200dp (tablets)
desktop: ≥ 1200dp (large screens)

// Scaling methods
responsiveFontSize()     // 14sp → 16sp
responsiveSize()         // 20dp → 40dp
responsivePadding()      // Proportional padding
responsiveBorderRadius() // Adaptive corners
```

**Applied to all widgets:**
- Font sizes scale smoothly
- Padding/margins adjust per device
- Icon sizes remain touch-friendly
- Dialog widths: 85% (mobile) → 60% (desktop)

### Filtering & Search Logic

#### Filter Enum: Four States
```dart
TodoFilter.all      → All tasks
TodoFilter.completed → Only completed tasks
TodoFilter.pending  → Incomplete, non-overdue tasks
TodoFilter.reminders → Incomplete, overdue tasks
```

#### Smart Reminder Detection
```dart
// Automatic categorization based on endAt timestamp
pending:  endAt == null || endAt.isAfter(now)
reminders: endAt != null && endAt.isBefore(now) // OVERDUE
```

#### Search Algorithm: AND Semantics
```dart
// Example: "flutter riverpod" search
// Only shows tasks containing BOTH words
// Ranked by relevance:
// 1. Exact matches (score: 100)
// 2. Word start matches (score: 50)
// 3. Contains matches (score: 20)
```

### Loading States & User Feedback

**Three-Tier Loading Strategy:**

1. **Visual Indicators**
   - ⏳ Spinning icon in dialog header while loading
   - 🔒 PopScope prevents accidental dismissal
   - 💬 Button text changes: "Create" → "Loading..."
   - 🚫 Disabled inputs and buttons during operation

2. **Simulated Delays**
   ```dart
   // All operations include 3-second delay
   await Future.delayed(const Duration(seconds: 3));
   ```

3. **Feedback Messages**
   - ✅ Success: "Task created successfully!" (clears after 2s)
   - ❌ Error: "Failed to create task: [reason]"
   - 💡 Input validation: "Please enter a title"

### Component Architecture

#### Screens
- **HomeScreen** - Main task list with header, filter controls, FAB
  - Displays filtered tasks or empty state
  - Shows task counters (pending, completed, reminders)
  - Manages bottom navigation and FAB

#### Key Widgets
- **WelcomeCard** - Header with greeting, search bar, counters
- **TodoWidget** - Individual task display with actions
- **CustomDialogNewTodo** - Create/edit dialog with date pickers
- **CustomDialogDeleteTodo** - Confirmation dialog with loading state
- **EmptyStateWidget** - Filter-specific empty state messages
- **CustomNavBar** - Bottom navigation for filter selection

#### Dialogs
- Backdrop blur effect for focus
- PopScope to prevent accidental dismissal during loading
- CircularProgressIndicator while operating
- Responsive sizing based on device

## 🚀 Getting Started

### Prerequisites
- Flutter SDK: ^3.9.2
- Dart: included with Flutter

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd krystal_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_riverpod` | ^2.6.1 | State management |
| `hive` | ^2.2.3 | Local database |
| `hive_flutter` | ^1.1.0 | Flutter integration |
| `google_fonts` | ^6.3.3 | Typography |

## 🧪 Testing the Application

### Test Create Flow
1. Tap FAB to open "New task" dialog
2. Enter title and description
3. Set start/end times (optional)
4. Tap "Create" and watch 3-second loading animation
5. Verify task appears in list with success message

### Test Edit Flow
1. Tap edit icon on any pending task
2. Modify title, description, or dates
3. Tap "Save" and observe loading state
4. Verify changes in list

### Test Delete Flow
1. Tap delete icon on any task
2. Confirm deletion in dialog
3. Watch loading indicator during 3-second delay
4. Task removed with success message

### Test Filtering
1. Use bottom navigation to switch filters
2. Verify correct tasks display:
   - **All**: All tasks
   - **Pending**: Only incomplete, non-overdue
   - **Completed**: Only completed
   - **Reminders**: Incomplete with past end dates

### Test Empty States
1. Delete all tasks or apply strict filter
2. See contextual empty state message
3. Different messages per filter type

### Test Responsive Design
1. Run on different devices:
   - Phone (< 600dp)
   - Tablet (600-1200dp)
   - Emulator desktop mode (> 1200dp)
2. Verify fonts, padding, and layouts scale appropriately

### Test Search
1. Create tasks with various keywords
2. Search with single word (matches all containing it)
3. Search with multiple words (AND semantics)
4. Verify relevance ranking

## 📱 Responsive Breakpoints

| Device Type | Width | Font Size | Padding | Dialog Width |
|-------------|-------|-----------|---------|--------------|
| Mobile | <600dp | 14-16sp | 20-30dp | 85% |
| Tablet | 600-1200dp | 15-17sp | 30-35dp | 70% |
| Desktop | ≥1200dp | 16-18sp | 40dp | 60% |

## 🎨 Design System

**Colors**
- Primary: Blue (#0066FF)
- Accent: Red (#FF0000)
- Backgrounds: White (#FFFFFF)
- Text: Dark Gray (#333333)

**Typography**
- Headlines: Arima (bold, 25-36sp)
- Body: Montserrat (400-500, 14-16sp)
- Responsive scaling per device

**Spacing**
- Card margins: 20-40dp
- Internal padding: 12-16dp
- Gap between items: 8-12dp

## 🔄 Data Flow Example

```
User taps "Create" button
    ↓
CustomDialogNewTodo opens
    ↓
User enters data + taps "Create"
    ↓
_handleSave() validates input
    ↓
createLoadingProvider = true (shows spinner)
    ↓
ref.read(todosProvider.notifier).addTodo()
    ↓
TodosNotifier.addTodo() executes:
  • Sets createLoadingProvider = true
  • Awaits 3 seconds
  • Calls repository.addTodo()
  • Refetches todos from repository
  • Updates todosProvider state
  • Sets successMessageProvider
  ↓
filteredTodosProvider recomputes automatically
    ↓
HomeScreen rebuilds with new task visible
    ↓
Success message displays for 2 seconds
    ↓
Dialog closes
```

## 🛠️ Development Patterns

### Adding a New Feature

1. **Domain**: Create entity in `domain/`
2. **Data**: Add repository methods
3. **Presentation**: Create Riverpod providers
4. **UI**: Build widgets with Consumer pattern

### Modifying State Management

1. Create/update provider in `provider/`
2. Update notifier logic
3. Add to relevant widgets via `ref.watch()`
4. Test refetch behavior

### Extending Responsive Design

1. Add new breakpoint in ResponsiveUtils
2. Update all widgets using new values
3. Test on multiple devices

## 📚 Project Documentation Files

- **LOADING_STATES_IMPLEMENTATION.md** - Detailed loading state documentation
- **LOADING_STATES_FLOW.md** - State transitions and flow diagrams
- **TESTING_GUIDE.md** - Comprehensive testing procedures

## 🤝 Code Quality

- ✅ Clean architecture principles
- ✅ Responsive design best practices
- ✅ Riverpod state management patterns
- ✅ Null safety enabled
- ✅ Strong typing throughout
- ✅ Descriptive error messages
- ✅ Comprehensive comments

## 📝 License

This project is private and for portfolio purposes.

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Hive Documentation](https://docs.hive.im/)
- [Material Design Guidelines](https://material.io/design)
