# DTO Architecture Diagram

## Overview

This document provides a visual representation of the DTO architecture for the My Book Library application.

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  (Widgets, Forms, Screens)                                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   Service Layer                              │
│  (BookService, SessionService, GenreService)                 │
│  ▪ Uses DTOs for all API operations                          │
│  ▪ Converts between DTOs and entities                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                     DTO Layer                                │
│  (types.dart)                                                │
│  ▪ BookListItemDto, CreateBookDto, UpdateBookDto            │
│  ▪ ReadingSessionDto, EndReadingSessionDto                  │
│  ▪ GenreDto, GenreEmbeddedDto                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  API/Supabase Layer                          │
│  (Supabase Client)                                           │
│  ▪ REST endpoints via PostgREST                              │
│  ▪ RPC functions                                             │
│  ▪ Row Level Security (RLS)                                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                 Database Layer                               │
│  (PostgreSQL via Supabase)                                   │
│  ▪ books, reading_sessions, genres tables                    │
│  ▪ Triggers, constraints, RLS policies                       │
└─────────────────────────────────────────────────────────────┘
```

## DTO Flow Diagrams

### Books Flow

```
CREATE BOOK FLOW:
┌──────────┐       ┌──────────────┐       ┌─────────┐       ┌──────────┐
│ UI Form  │──────▶│CreateBookDto │──────▶│Supabase │──────▶│Database  │
└──────────┘       │.toRequestJson│       │REST API │       │(books)   │
                   └──────────────┘       └─────────┘       └──────────┘
                                                │
                                                ▼
                   ┌──────────────┐       ┌─────────┐
                   │BookDetailDto │◀──────│Response │
                   │.fromJson     │       │JSON     │
                   └──────────────┘       └─────────┘
                          │
                          ▼
                   ┌──────────┐
                   │UI Display│
                   └──────────┘

UPDATE BOOK FLOW:
┌──────────┐       ┌──────────────┐       ┌─────────┐       ┌──────────┐
│ UI Form  │──────▶│UpdateBookDto │──────▶│Supabase │──────▶│Database  │
└──────────┘       │.toRequestJson│       │PATCH    │       │(books)   │
                   └──────────────┘       └─────────┘       └──────────┘
                                                │
                                                ▼
                   ┌──────────────┐       ┌─────────┐
                   │BookDetailDto │◀──────│Response │
                   │.fromJson     │       │JSON     │
                   └──────────────┘       └─────────┘

LIST BOOKS FLOW:
┌──────────┐       ┌─────────┐       ┌───────────────────┐       ┌──────────┐
│UI Screen │──────▶│Supabase │──────▶│Database           │──────▶│Response  │
└──────────┘       │SELECT   │       │(books + genres)   │       │JSON[]    │
                   └─────────┘       └───────────────────┘       └──────────┘
                                                                        │
                                                                        ▼
                                                              ┌──────────────────┐
                                                              │BookListItemDto[] │
                                                              │.fromJson (each)  │
                                                              └──────────────────┘
                                                                        │
                                                                        ▼
                                                                  ┌──────────┐
                                                                  │UI Display│
                                                                  └──────────┘
```

### Reading Sessions Flow

```
END SESSION FLOW:
┌──────────┐       ┌─────────────────────┐       ┌─────────┐       ┌──────────┐
│ Session  │──────▶│EndReadingSessionDto │──────▶│RPC      │──────▶│Database  │
│ Tracker  │       │.toRequestJson       │       │Function │       │+ Logic   │
└──────────┘       └─────────────────────┘       └─────────┘       └──────────┘
                                                       │
                                                       │ Creates session
                                                       │ Updates book progress
                                                       │ Auto-finishes if done
                                                       │
                                                       ▼
                                                  ┌─────────┐
                                                  │Session  │
                                                  │ID       │
                                                  └─────────┘

