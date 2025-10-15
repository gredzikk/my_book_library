# REST API Plan for My Book Library

This document outlines the REST API for the "My Book Library" application, built on Supabase. The API leverages Supabase's auto-generated REST endpoints powered by PostgREST, with custom RPC functions for complex business logic.

## 1. Resources

- **Books**: Represents a book in a user's library.
  - Corresponding Database Table: `public.books`
- **Reading Sessions**: Represents a single reading session for a book.
  - Corresponding Database Table: `public.reading_sessions`
- **Genres**: Represents the list of available book genres.
  - Corresponding Database Table: `public.genres`

## 2. Endpoints

### 2.1. Books Resource

#### List Books

- **Method**: `GET`
- **URL**: `/rest/v1/books`
- **Description**: Retrieves a list of books for the authenticated user.
- **Query Parameters**:
  - `select=*,genres(name)`: To embed the genre name.
  - `status=eq.{status}`: Filter by status (e.g., `unread`, `in_progress`, `finished`).
  - `genre_id=eq.{uuid}`: Filter by genre ID.
  - `order=title.asc`: Sort by title (or any other field).
  - `limit={number}`: For pagination.
  - `offset={number}`: For pagination.
- **Request Payload**: None
- **Response Payload (JSON)**:
  ```json
  [
    {
      "id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
      "user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "genre_id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
      "title": "The Hobbit",
      "author": "J.R.R. Tolkien",
      "page_count": 310,
      "cover_url": "http://example.com/cover.jpg",
      "isbn": "9780345339683",
      "publisher": "Houghton Mifflin Harcourt",
      "publication_year": 1937,
      "status": "in_progress",
      "last_read_page_number": 150,
      "created_at": "2025-10-10T12:00:00Z",
      "updated_at": "2025-10-12T18:30:00Z",
      "genres": {
        "name": "Fantastyka"
      }
    }
  ]
  ```
- **Success Codes**:
  - `200 OK`: Successfully retrieved the list of books.
- **Error Codes**:
  - `401 Unauthorized`: JWT is missing or invalid.

---

#### Get a Single Book

- **Method**: `GET`
- **URL**: `/rest/v1/books?id=eq.{book_id}`
- **Description**: Retrieves a single book by its ID.
- **Query Parameters**:
  - `select=*,genres(name)`: To embed the genre name.
- **Request Payload**: None
- **Response Payload (JSON)**: Same structure as a single object in the "List Books" response.
- **Success Codes**:
  - `200 OK`: Successfully retrieved the book.
- **Error Codes**:
  - `401 Unauthorized`: JWT is missing or invalid.
  - `404 Not Found`: No book with the specified ID exists for this user.

---

#### Create a Book

- **Method**: `POST`
- **URL**: `/rest/v1/books`
- **Description**: Adds a new book to the user's library. `user_id` is set automatically based on the authenticated user.
- **Request Payload (JSON)**:
  ```json
  {
    "title": "New Book Title",
    "author": "Author Name",
    "page_count": 400,
    "genre_id": "f1e2d3c4-b5a6-7890-1234-567890abcdef", // Optional
    "cover_url": "http://example.com/cover.jpg",      // Optional
    "isbn": "9780321765723",                           // Optional
    "publisher": "Publisher Name",                      // Optional
    "publication_year": 2025                          // Optional
  }
  ```
- **Response Payload (JSON)**: The newly created book object.
- **Success Codes**:
  - `201 Created`: The book was created successfully.
- **Error Codes**:
  - `400 Bad Request`: Validation failed (e.g., `page_count` is not positive).
  - `401 Unauthorized`: JWT is missing or invalid.
  - `409 Conflict`: A book with the same ISBN might already exist (if a unique constraint is added).

---

#### Update a Book

- **Method**: `PATCH`
- **URL**: `/rest/v1/books?id=eq.{book_id}`
- **Description**: Updates details of an existing book.
- **Request Payload (JSON)**:
  ```json
  {
    "status": "finished",
    "last_read_page_number": 310,
    "publisher": "New Publisher"
  }
  ```
- **Response Payload (JSON)**: The updated book object.
- **Success Codes**:
  - `200 OK`: The book was updated successfully.
- **Error Codes**:
  - `400 Bad Request`: Validation failed (e.g., `last_read_page_number > page_count`).
  - `401 Unauthorized`: JWT is missing or invalid.
  - `404 Not Found`: No book with the specified ID exists for this user.

---

#### Delete a Book

- **Method**: `DELETE`
- **URL**: `/rest/v1/books?id=eq.{book_id}`
- **Description**: Deletes a book and all its associated reading sessions from the user's library.
- **Request Payload**: None
- **Response Payload**: None
- **Success Codes**:
  - `204 No Content`: The book was deleted successfully.
- **Error Codes**:
  - `401 Unauthorized`: JWT is missing or invalid.
  - `404 Not Found`: No book with the specified ID exists for this user.

