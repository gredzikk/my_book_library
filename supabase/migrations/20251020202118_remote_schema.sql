


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."book_status" AS ENUM (
    'unread',
    'in_progress',
    'finished',
    'abandoned',
    'planned'
);


ALTER TYPE "public"."book_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."end_reading_session"("p_book_id" "uuid", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_last_read_page" integer) RETURNS "uuid"
    LANGUAGE "plpgsql"
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


ALTER FUNCTION "public"."end_reading_session"("p_book_id" "uuid", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_last_read_page" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."end_reading_session"("p_book_id" "uuid", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_last_read_page" integer) IS 'Atomically creates a reading session and updates book progress. Returns session UUID or NULL if no progress made.';



CREATE OR REPLACE FUNCTION "public"."set_user_id_on_books"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  NEW.user_id = auth.uid();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_user_id_on_books"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_updated_at_column"() IS 'Automatically updates the updated_at timestamp when a record is modified';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."books" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "genre_id" "uuid",
    "title" "text" NOT NULL,
    "author" "text" NOT NULL,
    "page_count" integer NOT NULL,
    "cover_url" "text",
    "isbn" "text",
    "publisher" "text",
    "publication_year" integer,
    "status" "public"."book_status" DEFAULT 'unread'::"public"."book_status" NOT NULL,
    "last_read_page_number" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "books_last_read_page_number_check" CHECK (("last_read_page_number" >= 0)),
    CONSTRAINT "books_page_count_check" CHECK (("page_count" > 0)),
    CONSTRAINT "books_publication_year_check" CHECK ((("publication_year" > 1000) AND (("publication_year")::numeric <= EXTRACT(year FROM "now"())))),
    CONSTRAINT "check_last_read_page_valid" CHECK (("last_read_page_number" <= "page_count"))
);


ALTER TABLE "public"."books" OWNER TO "postgres";


COMMENT ON TABLE "public"."books" IS 'Stores all books in users'' personal libraries';



COMMENT ON COLUMN "public"."books"."id" IS 'Unique identifier for the book';



COMMENT ON COLUMN "public"."books"."user_id" IS 'Reference to the book owner (cascades on user deletion)';



COMMENT ON COLUMN "public"."books"."genre_id" IS 'Optional reference to the book''s genre (nullified on genre deletion)';



COMMENT ON COLUMN "public"."books"."title" IS 'Book title';



COMMENT ON COLUMN "public"."books"."author" IS 'Book author';



COMMENT ON COLUMN "public"."books"."page_count" IS 'Total number of pages in the book';



COMMENT ON COLUMN "public"."books"."cover_url" IS 'URL to book cover image (typically from Google Books API)';



COMMENT ON COLUMN "public"."books"."isbn" IS 'International Standard Book Number';



COMMENT ON COLUMN "public"."books"."publisher" IS 'Publishing house name';



COMMENT ON COLUMN "public"."books"."publication_year" IS 'Year the book was published';



COMMENT ON COLUMN "public"."books"."status" IS 'Current reading status of the book';



COMMENT ON COLUMN "public"."books"."last_read_page_number" IS 'Last page number read by the user (0 if not started)';



COMMENT ON COLUMN "public"."books"."created_at" IS 'Timestamp when the book was added to the library';



COMMENT ON COLUMN "public"."books"."updated_at" IS 'Timestamp of last modification (auto-updated via trigger)';



CREATE TABLE IF NOT EXISTS "public"."genres" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."genres" OWNER TO "postgres";


COMMENT ON TABLE "public"."genres" IS 'Reference table containing literary genres available in the application';



COMMENT ON COLUMN "public"."genres"."id" IS 'Unique identifier for the genre';



COMMENT ON COLUMN "public"."genres"."name" IS 'Genre name (e.g., "Fantasy", "Thriller")';



COMMENT ON COLUMN "public"."genres"."created_at" IS 'Timestamp when the genre was added to the system';



CREATE TABLE IF NOT EXISTS "public"."reading_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "book_id" "uuid" NOT NULL,
    "start_time" timestamp with time zone NOT NULL,
    "end_time" timestamp with time zone NOT NULL,
    "duration_minutes" integer NOT NULL,
    "pages_read" integer NOT NULL,
    "last_read_page_number" integer NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "check_end_after_start" CHECK (("end_time" > "start_time")),
    CONSTRAINT "reading_sessions_duration_minutes_check" CHECK (("duration_minutes" >= 0)),
    CONSTRAINT "reading_sessions_last_read_page_number_check" CHECK (("last_read_page_number" > 0)),
    CONSTRAINT "reading_sessions_pages_read_check" CHECK (("pages_read" > 0))
);


ALTER TABLE "public"."reading_sessions" OWNER TO "postgres";


COMMENT ON TABLE "public"."reading_sessions" IS 'Historical log of all reading sessions for tracking progress and statistics';



COMMENT ON COLUMN "public"."reading_sessions"."id" IS 'Unique identifier for the reading session';



COMMENT ON COLUMN "public"."reading_sessions"."user_id" IS 'Reference to the user who performed the session (cascades on user deletion)';



COMMENT ON COLUMN "public"."reading_sessions"."book_id" IS 'Reference to the book being read (cascades on book deletion)';



COMMENT ON COLUMN "public"."reading_sessions"."start_time" IS 'Timestamp when the reading session started';



