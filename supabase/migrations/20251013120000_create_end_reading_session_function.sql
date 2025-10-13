-- Migration: Create end_reading_session RPC function
-- Created: 2025-10-13
-- Description: PostgreSQL function to atomically create reading session and update book progress

CREATE OR REPLACE FUNCTION end_reading_session(
  p_book_id UUID,
  p_start_time TIMESTAMPTZ,
  p_end_time TIMESTAMPTZ,
  p_last_read_page INTEGER
) RETURNS UUID
LANGUAGE plpgsql
SECURITY INVOKER
AS $$
DECLARE
  v_book RECORD;
  v_session_id UUID;
  v_pages_read INTEGER;
  v_duration_minutes INTEGER;
  v_user_id UUID;
BEGIN
  -- Get authenticated user ID
  v_user_id := auth.uid();
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Authentication required';
  END IF;
  
  -- Validate and fetch book data
  -- Using FOR UPDATE to prevent race conditions
  SELECT * INTO v_book 
  FROM books 
  WHERE id = p_book_id AND user_id = v_user_id
  FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Book not found or access denied';
  END IF;
  
  -- Validate last_read_page
  IF p_last_read_page > v_book.page_count THEN
    RAISE EXCEPTION 'Invalid last_read_page: exceeds page_count (% > %)', 
      p_last_read_page, v_book.page_count;
  END IF;
  
  IF p_last_read_page <= 0 THEN
    RAISE EXCEPTION 'Invalid last_read_page: must be positive';
  END IF;
  
  -- Validate time ordering
  IF p_end_time <= p_start_time THEN
    RAISE EXCEPTION 'Invalid time range: end_time must be after start_time';
  END IF;
  
  -- Calculate derived values
  v_duration_minutes := CEIL(EXTRACT(EPOCH FROM (p_end_time - p_start_time)) / 60);
  v_pages_read := p_last_read_page - v_book.last_read_page_number;
  
  -- Skip if no progress (user didn't advance in the book)
  IF v_pages_read <= 0 THEN
    RETURN NULL;
  END IF;
  
  -- Insert reading session
  INSERT INTO reading_sessions (
    user_id, 
    book_id, 
    start_time, 
    end_time, 
    duration_minutes, 
    pages_read, 
    last_read_page_number
  ) VALUES (
    v_user_id,
    p_book_id,
    p_start_time,
    p_end_time,
    v_duration_minutes,
    v_pages_read,
    p_last_read_page
  ) RETURNING id INTO v_session_id;
  
  -- Update book progress and status
  UPDATE books 
  SET 
    last_read_page_number = p_last_read_page,
    status = CASE 
      -- If user read all pages, mark as finished
      WHEN p_last_read_page >= page_count THEN 'finished'::book_status
      -- If book was unread and now has progress, mark as in_progress
      WHEN status = 'unread' THEN 'in_progress'::book_status
      -- Otherwise keep current status
      ELSE status
    END,
    updated_at = NOW()
  WHERE id = p_book_id;
  
  RETURN v_session_id;
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION end_reading_session(UUID, TIMESTAMPTZ, TIMESTAMPTZ, INTEGER) IS 
'Atomically creates a reading session and updates book progress. Returns session UUID or NULL if no progress made.';

