# Edit Book Feature - Bug Fixes

## Issues Found and Fixed

### Issue 1: Genre Dropdown Error
**Problem**: When editing a book, the dropdown threw an assertion error:
```
"There should be exactly one item with [DropdownButton]'s value: c42107f6-d432-44ca-acc3-4af41e0eb796"
```

**Root Cause**: The book's `genreId` was set before the genres list was loaded, causing a mismatch where the dropdown value didn't exist in the available items.

**Fix**: Added validation in `book_form_screen.dart` (lines 181-188) to check if the `selectedGenreId` exists in the loaded genres list. If not, it resets to null.

```dart
if (state is AddBookReady) {
  setState(() {
    _availableGenres = state.genres;
    // Validate that selectedGenreId exists in available genres
    if (_selectedGenreId != null) {
      final genreExists = state.genres.any((g) => g.id == _selectedGenreId);
      if (!genreExists) {
        _selectedGenreId = null;
      }
    }
  });
}
```

### Issue 2: Database Not Updating
**Problem**: Editing book information and saving didn't change anything in the database.

**Potential Root Causes Addressed**:

1. **Empty String Handling** (Fixed in `types.dart` lines 133-165):
   - Enhanced `UpdateBookDto.toRequestJson()` to properly handle empty strings
   - Empty optional fields are now converted to `null` to clear database values
   - Required fields are always included if not null

2. **Silent Update Failures** (Fixed in `book_service.dart` lines 533-544):
   - Added `.select('id')` to the update query to get response
   - Added check to verify that rows were actually updated
   - Throws `NotFoundException` if no rows were updated (due to RLS or non-existent book)

**Changes Made**:

#### In `lib/models/types.dart`:
```dart
Map<String, dynamic> toRequestJson() {
  final map = <String, dynamic>{};
  
  // Always include non-null values, handle empty strings for optional fields
  if (title != null) map['title'] = title;
  if (author != null) map['author'] = author;
  if (pageCount != null) map['page_count'] = pageCount;
  
  // For optional fields, include null to clear the field if needed
  if (genreId != null) {
    map['genre_id'] = genreId;
  }
  if (coverUrl != null) {
    map['cover_url'] = coverUrl!.isEmpty ? null : coverUrl;
  }
  if (isbn != null) {
    map['isbn'] = isbn!.isEmpty ? null : isbn;
  }
  if (publisher != null) {
    map['publisher'] = publisher!.isEmpty ? null : publisher;
  }
  if (publicationYear != null) {
    map['publication_year'] = publicationYear;
  }
  if (status != null) {
    map['status'] = status.toString().split('.').last;
  }
  if (lastReadPageNumber != null) {
    map['last_read_page_number'] = lastReadPageNumber;
  }
  
  return map;
}
```

#### In `lib/services/book_service.dart`:
```dart
// Execute update and check count
final response = await _supabase
    .from('books')
    .update(updateData)
    .eq('id', id)
    .select('id')
    .timeout(ApiConstants.defaultTimeout) as List;

// Check if any rows were updated
if (response.isEmpty) {
  throw NotFoundException('Book not found or you don\'t have permission to update it');
}
```

## Testing Recommendations

### Test Case 1: Genre Dropdown
1. Create a book with a genre
2. Delete that genre from the database (or use a book with invalid genre ID)
3. Try to edit the book
4. **Expected**: Dropdown should show "Brak" selected instead of crashing

### Test Case 2: Update Verification
1. Edit a book and change the title
2. Save changes
3. **Expected**: Database should reflect the new title
4. **Verification**: Check that the book detail screen shows updated info

### Test Case 3: Optional Fields
1. Edit a book and clear an optional field (e.g., publisher)
2. Save changes
3. **Expected**: Field should be cleared in database (null value)

### Test Case 4: RLS Permissions
1. Try to edit a book that doesn't belong to you (if possible)
2. **Expected**: Should throw NotFoundException with permission message

### Test Case 5: Empty String Handling
1. Edit a book and set ISBN to empty string
2. Save changes
3. **Expected**: ISBN should be null in database, not empty string

## Files Modified

1. `lib/features/add_book/view/book_form_screen.dart` - Genre validation
2. `lib/models/types.dart` - Empty string handling in UpdateBookDto
3. `lib/services/book_service.dart` - Update verification

## Error Messages Enhanced

- **Before**: Silent failure or generic error
- **After**: Clear error message: "Book not found or you don't have permission to update it"

## Next Steps

1. Test the fixes in the running application
2. Verify that both issues are resolved
3. Check database to confirm updates are persisting
4. Monitor logs for any update-related errors

