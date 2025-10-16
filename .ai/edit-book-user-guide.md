# Edit Book Details - User Guide

## Feature Description
You can now edit book details directly from the Book Detail screen. This feature allows you to update any information about your books including title, author, page count, genre, and more.

## How to Edit a Book

### Step 1: Navigate to Book Details
1. From the home screen, tap on any book to view its details
2. You'll see the book detail screen with all information

### Step 2: Tap the Edit Button
1. Look for the pencil icon (✏️) in the top-right corner of the app bar
2. Tap the edit button
3. The book form screen will open with all current data pre-filled

### Step 3: Modify Book Information
The form includes the following fields:

#### Required Fields (marked with *)
- **Title**: The book's title
- **Author**: The book's author
- **Page Count**: Total number of pages (must be > 0)

#### Optional Fields
- **Genre**: Select from dropdown (or leave as "Brak")
- **Cover URL**: Link to book cover image
- **ISBN**: Book's ISBN number
- **Publisher**: Publishing company
- **Publication Year**: Year published (4 digits)

### Step 4: Save Changes
1. After making your changes, tap the blue "Zapisz zmiany" button at the bottom
2. Wait for the loading indicator
3. You'll see a success message: "Książka została zaktualizowana"
4. The form will close and return to the book detail screen
5. The book details will automatically refresh to show your changes

### Step 5: Verify Changes
- The book detail screen will display the updated information
- All changes are immediately saved to the database

## Cancel Editing
- To cancel without saving, tap the back arrow (←) in the top-left corner
- Your changes will NOT be saved

## Validation Rules

The form validates your input:
- **Title**: Cannot be empty
- **Author**: Cannot be empty  
- **Page Count**: Must be a positive number
- **Publication Year**: Must be a valid 4-digit year (if provided)

If validation fails, you'll see an error message below the invalid field.

## Visual Consistency

The edit screen uses the **exact same layout** as the add book screen, ensuring a familiar and consistent experience. The only differences are:
- App bar title: "Edytuj książkę" instead of "Dodaj książkę"
- Button text: "Zapisz zmiany" instead of "Dodaj książkę"
- Success message: "Książka została zaktualizowana" instead of "Książka została dodana"

## Error Handling

If something goes wrong:
- **No Internet**: "Brak połączenia z internetem"
- **Validation Error**: Specific field errors shown below each field
- **Authorization Error**: "Błąd autoryzacji"
- **Server Error**: "Błąd serwera"

You can correct the issue and try saving again.

## What Gets Updated

When you save:
- All book metadata (title, author, etc.)
- Genre association
- Cover URL
- ISBN and publication details

What does NOT change:
- Book ID
- User ID (ownership)
- Reading status
- Current page progress
- Reading session history
- Created date (updated date changes automatically)

## Tips

1. **Double-check required fields**: Make sure title, author, and page count are filled
2. **Genre selection**: You can change or remove the genre at any time
3. **Cover URL**: Update the cover URL if you find a better image
4. **ISBN updates**: Useful if you initially added a book manually and later found the ISBN

