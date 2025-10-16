# Quick Reference: Auto-Refresh Pattern

## 🚀 TL;DR

When a screen modifies data, return `true`. Parent screens listen for `true` and refresh.

## Pattern Overview

### 1. Screen That Modifies Data (Child)

```dart
// After saving/deleting data
Navigator.of(context).pop(true);  // Return true
```

### 2. Screen That Displays List (Parent)

```dart
// Navigate and wait for result
final result = await Navigator.push(
  MaterialPageRoute(builder: (context) => ChildScreen()),
);

// Refresh if data changed
if (result == true && context.mounted) {
  context.read<HomeScreenBloc>().add(RefreshBooksEvent());
}
```

## Real Examples from Your App

### Example 1: Add Book Button

```dart
// lib/features/home/view/home_screen_content.dart

FloatingActionButton(
  onPressed: () async {
    final result = await Navigator.push(
      MaterialPageRoute(builder: (context) => const AddBookScreen()),
    );
    
    if (result == true && context.mounted) {
      context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
    }
  },
  child: const Icon(Icons.add),
)
```

### Example 2: Book Grid Tile

```dart
// lib/features/home/widgets/book_grid.dart

BookGridTile(
  book: book,
  onTap: () async {
    final result = await Navigator.push(
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(bookId: book.id),
      ),
    );
    
    if (result == true && context.mounted) {
      context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
    }
  },
)
```

### Example 3: Delete Book

```dart
// lib/features/book_detail/book_detail_screen.dart

// In BLoC listener
if (state is BookDetailsActionSuccess) {
  if (state.shouldNavigateBack) {
    Navigator.of(context).pop(true);  // Returns true to trigger refresh
  }
}
```

### Example 4: Save Book

```dart
// lib/features/add_book/view/book_form_screen.dart

// When book is saved
if (state is BookSaved) {
  Navigator.of(context).pop(true);  // Returns true
}
```

## Common Patterns

### Pattern: Single Screen Navigation

```dart
// Parent
onPressed: () async {
  final result = await Navigator.push(...);
  if (result == true && context.mounted) {
    refresh();
  }
}

// Child
onSave: () {
  Navigator.pop(context, true);
}
```

### Pattern: Nested Navigation (Your Add Book Flow)

```dart
// Home Screen
final result = await Navigator.push(AddBookScreen());
if (result == true) refresh();

// Add Book Screen (intermediate)
final formResult = await Navigator.push(BookFormScreen());
if (formResult == true) {
  Navigator.pop(context, true);  // Pass result up
}

// Book Form Screen (final)
onSave: () {
  Navigator.pop(context, true);  // Start the chain
}
```

## Avoiding Async Context Warnings

### ❌ Wrong (causes lint warning)

```dart
listener: (context, state) async {
  if (state is BookFound) {
    final result = await Navigator.of(context).push(...);  // ❌
    if (result == true && context.mounted) {  
      Navigator.of(context).pop(true);  // ❌ Using context after await
    }
  }
}
```

### ✅ Correct (no warnings)

```dart
listener: (context, state) async {
  if (state is BookFound) {
    final navigator = Navigator.of(context);  // ✅ Capture before await
    final result = await navigator.push(...);
    if (result == true) {
      navigator.pop(true);  // ✅ Use captured reference
    }
  }
}
```

## Decision Tree

```
Does this screen modify data?
    ├─ YES → Return true when done: Navigator.pop(context, true)
    └─ NO → Normal navigation: Navigator.pop(context)

Does this screen show a list that could be outdated?
    ├─ YES → Listen for result and refresh if true
    └─ NO → Normal navigation
```

## When to Use

Use this pattern when:
- ✅ Screen creates new data
- ✅ Screen updates existing data
- ✅ Screen deletes data
- ✅ Parent screen displays a list of that data

Don't use when:
- ❌ Just viewing data (no changes)
- ❌ Changes don't affect parent screen
- ❌ Parent uses realtime updates instead

## Checklist for Adding Auto-Refresh to New Screens

1. **Identify data modification screens**
   - [ ] Add/Create screens
   - [ ] Edit/Update screens
   - [ ] Delete operations

2. **Modify child screen**
   - [ ] Change `Navigator.pop()` to `Navigator.pop(true)` after save/delete
   - [ ] Test that it returns to parent

3. **Modify parent screen**
   - [ ] Add `await` to navigation call
   - [ ] Check result: `if (result == true && context.mounted)`
   - [ ] Trigger refresh event

4. **Test**
   - [ ] Perform operation in child
   - [ ] Verify parent list updates
   - [ ] Check no lint warnings

## Common Mistakes

### Mistake 1: Forgetting `await`

```dart
// ❌ Wrong
Navigator.push(...);  // No await, can't get result

// ✅ Correct
final result = await Navigator.push(...);
```

### Mistake 2: Not checking result

```dart
// ❌ Wrong
await Navigator.push(...);
refresh();  // Always refreshes!

// ✅ Correct
final result = await Navigator.push(...);
if (result == true) refresh();  // Only refresh if needed
```

### Mistake 3: Using wrong pop syntax

```dart
// ❌ Wrong
Navigator.pop(true, context);  // Wrong parameter order

// ✅ Correct
Navigator.pop(context, true);  // Context first, then result
```

### Mistake 4: Breaking the chain in nested navigation

```dart
// ❌ Wrong - AddBookScreen
final result = await Navigator.push(BookFormScreen());
// Forgot to propagate result to home screen!

// ✅ Correct - AddBookScreen
final result = await Navigator.push(BookFormScreen());
if (result == true) {
  Navigator.pop(context, true);  // Pass it up!
}
```

## Debugging Tips

### Check 1: Is result being returned?

```dart
// In child screen
print('Returning result: true');
Navigator.pop(context, true);
```

### Check 2: Is result being received?

```dart
// In parent screen
final result = await Navigator.push(...);
print('Received result: $result');
```

### Check 3: Is refresh being triggered?

```dart
// In parent screen
if (result == true && context.mounted) {
  print('Triggering refresh!');
  context.read<HomeScreenBloc>().add(const RefreshBooksEvent());
}
```

### Check 4: Is BLoC receiving event?

```dart
// In HomeScreenBloc
void _onRefreshBooks(...) {
  print('RefreshBooksEvent received');
  // ...
}
```

## Performance Tips

1. **Only refresh what changed**
   - ✅ Return `true` only when data actually changed
   - ❌ Don't return `true` on cancel

2. **Use specific refresh events**
   - ✅ Could create `BookAddedEvent`, `BookDeletedEvent` for targeted updates
   - Current: Generic `RefreshBooksEvent` (simple and effective)

3. **Consider caching**
   - If refreshes are slow, add client-side caching
   - See `.ai/list-books-implementation-plan.md` for cache implementation

4. **Avoid unnecessary navigations**
   - If staying on same screen after update, don't navigate
   - Example: Marking as read stays on detail screen (good UX)

## Summary

**Pattern:**
```dart
Child: pop(true) → Parent: if(result) refresh()
```

**That's it!** Simple, effective, no magic. 🎉

