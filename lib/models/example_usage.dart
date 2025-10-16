// Example usage of DTOs for the My Book Library API
// This file demonstrates how to use the DTOs in real-world scenarios

import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_types.dart';
import 'types.dart';

class BookService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================================
  // Book Operations
  // ============================================================================

  /// Fetch all books for the current user with genre names
  Future<List<BookListItemDto>> getAllBooks() async {
    final response = await _supabase.books
        .select('*, genres(name)')
        .order('title', ascending: true);

    return (response as List)
        .map((json) => BookListItemDto.fromJson(json))
        .toList();
  }

  /// Fetch books filtered by status
  Future<List<BookListItemDto>> getBooksByStatus(BookStatus status) async {
    final statusString = status.toString().split('.').last;
    final response = await _supabase.books
        .select('*, genres(name)')
        .eq('status', statusString)
        .order('title', ascending: true);

    return (response as List)
        .map((json) => BookListItemDto.fromJson(json))
        .toList();
  }

  /// Get a single book by ID
  Future<BookDetailDto?> getBookById(String bookId) async {
    final response = await _supabase.books
        .select('*, genres(name)')
        .eq('id', bookId)
        .maybeSingle();

    return response != null ? BookDetailDto.fromJson(response) : null;
  }

  /// Create a new book
  Future<BookDetailDto> createBook(CreateBookDto bookDto) async {
    final response = await _supabase.books
        .insert(bookDto.toRequestJson())
        .select('*, genres(name)')
        .single();

    return BookDetailDto.fromJson(response);
  }

  /// Update an existing book
  Future<BookDetailDto> updateBook(
    String bookId,
    UpdateBookDto updateDto,
  ) async {
    final response = await _supabase.books
        .update(updateDto.toRequestJson())
        .eq('id', bookId)
        .select('*, genres(name)')
        .single();

    return BookDetailDto.fromJson(response);
  }

  /// Mark a book as finished
  Future<BookDetailDto> markBookAsFinished(String bookId, int pageCount) async {
    final updateDto = UpdateBookDto(
      status: BookStatus.finished,
      lastReadPageNumber: pageCount,
    );

    return updateBook(bookId, updateDto);
  }

  /// Delete a book
  Future<void> deleteBook(String bookId) async {
    await _supabase.books.delete().eq('id', bookId);
  }

  // ============================================================================
  // Reading Session Operations
  // ============================================================================

  /// Get all reading sessions for a specific book
  Future<List<ReadingSessionDto>> getReadingSessions(String bookId) async {
    final response = await _supabase.reading_sessions
        .select()
        .eq('book_id', bookId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ReadingSessionDto.fromJson(json))
        .toList();
  }

  /// End a reading session using the RPC function
  /// This automatically updates the book's progress
  Future<String?> endReadingSession(EndReadingSessionDto sessionDto) async {
    final response = await _supabase.rpc(
      'end_reading_session',
      params: sessionDto.toRequestJson(),
    );

    return response as String?;
  }

  /// Get total reading statistics for a book
  Future<Map<String, dynamic>> getBookStatistics(String bookId) async {
    final sessions = await getReadingSessions(bookId);

    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.durationMinutes,
    );

    final totalPagesRead = sessions.fold<int>(
      0,
      (sum, session) => sum + session.pagesRead,
    );

    return {
      'totalSessions': sessions.length,
      'totalMinutes': totalMinutes,
      'totalPagesRead': totalPagesRead,
      'averageSessionMinutes': sessions.isEmpty
          ? 0
          : totalMinutes / sessions.length,
      'averagePagesPerSession': sessions.isEmpty
          ? 0
          : totalPagesRead / sessions.length,
    };
  }

  // ============================================================================
  // Genre Operations
  // ============================================================================

  /// Get all available genres
  Future<List<GenreDto>> getAllGenres() async {
    final response = await _supabase.genres.select().order(
      'name',
      ascending: true,
    );

    return (response as List).map((json) => GenreDto.fromJson(json)).toList();
  }

  /// Get books by genre
  Future<List<BookListItemDto>> getBooksByGenre(String genreId) async {
    final response = await _supabase.books
        .select('*, genres(name)')
        .eq('genre_id', genreId)
        .order('title', ascending: true);

    return (response as List)
        .map((json) => BookListItemDto.fromJson(json))
        .toList();
  }

  // ============================================================================
  // Example Complex Workflows
  // ============================================================================

  /// Complete workflow: Add a book and start reading
  Future<Map<String, dynamic>> addBookAndStartReading({
    required String title,
    required String author,
    required int pageCount,
    String? genreId,
    String? coverUrl,
  }) async {
    // Step 1: Create the book
    final createDto = CreateBookDto(
      title: title,
      author: author,
      pageCount: pageCount,
      genreId: genreId,
      coverUrl: coverUrl,
    );

    final book = await createBook(createDto);

    // Step 2: Update status to in_progress
    final updateDto = UpdateBookDto(status: BookStatus.in_progress);

    final updatedBook = await updateBook(book.id, updateDto);

    return {'book': updatedBook, 'message': 'Book added and ready to read!'};
  }

  /// Complete a reading session workflow
  Future<Map<String, dynamic>> completeReadingSession({
    required String bookId,
    required DateTime startTime,
    required DateTime endTime,
    required int lastReadPage,
  }) async {
    // Create the session DTO
    final sessionDto = EndReadingSessionDto(
      bookId: bookId,
      startTime: startTime,
      endTime: endTime,
      lastReadPage: lastReadPage,
    );

    // End the session via RPC (this handles all the logic)
    final sessionId = await endReadingSession(sessionDto);

    // Get updated book details
    final book = await getBookById(bookId);

    // Get updated statistics
    final stats = await getBookStatistics(bookId);

    return {
      'sessionId': sessionId,
      'book': book,
      'statistics': stats,
      'isFinished': book?.status == BookStatus.finished,
    };
  }

  /// Get reading progress summary
  Future<Map<String, dynamic>> getReadingProgress() async {
    final allBooks = await getAllBooks();

    final unread = allBooks.where((b) => b.status == BookStatus.unread).length;
    final inProgress = allBooks
        .where((b) => b.status == BookStatus.in_progress)
        .length;
    final finished = allBooks
        .where((b) => b.status == BookStatus.finished)
        .length;
    final abandoned = allBooks
        .where((b) => b.status == BookStatus.abandoned)
        .length;
    final planned = allBooks
        .where((b) => b.status == BookStatus.planned)
        .length;

    // Calculate total pages read
    int totalPagesRead = 0;
    for (final book in allBooks) {
      totalPagesRead += book.lastReadPageNumber;
    }

    return {
      'totalBooks': allBooks.length,
      'unread': unread,
      'inProgress': inProgress,
      'finished': finished,
      'abandoned': abandoned,
      'planned': planned,
      'totalPagesRead': totalPagesRead,
    };
  }
}
