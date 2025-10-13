# DTOs Quick Reference Card

## Quick Import
```dart
import 'package:my_book_library/models/types.dart';
import 'package:my_book_library/models/database_types.dart';
```

## API Operations Cheat Sheet

### 📚 Books

#### List All Books
```dart
final response = await supabase.books
  .select('*, genres(name)')
  .order('title', ascending: true);
  
final books = (response as List)
  .map((json) => BookListItemDto.fromJson(json))
  .toList();
```

#### Get Single Book
```dart
final response = await supabase.books
  .select('*, genres(name)')
  .eq('id', bookId)
  .maybeSingle();
  
final book = response != null ? BookDetailDto.fromJson(response) : null;
```

#### Create Book
```dart
final dto = CreateBookDto(
  title: 'The Hobbit',
  author: 'J.R.R. Tolkien',
  pageCount: 310,
  genreId: 'genre-id-here',
);

final response = await supabase.books
  .insert(dto.toRequestJson())
  .select('*, genres(name)')
  .single();
  
final newBook = BookDetailDto.fromJson(response);
```

#### Update Book
```dart
final dto = UpdateBookDto(
  status: BOOK_STATUS.finished,
  lastReadPageNumber: 310,
);

final response = await supabase.books
  .update(dto.toRequestJson())
  .eq('id', bookId)
  .select('*, genres(name)')
  .single();
  
final updatedBook = BookDetailDto.fromJson(response);
```

#### Delete Book
```dart
await supabase.books.delete().eq('id', bookId);
```

### 📖 Reading Sessions

#### List Sessions for Book
```dart
final response = await supabase.reading_sessions
  .select()
  .eq('book_id', bookId)
  .order('created_at', ascending: false);
  
final sessions = (response as List)
  .map((json) => ReadingSessionDto.fromJson(json))
  .toList();
```

#### End Reading Session (RPC)
```dart
final dto = EndReadingSessionDto(
  bookId: bookId,
  startTime: sessionStart,
  endTime: DateTime.now(),
  lastReadPage: 150,
);

final sessionId = await supabase.rpc(
  'end_reading_session',
  params: dto.toRequestJson(),
);
```

### 🏷️ Genres

#### List All Genres
```dart
final response = await supabase.genres
  .select()
  .order('name', ascending: true);
  
final genres = (response as List)
  .map((json) => GenreDto.fromJson(json))
  .toList();
```

## DTO Reference Table

| DTO | Purpose | API Method | Endpoint |
|-----|---------|------------|----------|
| `BookListItemDto` | List/Get books | GET | `/rest/v1/books` |
| `BookDetailDto` | Get single book | GET | `/rest/v1/books?id=eq.{id}` |
| `CreateBookDto` | Create book | POST | `/rest/v1/books` |
| `UpdateBookDto` | Update book | PATCH | `/rest/v1/books?id=eq.{id}` |
| `ReadingSessionDto` | List sessions | GET | `/rest/v1/reading_sessions` |
| `EndReadingSessionDto` | End session | POST | `/rest/v1/rpc/end_reading_session` |
| `GenreDto` | List genres | GET | `/rest/v1/genres` |
| `GenreEmbeddedDto` | Embedded genre | N/A | (embedded in books) |

## Field Mappings

### CreateBookDto Required Fields
- ✅ `title` (String)
- ✅ `author` (String)
- ✅ `pageCount` (int)

### CreateBookDto Optional Fields
- ⭕ `genreId` (String?)
- ⭕ `coverUrl` (String?)
- ⭕ `isbn` (String?)
- ⭕ `publisher` (String?)
- ⭕ `publicationYear` (int?)

### UpdateBookDto (All Optional)
- ⭕ `genreId` (String?)
- ⭕ `title` (String?)
- ⭕ `author` (String?)
- ⭕ `pageCount` (int?)
- ⭕ `coverUrl` (String?)
- ⭕ `isbn` (String?)
- ⭕ `publisher` (String?)
- ⭕ `publicationYear` (int?)
- ⭕ `status` (BOOK_STATUS?)
- ⭕ `lastReadPageNumber` (int?)

### EndReadingSessionDto Required Fields
- ✅ `bookId` (String)
- ✅ `startTime` (DateTime)
- ✅ `endTime` (DateTime)
- ✅ `lastReadPage` (int)

## Book Status Enum

```dart
enum BOOK_STATUS {
  unread,      // Book hasn't been started
  in_progress, // Currently reading
  finished,    // Completed reading
  abandoned,   // Stopped reading (not completed)
  planned      // Planning to read
}
```

### Usage
```dart
// In CreateBookDto - defaults to 'unread'
// In UpdateBookDto
final dto = UpdateBookDto(status: BOOK_STATUS.finished);
```

## Common Patterns

### Filter Books by Status
```dart
final statusString = BOOK_STATUS.in_progress.toString().split('.').last;
final response = await supabase.books
  .select('*, genres(name)')
  .eq('status', statusString);
```

### Filter Books by Genre
```dart
final response = await supabase.books
  .select('*, genres(name)')
  .eq('genre_id', genreId);
```

### Mark Book as Finished
```dart
final book = await getBookById(bookId);
final dto = UpdateBookDto(
  status: BOOK_STATUS.finished,
  lastReadPageNumber: book.pageCount,
);
await updateBook(bookId, dto);
```

### Calculate Reading Progress
```dart
final progress = (book.lastReadPageNumber / book.pageCount * 100).round();
print('Progress: $progress%');
```

### Using copyWith
```dart
final book = BookListItemDto(...);
final updated = book.copyWith(title: 'New Title');
```

### JSON Conversion
```dart
// To JSON
final json = book.toJson();

// From JSON
final book = BookListItemDto.fromJson(json);
```

## Error Handling

```dart
try {
  final response = await supabase.books
    .insert(createDto.toRequestJson())
    .select('*, genres(name)')
    .single();
  final book = BookDetailDto.fromJson(response);
} on PostgrestException catch (e) {
  // Handle Supabase errors
  print('Error: ${e.message}');
} catch (e) {
  // Handle other errors
  print('Unexpected error: $e');
}
```

## Validation Tips

✅ **DO**:
- Use `toRequestJson()` for all API requests
- Check for null values before accessing optional fields
- Convert DateTime to UTC for consistency
- Use the enum values for status

❌ **DON'T**:
- Modify `.freezed.dart` or `.g.dart` files
- Use `toJson()` for API requests (use `toRequestJson()` instead)
- Forget to regenerate code after changing DTOs
- Hardcode status strings (use enum)

## Regenerating Code

After modifying `types.dart`:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Getting Help

- 📖 Full documentation: `lib/models/README.md`
- 💡 Examples: `lib/models/example_usage.dart`
- 📊 Implementation details: `lib/models/DTO_IMPLEMENTATION_SUMMARY.md`