LIST SESSIONS FLOW:
┌──────────┐       ┌─────────┐       ┌──────────────────┐       ┌─────────────────┐
│UI Screen │──────▶│Supabase │──────▶│Database          │──────▶│ReadingSessionDto│
└──────────┘       │SELECT   │       │(reading_sessions)│       │.fromJson (each) │
                   └─────────┘       └──────────────────┘       └─────────────────┘
```

## DTO Type Hierarchy

```
SupadartClass (abstract)
    │
    ├── Books (entity)
    ├── ReadingSessions (entity)
    └── Genres (entity)

Book DTOs:
    ┌─────────────────┐
    │BookListItemDto  │ ◀── Response (with embedded genre)
    │BookDetailDto    │ ◀── Response (alias)
    │CreateBookDto    │ ◀── Command (create)
    │UpdateBookDto    │ ◀── Command (update)
    └─────────────────┘

Session DTOs:
    ┌───────────────────────┐
    │ReadingSessionDto      │ ◀── Response
    │EndReadingSessionDto   │ ◀── Command (RPC)
    └───────────────────────┘

Genre DTOs:
    ┌─────────────────┐
    │GenreDto         │ ◀── Response
    │GenreEmbeddedDto │ ◀── Embedded in books
    └─────────────────┘
```

## Data Flow Examples

### Example 1: User Creates a Book

```
1. User fills form
   ├─ Title: "The Hobbit"
   ├─ Author: "J.R.R. Tolkien"
   ├─ Pages: 310
   └─ Genre: "Fantasy"

2. UI creates CreateBookDto
   CreateBookDto(
     title: "The Hobbit",
     author: "J.R.R. Tolkien",
     pageCount: 310,
     genreId: "uuid-here"
   )

3. Service calls toRequestJson()
   {
     "title": "The Hobbit",
     "author": "J.R.R. Tolkien",
     "page_count": 310,
     "genre_id": "uuid-here"
   }

4. Supabase inserts to database
   ├─ Sets user_id from JWT
   ├─ Generates id
   ├─ Sets timestamps
   └─ Sets defaults (status=unread, last_read_page_number=0)

5. Database returns inserted row
   {
     "id": "new-uuid",
     "user_id": "user-uuid",
     "title": "The Hobbit",
     ... (all fields)
     "genres": {"name": "Fantasy"}
   }

6. Service converts to BookDetailDto
   BookDetailDto.fromJson(response)

7. UI displays the new book
```

### Example 2: User Completes Reading Session

```
1. Session tracker records
   ├─ Start: 18:00
   ├─ End: 18:30
   ├─ Last page: 150
   └─ Book ID: "book-uuid"

2. UI creates EndReadingSessionDto
   EndReadingSessionDto(
     bookId: "book-uuid",
     startTime: DateTime(2025, 10, 12, 18, 0),
     endTime: DateTime(2025, 10, 12, 18, 30),
     lastReadPage: 150
   )

3. Service calls toRequestJson()
   {
     "p_book_id": "book-uuid",
     "p_start_time": "2025-10-12T18:00:00Z",
     "p_end_time": "2025-10-12T18:30:00Z",
     "p_last_read_page": 150
   }

4. RPC function executes
   ├─ Calculates duration (30 minutes)
   ├─ Calculates pages read (150 - previous)
   ├─ Creates reading_sessions record
   ├─ Updates book.last_read_page_number
   └─ Auto-finishes if last_read = page_count

5. Returns session ID
   "session-uuid"

6. UI fetches updated book and displays progress
```

## Entity-DTO Mapping

```
Books Entity Fields → DTO Mappings:

