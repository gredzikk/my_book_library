# Edit Book Feature - Flow Diagram

## User Journey Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         HOME SCREEN                                  │
│                                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  Book 1  │  │  Book 2  │  │  Book 3  │  │  Book 4  │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│       │                                                              │
│       │ (User taps book)                                            │
│       ▼                                                              │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BOOK DETAIL SCREEN                                │
│  ┌──────────────────────────────────────────────────────────┐       │
│  │  ← Back    Szczegóły książki        ✏️ Edit    ⋮ Menu │       │
│  └──────────────────────────────────────────────────────────┘       │
│                                                                      │
│  ┌───────────┐   The Hobbit                                         │
│  │   Cover   │   by J.R.R. Tolkien                                 │
│  │   Image   │   Fantasy • 310 pages                               │
│  └───────────┘                                                       │
│                                                                      │
│  Progress: ████████░░░░░░░░░░░░ 150/310 pages (48%)               │
│                                                                      │
│  [Start Reading Session]  [Mark as Read]                           │
│                                                                      │
│  Reading Session History:                                           │
│  • Session 1: 50 pages ...                                         │
│  • Session 2: 100 pages ...                                        │
│       │                                                              │
│       │ (User taps Edit ✏️ button)                                │
│       ▼                                                              │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BOOK FORM SCREEN (Edit Mode)                      │
│  ┌──────────────────────────────────────────────────────────┐       │
│  │  ← Back    Edytuj książkę                                 │       │
│  └──────────────────────────────────────────────────────────┘       │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ Tytuł *              [The Hobbit              ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ Autor *              [J.R.R. Tolkien          ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ Liczba stron *       [310                     ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ Gatunek              [Fantasy                 ▼]       │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ URL okładki          [https://...             ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ ISBN                 [978-0547928227          ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ Wydawca              [Houghton Mifflin        ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │ Rok wydania          [2012                    ]        │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │        💾  Zapisz zmiany                               │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  * Pola wymagane                                                    │
│       │                                                              │
│       │ (User modifies fields and taps Save)                       │
│       ▼                                                              │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      LOADING & SAVE                                  │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │                      ⏳                                 │         │
│  │           Zapisywanie książki...                       │         │
│  └────────────────────────────────────────────────────────┘         │
│                                                                      │
│  [Processing in background]                                         │
│  1. Validate form data                                              │
│  2. Convert to UpdateBookDto                                        │
│  3. Call BookService.updateBook()                                   │
│  4. Update Supabase database                                        │
│       │                                                              │
│       ▼                                                              │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      SUCCESS MESSAGE                                 │
│                                                                      │
│  ┌────────────────────────────────────────────────────────┐         │
│  │  ✓  Książka została zaktualizowana                    │         │
│  └────────────────────────────────────────────────────────┘         │
│       │                                                              │
│       │ (Auto-dismiss and navigate back)                           │
│       ▼                                                              │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    BOOK DETAIL SCREEN (Refreshed)                    │
│  ┌──────────────────────────────────────────────────────────┐       │
│  │  ← Back    Szczegóły książki        ✏️ Edit    ⋮ Menu │       │
│  └──────────────────────────────────────────────────────────┘       │
│                                                                      │
│  [Updated information displayed]                                    │
│  [All changes reflected]                                            │
│       │                                                              │
│       │ (User goes back to home)                                   │
│       ▼                                                              │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    HOME SCREEN (Refreshed)                           │
│                                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  Book 1  │  │  Book 2  │  │  Book 3  │  │  Book 4  │           │
│  │ UPDATED  │  │          │  │          │  │          │           │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘           │
│                                                                      │
│  [Book list refreshed with updated data]                            │
└─────────────────────────────────────────────────────────────────────┘
```

## Technical Component Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  BookDetailScreen                                                   │
│    │                                                                 │
│    │ _navigateToEditScreen()                                        │
│    │   ├─ Extract book from state (BookDetailDto)                  │
│    │   ├─ Convert to AddBookFormViewModel                          │
│    │   ├─ Provide dependencies (Services via Providers)            │
│    │   └─ Navigate to BookFormScreen                               │
│    │                                                                 │
│    ▼                                                                 │
│  BookFormScreen                                                     │
│    │                                                                 │
│    │ (User edits form and taps Save)                               │
│    │                                                                 │
│    └─► AddBookBloc.add(SaveBook(data, bookId))                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BUSINESS LOGIC LAYER                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  AddBookBloc                                                        │
│    │                                                                 │
│    │ _onSaveBook(event, emit)                                       │
│    │   │                                                             │
│    │   ├─ emit(AddBookLoading)                                     │
│    │   │                                                             │
│    │   ├─ if (bookId == null)                                      │
│    │   │    └─ Create new book                                     │
│    │   │                                                             │
│    │   └─ else (bookId != null) ◄─── OUR EDIT PATH                │
│    │        │                                                        │
│    │        ├─ Convert ViewModel to UpdateBookDto                  │
│    │        ├─ Call bookService.updateBook(bookId, dto)            │
│    │        └─ emit(BookSaved("Książka została zaktualizowana"))   │
│    │                                                                 │
│    └─► BookFormScreen receives state                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  BookService                                                        │
│    │                                                                 │
│    │ updateBook(id, dto)                                            │
│    │   │                                                             │
│    │   ├─ Validate UUID format                                     │
│    │   ├─ Convert DTO to JSON                                      │
│    │   ├─ Execute Supabase update query:                           │
│    │   │    UPDATE books                                            │
│    │   │    SET [fields]                                            │
│    │   │    WHERE id = ? AND user_id = auth.uid()                  │
│    │   │                                                             │
│    │   └─ Handle errors (network, auth, validation)                │
│    │                                                                 │
│    └─► Return success or throw exception                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      DATABASE (Supabase)                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  PostgreSQL + Row-Level Security                                    │
│    │                                                                 │
│    ├─ Verify user authentication (JWT)                             │
│    ├─ Check RLS policies (user owns this book)                     │
│    ├─ Update book record                                           │
│    ├─ Set updated_at = NOW()                                       │
│    └─ Return success                                                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
         │
         ▼ (Success flows back up)
┌─────────────────────────────────────────────────────────────────────┐
│                      NAVIGATION FLOW                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  BookFormScreen                                                     │
│    │                                                                 │
│    │ BlocListener hears BookSaved state                            │
│    │   ├─ Show SnackBar("Książka została zaktualizowana")          │
│    │   └─ Navigator.pop(true)  ◄─── Return success signal         │
│    │                                                                 │
│    ▼                                                                 │
│  BookDetailScreen                                                   │
│    │                                                                 │
│    │ Receives result == true                                        │
│    │   └─ Dispatch FetchBookDetails event                          │
│    │                                                                 │
│    ▼                                                                 │
│  BookDetailsBloc                                                    │
│    │                                                                 │
│    │ _onFetchBookDetails                                            │
│    │   ├─ Fetch updated book from Supabase                         │
│    │   ├─ Fetch reading sessions                                   │
│    │   └─ emit(BookDetailsSuccess)                                 │
│    │                                                                 │
│    ▼                                                                 │
│  UI Updates with fresh data                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
         │
         ▼ (User navigates back)
┌─────────────────────────────────────────────────────────────────────┐
│                      HOME SCREEN REFRESH                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  BookGrid (in home screen)                                          │
│    │                                                                 │
│    │ Receives result == true from BookDetailScreen                 │
│    │   └─ Dispatch RefreshBooksEvent                               │
│    │                                                                 │
│    ▼                                                                 │
│  HomeScreenBloc                                                     │
│    │                                                                 │
│    │ _onRefreshBooks                                                │
│    │   ├─ Fetch updated book list from Supabase                    │
│    │   └─ emit(BookListLoaded)                                     │
│    │                                                                 │
│    ▼                                                                 │
│  UI Updates with fresh list                                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌──────────────────────┐
│   BookDetailDto      │  (From current state)
│   ────────────────   │
│   - id               │
│   - title            │
│   - author           │
│   - pageCount        │
│   - genreId          │
│   - coverUrl         │
│   - isbn             │
│   - publisher        │
│   - publicationYear  │
│   - status           │
│   - lastReadPage     │
│   - createdAt        │
│   - updatedAt        │
└──────────────────────┘
          │
          │ Convert
          ▼
┌──────────────────────┐
│ AddBookFormViewModel │  (For editing in form)
│   ────────────────   │
│   - title            │
│   - author           │
│   - pageCount        │
│   - genreId          │
│   - coverUrl         │
│   - isbn             │
│   - publisher        │
│   - publicationYear  │
└──────────────────────┘
          │
          │ User edits
          ▼
┌──────────────────────┐
│ AddBookFormViewModel │  (Modified by user)
│   ────────────────   │
│   - title (edited)   │
│   - author           │
│   - pageCount        │
│   - genreId (edited) │
│   - coverUrl         │
│   - isbn             │
│   - publisher        │
│   - publicationYear  │
└──────────────────────┘
          │
          │ Convert via toUpdateBookDto()
          ▼
┌──────────────────────┐
│   UpdateBookDto      │  (For API request)
│   ────────────────   │
│   - title            │
│   - author           │
│   - pageCount        │
│   - genreId          │
│   - coverUrl         │
│   - isbn             │
│   - publisher        │
│   - publicationYear  │
└──────────────────────┘
          │
          │ Convert via toRequestJson()
          ▼
┌──────────────────────┐
│  Map<String, dynamic>│  (JSON payload)
│   ────────────────   │
│   {                  │
│     "title": "...",  │
│     "author": "...", │
│     "page_count": 310│
│     "genre_id": "..." │
│     ...              │
│   }                  │
└──────────────────────┘
          │
          │ HTTP PATCH to Supabase
          ▼
┌──────────────────────┐
│   PostgreSQL DB      │  (Updated record)
│   ────────────────   │
│   UPDATE books       │
│   SET ...            │
│   WHERE id = ?       │
│   AND user_id = ?    │
└──────────────────────┘
```

## State Transitions

```
BookDetailScreen States:
├─ BookDetailsSuccess (viewing)
│  └─ User taps Edit
│     └─ Navigate to BookFormScreen
│        └─ (No state change in BookDetailScreen)

BookFormScreen States:
├─ AddBookInitial
├─ AddBookLoading (fetching genres)
├─ AddBookReady (genres loaded, form ready)
│  └─ User taps Save
│     ├─ AddBookLoading (saving)
│     ├─ BookSaved (success) ◄─── Edit success path
│     │  └─ Pop with result = true
│     └─ AddBookError (failure)
│        └─ Stay on form, show error

Back to BookDetailScreen:
├─ Receives result == true
├─ Dispatch FetchBookDetails
├─ BookDetailsLoading
└─ BookDetailsSuccess (with updated data)
```

This flow ensures seamless data consistency across the entire application!