### 2.2. Reading Sessions Resource

#### List Reading Sessions for a Book

- **Method**: `GET`
- **URL**: `/rest/v1/reading_sessions?book_id=eq.{book_id}`
- **Description**: Retrieves the history of reading sessions for a specific book.
- **Query Parameters**:
  - `order=created_at.desc`: To sort sessions from newest to oldest.
- **Request Payload**: None
- **Response Payload (JSON)**:
  ```json
  [
    {
      "id": "e6f7a8b9-c0d1-e2f3-a4b5-c6d7e8f9a0b1",
      "user_id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "book_id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
      "start_time": "2025-10-12T18:00:00Z",
      "end_time": "2025-10-12T18:30:00Z",
      "duration_minutes": 30,
      "pages_read": 25,
      "last_read_page_number": 150,
      "created_at": "2025-10-12T18:30:05Z"
    }
  ]
  ```
- **Success Codes**:
  - `200 OK`: Successfully retrieved the list of sessions.
- **Error Codes**:
  - `401 Unauthorized`: JWT is missing or invalid.

---

#### End a Reading Session (Custom Logic)

This endpoint handles the complex logic of finishing a session and updating the book's progress atomically.

- **Method**: `POST`
- **URL**: `/rest/v1/rpc/end_reading_session`
- **Description**: Creates a reading session record, updates the book's `last_read_page_number`, and automatically updates the book's status to `finished` if completed.
- **Request Payload (JSON)**:
  ```json
  {
    "p_book_id": "c3e4b5a6-3b2a-4f1e-8b3d-2c1a1b0e9d8c",
    "p_start_time": "2025-10-12T18:00:00Z",
    "p_end_time": "2025-10-12T18:30:00Z",
    "p_last_read_page": 150
  }
  ```
- **Response Payload**: The ID of the created session or null if not created (e.g., zero pages read).
- **Success Codes**:
  - `200 OK`: The session was processed successfully.
- **Error Codes**:
  - `400 Bad Request`: Invalid input (e.g., page number is invalid).
  - `401 Unauthorized`: JWT is missing or invalid.
  - `500 Internal Server Error`: The RPC function failed.

### 2.3. Genres Resource

#### List Genres

- **Method**: `GET`
- **URL**: `/rest/v1/genres`
- **Description**: Retrieves the master list of all available book genres.
- **Query Parameters**: `order=name.asc`
- **Request Payload**: None
- **Response Payload (JSON)**:
  ```json
  [
    {
      "id": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
      "name": "Fantastyka",
      "created_at": "2025-10-10T12:00:00Z"
    },
    {
      "id": "a9b8c7d6-e5f4-a3b2-c1d0-e9f8a7b6c5d4",
      "name": "Kryminał",
      "created_at": "2025-10-10T12:00:00Z"
    }
  ]
  ```
- **Success Codes**:
  - `200 OK`: Successfully retrieved the list of genres.
- **Error Codes**:
  - `401 Unauthorized`: JWT is missing or invalid.

## 3. Authentication and Authorization

- **Mechanism**: All API requests must be authenticated using a JSON Web Token (JWT) provided by Supabase Auth.
- **Implementation**: The client must include the JWT in the `Authorization` header of every request.
  - `Authorization: Bearer <SUPABASE_JWT>`
- **Authorization**: Data access is controlled by PostgreSQL's Row Level Security (RLS) policies. These policies ensure that users can only perform actions (SELECT, INSERT, UPDATE, DELETE) on their own data. For example, a request to `GET /rest/v1/books` will only ever return books where `books.user_id` matches the `id` of the authenticated user.

## 4. Validation and Business Logic

### Validation

The API enforces data integrity through constraints defined in the PostgreSQL schema. Invalid requests will result in a `400 Bad Request` error.
- **`books` resource**:
  - `title`, `author`, `page_count` are required.
  - `page_count` must be a positive integer (`> 0`).
  - `last_read_page_number` cannot be greater than `page_count`.
  - `publication_year` must be a realistic year.
- **`reading_sessions` resource**:
  - `pages_read` must be a positive integer (`> 0`).
  - `end_time` must be later than `start_time`.

### Business Logic

- **Auto-updating book status**: The `end_reading_session` RPC function contains logic to check if `last_read_page_number` equals `page_count`. If true, it automatically updates the book's status to `finished`.
- **Blocking `page_count` edit**: The database should have a trigger or check constraint to prevent updating `page_count` if a book's status is `in_progress`. The client application is responsible for disabling this field in the UI to provide a better user experience.
- **Manually marking a book as "Read"**: This is handled by a standard `PATCH` request on the `/books` resource, setting the `status` to `finished` and `last_read_page_number` to the book's `page_count`.
- **Zero-page sessions**: The `end_reading_session` function will not create a `reading_sessions` record if the number of pages read is zero.