Database Field          │ Entity Property      │ DTO Property
────────────────────────┼─────────────────────┼──────────────────
id                      │ id                  │ id
user_id                 │ userId              │ userId
genre_id                │ genreId             │ genreId
title                   │ title               │ title
author                  │ author              │ author
page_count              │ pageCount           │ pageCount
cover_url               │ coverUrl            │ coverUrl
isbn                    │ isbn                │ isbn
publisher               │ publisher           │ publisher
publication_year        │ publicationYear     │ publicationYear
status                  │ status (enum)       │ status (enum)
last_read_page_number   │ lastReadPageNumber  │ lastReadPageNumber
created_at              │ createdAt           │ createdAt
updated_at              │ updatedAt           │ updatedAt
(relation)              │ -                   │ genres (embedded)
```

## Freezed Generated Methods

```
BookListItemDto
    ├── fromJson(Map<String, dynamic>) → BookListItemDto
    ├── toJson() → Map<String, dynamic>
    ├── copyWith({...}) → BookListItemDto
    ├── toString() → String
    ├── operator ==(other) → bool
    └── hashCode → int

CreateBookDto
    ├── fromJson(Map<String, dynamic>) → CreateBookDto
    ├── toJson() → Map<String, dynamic>
    ├── toRequestJson() → Map<String, dynamic>  ← Custom method
    ├── copyWith({...}) → CreateBookDto
    ├── toString() → String
    ├── operator ==(other) → bool
    └── hashCode → int
```

## State Management Integration

```
┌─────────────┐
│   Provider  │ (or Riverpod/Bloc)
│  BookState  │
└──────┬──────┘
       │
       ├── List<BookListItemDto> books
       ├── BookDetailDto? selectedBook
       ├── bool isLoading
       └── String? error
       │
       ▼
┌─────────────┐
│BookService  │
└──────┬──────┘
       │
       ├── getAllBooks() → List<BookListItemDto>
       ├── getBookById(id) → BookDetailDto?
       ├── createBook(CreateBookDto) → BookDetailDto
       └── updateBook(id, UpdateBookDto) → BookDetailDto
```

## Error Handling Flow

```
┌──────────┐       ┌──────────┐       ┌─────────┐
│   DTO    │──────▶│ Service  │──────▶│Supabase │
└──────────┘       └────┬─────┘       └────┬────┘
                        │                  │
                        │                  ▼
                        │            ┌──────────────┐
                        │            │PostgrestError│
                        │            └──────┬───────┘
                        │                   │
                        │                   ▼
                        │            ┌──────────────┐
                        ◀────────────│  Catch &     │
                                     │  Handle      │
                                     └──────┬───────┘
                                            │
                                            ▼
                                     ┌──────────────┐
                                     │Show Error    │
                                     │in UI         │
                                     └──────────────┘
```

## Best Practices Summary

```
✅ DO:
    ├── Use toRequestJson() for API calls
    ├── Use fromJson() for responses
    ├── Use copyWith() for modifications
    ├── Handle null values properly
    └── Convert entities via factory constructors

❌ DON'T:
    ├── Modify .freezed.dart or .g.dart files
    ├── Use toJson() for API requests
    ├── Mutate DTO objects (they're immutable)
    ├── Forget to regenerate after changes
    └── Skip null checks on optional fields
```

## Performance Considerations

```
Code Generation (Build Time)
    ├── Freezed: ~7s
    ├── json_serializable: ~3s
    └── Total: ~10s one-time cost

Runtime Performance
    ├── fromJson: O(1) per field
    ├── toJson: O(1) per field
    ├── copyWith: O(n) field count
    ├── Equality: O(n) field count
    └── No reflection overhead
```

## Testing Strategy

```
Unit Tests
    ├── DTO Serialization
    │   ├── fromJson round-trip
    │   ├── toJson round-trip
    │   └── toRequestJson null filtering
    │
    ├── DTO Operations
    │   ├── copyWith modifications
    │   ├── Equality comparison
    │   └── Factory constructors
    │
    └── Edge Cases
        ├── Null handling
        ├── Enum conversion
        └── DateTime UTC handling

Integration Tests
    ├── Supabase API calls
    ├── RPC function calls
    └── Full CRUD operations
```

---

This architecture ensures type safety, maintainability, and clear separation of concerns throughout the application.

