-- =====================================================
-- Migration: Initial Database Schema for My Book Library
-- Created: 2025-10-10
-- Description: Creates the core schema including genres, books, and reading_sessions tables
--              with appropriate indexes, triggers, and RLS policies
-- 
-- Tables affected:
--   - genres (new)
--   - books (new)
--   - reading_sessions (new)
--
-- Dependencies:
--   - Requires Supabase Auth (auth.users table)
--
-- Notes:
--   - All tables have RLS enabled for security
--   - Cascading deletes are configured to maintain data integrity
--   - Indexes are optimized for common query patterns
-- =====================================================

-- =====================================================
-- 1. CREATE ENUM TYPE FOR BOOK STATUS
-- =====================================================
-- Defines possible reading statuses for books
-- Enum values represent the lifecycle of a book in the user's library
create type book_status as enum (
  'unread',       -- Book has not been started
  'in_progress',  -- Book is currently being read
  'finished',     -- Book has been completed
  'abandoned',    -- Book was started but not completed (future feature)
  'planned'       -- Book is planned to be read (future feature)
);

-- =====================================================
-- 2. CREATE GENRES TABLE
-- =====================================================
-- Stores available literary genres in the application
-- This is a reference table with predefined values
create table genres (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

-- Add comment to table
comment on table genres is 'Reference table containing literary genres available in the application';
comment on column genres.id is 'Unique identifier for the genre';
comment on column genres.name is 'Genre name (e.g., "Fantasy", "Thriller")';
comment on column genres.created_at is 'Timestamp when the genre was added to the system';

-- Insert default genres
-- These are the initial genres available to all users
insert into genres (name) values
  ('Fantastyka'),
  ('Science Fiction'),
  ('Kryminał'),
  ('Thriller'),
  ('Romans'),
  ('Horror'),
  ('Literatura faktu'),
  ('Biografia'),
  ('Poradnik'),
  ('Poezja'),
  ('Klasyka');

-- =====================================================
-- 3. CREATE BOOKS TABLE
-- =====================================================
-- Main table storing user's book collection
-- Each book belongs to exactly one user and optionally has a genre
create table books (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  genre_id uuid references genres(id) on delete set null,
  title text not null,
  author text not null,
  page_count integer not null check (page_count > 0),
  cover_url text,
  isbn text,
  publisher text,
  publication_year integer check (publication_year > 1000 and publication_year <= extract(year from now())),
  status book_status not null default 'unread',
  last_read_page_number integer not null default 0 check (last_read_page_number >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  -- Ensures that last_read_page_number cannot exceed total page_count
  constraint check_last_read_page_valid check (last_read_page_number <= page_count)
);

-- Add comments to table and columns
comment on table books is 'Stores all books in users'' personal libraries';
comment on column books.id is 'Unique identifier for the book';
comment on column books.user_id is 'Reference to the book owner (cascades on user deletion)';
comment on column books.genre_id is 'Optional reference to the book''s genre (nullified on genre deletion)';
comment on column books.title is 'Book title';
comment on column books.author is 'Book author';
comment on column books.page_count is 'Total number of pages in the book';
comment on column books.cover_url is 'URL to book cover image (typically from Google Books API)';
comment on column books.isbn is 'International Standard Book Number';
comment on column books.publisher is 'Publishing house name';
comment on column books.publication_year is 'Year the book was published';
comment on column books.status is 'Current reading status of the book';
comment on column books.last_read_page_number is 'Last page number read by the user (0 if not started)';
comment on column books.created_at is 'Timestamp when the book was added to the library';
comment on column books.updated_at is 'Timestamp of last modification (auto-updated via trigger)';

-- =====================================================
-- 4. CREATE READING_SESSIONS TABLE
-- =====================================================
-- Stores historical reading session data for each book
-- Tracks when users read, for how long, and how many pages they covered
create table reading_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id uuid not null references books(id) on delete cascade,
  start_time timestamptz not null,
  end_time timestamptz not null,
  duration_minutes integer not null check (duration_minutes >= 0),
  pages_read integer not null check (pages_read > 0),
  last_read_page_number integer not null check (last_read_page_number > 0),
  created_at timestamptz not null default now(),
  -- Ensures that end_time is always after start_time
  constraint check_end_after_start check (end_time > start_time)
);

-- Add comments to table and columns
comment on table reading_sessions is 'Historical log of all reading sessions for tracking progress and statistics';
comment on column reading_sessions.id is 'Unique identifier for the reading session';
comment on column reading_sessions.user_id is 'Reference to the user who performed the session (cascades on user deletion)';
comment on column reading_sessions.book_id is 'Reference to the book being read (cascades on book deletion)';
comment on column reading_sessions.start_time is 'Timestamp when the reading session started';
comment on column reading_sessions.end_time is 'Timestamp when the reading session ended';
comment on column reading_sessions.duration_minutes is 'Duration of the session in minutes (stored for performance)';
comment on column reading_sessions.pages_read is 'Number of pages read during this session';
comment on column reading_sessions.last_read_page_number is 'Last page number reached at the end of this session';
comment on column reading_sessions.created_at is 'Timestamp when the session record was created';

-- =====================================================
-- 5. CREATE INDEXES
-- =====================================================
-- Indexes are created to optimize common query patterns

-- Indexes for books table
-- Speeds up queries filtering by user_id (most common operation)
create index idx_books_user_id on books(user_id);

-- Composite index for filtering books by user and status (e.g., show only "in_progress" books)
create index idx_books_user_status on books(user_id, status);

-- Speeds up queries filtering by genre
create index idx_books_genre_id on books(genre_id);

-- Partial index for ISBN lookups (only indexes non-null ISBN values)
-- Used for checking if a book with specific ISBN already exists in user's library
create index idx_books_isbn on books(isbn) where isbn is not null;

-- Indexes for reading_sessions table
-- Speeds up queries fetching all sessions for a specific book
create index idx_reading_sessions_book_id on reading_sessions(book_id);

-- Speeds up queries fetching all sessions for a specific user (for statistics)
create index idx_reading_sessions_user_id on reading_sessions(user_id);

-- Composite index for chronologically sorted sessions per book
-- Optimizes queries showing reading history for a specific book
create index idx_reading_sessions_book_created on reading_sessions(book_id, created_at desc);

-- Index for analytical queries filtering sessions by time period
create index idx_reading_sessions_end_time on reading_sessions(end_time);

-- =====================================================
-- 6. CREATE TRIGGER FUNCTION FOR AUTO-UPDATING updated_at
-- =====================================================
-- This function automatically updates the updated_at column
-- whenever a record in the books table is modified
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

comment on function update_updated_at_column() is 'Automatically updates the updated_at timestamp when a record is modified';

-- =====================================================
-- 7. CREATE TRIGGER FOR BOOKS TABLE
-- =====================================================
-- Attaches the auto-update function to the books table
-- Fires before every UPDATE operation on any row
create trigger set_updated_at
  before update on books
  for each row
  execute function update_updated_at_column();

comment on trigger set_updated_at on books is 'Ensures updated_at is automatically set to current timestamp on every update';

-- =====================================================
-- 8. ENABLE ROW LEVEL SECURITY (RLS)
-- =====================================================
-- RLS ensures users can only access their own data
-- Even with direct database access, users cannot bypass these restrictions

-- Enable RLS on books table
-- Without RLS policies, no data would be accessible to users
alter table books enable row level security;

-- Enable RLS on reading_sessions table
alter table reading_sessions enable row level security;

-- Enable RLS on genres table
-- Genres are read-only for all authenticated users
alter table genres enable row level security;

-- =====================================================
-- 9. CREATE RLS POLICIES FOR BOOKS TABLE
-- =====================================================

-- SELECT policy: Users can only view their own books
-- Rationale: Prevents users from accessing other users' book collections
create policy "Users can view their own books"
  on books
  for select
  using (auth.uid() = user_id);

comment on policy "Users can view their own books" on books is 'Restricts book visibility to the owner only';

-- INSERT policy: Users can only add books to their own library
-- Rationale: Prevents users from adding books to other users' accounts
create policy "Users can insert their own books"
  on books
  for insert
  with check (auth.uid() = user_id);

comment on policy "Users can insert their own books" on books is 'Ensures users can only add books to their own library';

-- UPDATE policy: Users can only modify their own books
-- Rationale: Prevents unauthorized modifications to other users' book data
-- USING clause: Determines which existing rows can be selected for update
-- WITH CHECK clause: Validates the new row values after update
create policy "Users can update their own books"
  on books
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

comment on policy "Users can update their own books" on books is 'Restricts book modifications to the owner only';

-- DELETE policy: Users can only delete their own books
-- Rationale: Prevents users from deleting books from other users' libraries
create policy "Users can delete their own books"
  on books
  for delete
  using (auth.uid() = user_id);

comment on policy "Users can delete their own books" on books is 'Allows users to delete only their own books';

-- =====================================================
-- 10. CREATE RLS POLICIES FOR READING_SESSIONS TABLE
-- =====================================================

-- SELECT policy: Users can only view their own reading sessions
-- Rationale: Reading history is private and should not be visible to other users
create policy "Users can view their own reading sessions"
  on reading_sessions
  for select
  using (auth.uid() = user_id);

comment on policy "Users can view their own reading sessions" on reading_sessions is 'Restricts reading session visibility to the owner only';

-- INSERT policy: Users can only create reading sessions for their own books
-- Rationale: Prevents users from creating fake reading sessions for others
create policy "Users can insert their own reading sessions"
  on reading_sessions
  for insert
  with check (auth.uid() = user_id);

comment on policy "Users can insert their own reading sessions" on reading_sessions is 'Ensures users can only create reading sessions for their own books';

-- UPDATE policy: Users can only modify their own reading sessions
-- Rationale: Prevents unauthorized modifications to reading history
-- USING clause: Determines which existing sessions can be selected for update
-- WITH CHECK clause: Validates the new session values after update
create policy "Users can update their own reading sessions"
  on reading_sessions
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

comment on policy "Users can update their own reading sessions" on reading_sessions is 'Restricts reading session modifications to the owner only';

-- DELETE policy: Users can only delete their own reading sessions
-- Rationale: Allows users to clean up their own reading history
create policy "Users can delete their own reading sessions"
  on reading_sessions
  for delete
  using (auth.uid() = user_id);

comment on policy "Users can delete their own reading sessions" on reading_sessions is 'Allows users to delete only their own reading sessions';

-- =====================================================
-- 11. CREATE RLS POLICIES FOR GENRES TABLE
-- =====================================================

-- SELECT policy for authenticated users: All logged-in users can view all genres
-- Rationale: Genres are reference data shared across all users
-- No INSERT/UPDATE/DELETE policies: Only database admins can modify genres
create policy "Authenticated users can view all genres"
  on genres
  for select
  using (auth.role() = 'authenticated');

comment on policy "Authenticated users can view all genres" on genres is 'Allows all authenticated users to view the genre list (read-only reference data)';

-- SELECT policy for anonymous users: Allow public access to genres
-- Rationale: Genres may need to be visible during onboarding or public book browsing
create policy "Anonymous users can view all genres"
  on genres
  for select
  using (auth.role() = 'anon');

comment on policy "Anonymous users can view all genres" on genres is 'Allows anonymous users to view the genre list (read-only reference data)';

-- =====================================================
-- END OF MIGRATION
-- =====================================================