COMMENT ON COLUMN "public"."reading_sessions"."end_time" IS 'Timestamp when the reading session ended';



COMMENT ON COLUMN "public"."reading_sessions"."duration_minutes" IS 'Duration of the session in minutes (stored for performance)';



COMMENT ON COLUMN "public"."reading_sessions"."pages_read" IS 'Number of pages read during this session';



COMMENT ON COLUMN "public"."reading_sessions"."last_read_page_number" IS 'Last page number reached at the end of this session';



COMMENT ON COLUMN "public"."reading_sessions"."created_at" IS 'Timestamp when the session record was created';



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_user_isbn_unique" UNIQUE ("user_id", "isbn");



ALTER TABLE ONLY "public"."genres"
    ADD CONSTRAINT "genres_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."genres"
    ADD CONSTRAINT "genres_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_books_genre_id" ON "public"."books" USING "btree" ("genre_id");



CREATE INDEX "idx_books_isbn" ON "public"."books" USING "btree" ("isbn") WHERE ("isbn" IS NOT NULL);



CREATE INDEX "idx_books_user_id" ON "public"."books" USING "btree" ("user_id");



CREATE INDEX "idx_books_user_status" ON "public"."books" USING "btree" ("user_id", "status");



CREATE INDEX "idx_reading_sessions_book_created" ON "public"."reading_sessions" USING "btree" ("book_id", "created_at" DESC);



CREATE INDEX "idx_reading_sessions_book_id" ON "public"."reading_sessions" USING "btree" ("book_id");



CREATE INDEX "idx_reading_sessions_end_time" ON "public"."reading_sessions" USING "btree" ("end_time");



CREATE INDEX "idx_reading_sessions_user_id" ON "public"."reading_sessions" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "set_updated_at" BEFORE UPDATE ON "public"."books" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



COMMENT ON TRIGGER "set_updated_at" ON "public"."books" IS 'Ensures updated_at is automatically set to current timestamp on every update';



CREATE OR REPLACE TRIGGER "set_user_id_before_insert_books" BEFORE INSERT ON "public"."books" FOR EACH ROW EXECUTE FUNCTION "public"."set_user_id_on_books"();



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_genre_id_fkey" FOREIGN KEY ("genre_id") REFERENCES "public"."genres"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."books"
    ADD CONSTRAINT "books_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "public"."books"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."reading_sessions"
    ADD CONSTRAINT "reading_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Anonymous users can view all genres" ON "public"."genres" FOR SELECT USING (("auth"."role"() = 'anon'::"text"));



COMMENT ON POLICY "Anonymous users can view all genres" ON "public"."genres" IS 'Allows anonymous users to view the genre list (read-only reference data)';



CREATE POLICY "Authenticated users can view all genres" ON "public"."genres" FOR SELECT USING (("auth"."role"() = 'authenticated'::"text"));



COMMENT ON POLICY "Authenticated users can view all genres" ON "public"."genres" IS 'Allows all authenticated users to view the genre list (read-only reference data)';



CREATE POLICY "Enable delete for users based on user_id" ON "public"."books" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Enable users to view their own data only" ON "public"."books" FOR SELECT TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "user_id"));



CREATE POLICY "Users can delete their own reading sessions" ON "public"."reading_sessions" FOR DELETE USING (("auth"."uid"() = "user_id"));



COMMENT ON POLICY "Users can delete their own reading sessions" ON "public"."reading_sessions" IS 'Allows users to delete only their own reading sessions';



CREATE POLICY "Users can insert their own reading sessions" ON "public"."reading_sessions" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



COMMENT ON POLICY "Users can insert their own reading sessions" ON "public"."reading_sessions" IS 'Ensures users can only create reading sessions for their own books';



CREATE POLICY "Users can update their own reading sessions" ON "public"."reading_sessions" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



COMMENT ON POLICY "Users can update their own reading sessions" ON "public"."reading_sessions" IS 'Restricts reading session modifications to the owner only';



CREATE POLICY "Users can view their own reading sessions" ON "public"."reading_sessions" FOR SELECT USING (("auth"."uid"() = "user_id"));



COMMENT ON POLICY "Users can view their own reading sessions" ON "public"."reading_sessions" IS 'Restricts reading session visibility to the owner only';



CREATE POLICY "allow users to insert rows with their id" ON "public"."books" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "allow users to update their rows" ON "public"."books" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."books" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."genres" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."reading_sessions" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."end_reading_session"("p_book_id" "uuid", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_last_read_page" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."end_reading_session"("p_book_id" "uuid", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_last_read_page" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."end_reading_session"("p_book_id" "uuid", "p_start_time" timestamp with time zone, "p_end_time" timestamp with time zone, "p_last_read_page" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."set_user_id_on_books"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_user_id_on_books"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_user_id_on_books"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."books" TO "anon";
GRANT ALL ON TABLE "public"."books" TO "authenticated";
GRANT ALL ON TABLE "public"."books" TO "service_role";



GRANT ALL ON TABLE "public"."genres" TO "anon";
GRANT ALL ON TABLE "public"."genres" TO "authenticated";
GRANT ALL ON TABLE "public"."genres" TO "service_role";



GRANT ALL ON TABLE "public"."reading_sessions" TO "anon";
GRANT ALL ON TABLE "public"."reading_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."reading_sessions" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































RESET ALL;
