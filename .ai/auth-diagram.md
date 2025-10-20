sequenceDiagram
    autonumber

    participant Użytkownik
    participant Aplikacja Flutter (UI)
    participant AuthService (Service Layer)
    participant Supabase Auth (Backend)

    %% --- Przepływ logowania ---
    Note over Użytkownik, Supabase Auth: Przepływ logowania (US-002)

    Użytkownik->>Aplikacja Flutter (UI): Wprowadza email i hasło
    Aplikacja Flutter (UI)->>AuthService (Service Layer): Wywołuje signInWithPassword(email, password)
    activate AuthService (Service Layer)
    AuthService (Service Layer)->>Supabase Auth (Backend): Żądanie logowania z poświadczeniami
    activate Supabase Auth (Backend)

    alt Dane poprawne
        Supabase Auth (Backend)-->>AuthService (Service Layer): Zwraca sesję użytkownika (JWT)
        deactivate Supabase Auth (Backend)
        AuthService (Service Layer)-->>Aplikacja Flutter (UI): Sukces, strumień onAuthStateChange emituje nowy stan
        deactivate AuthService (Service Layer)
        Aplikacja Flutter (UI)->>Użytkownik: Przekierowanie do ekranu głównego (HomeScreen)
    else Dane niepoprawne
        Supabase Auth (Backend)-->>AuthService (Service Layer): Zwraca błąd (np. 400 Invalid login credentials)
        deactivate Supabase Auth (Backend)
        AuthService (Service Layer)-->>Aplikacja Flutter (UI): Przekazuje wyjątek
        deactivate AuthService (Service Layer)
        Aplikacja Flutter (UI)->>Użytkownik: Wyświetla komunikat o błędzie
    end

    %% --- Przepływ rejestracji ---
    Note over Użytkownik, Supabase Auth: Przepływ rejestracji (US-001)

    Użytkownik->>Aplikacja Flutter (UI): Wprowadza email, hasło i potwierdzenie
    Aplikacja Flutter (UI)->>AuthService (Service Layer): Wywołuje signUp(email, password)
    activate AuthService (Service Layer)
    AuthService (Service Layer)->>Supabase Auth (Backend): Żądanie utworzenia nowego użytkownika
    activate Supabase Auth (Backend)
    Supabase Auth (Backend)-->>AuthService (Service Layer): Potwierdzenie utworzenia użytkownika
    Supabase Auth (Backend)-->>Użytkownik: Wysyła email weryfikacyjny
    deactivate Supabase Auth (Backend)
    AuthService (Service Layer)-->>Aplikacja Flutter (UI): Sukces
    deactivate AuthService (Service Layer)
    Aplikacja Flutter (UI)->>Użytkownik: Wyświetla komunikat o konieczności weryfikacji emaila

    %% --- Przepływ odzyskiwania hasła ---
    Note over Użytkownik, Supabase Auth: Przepływ odzyskiwania hasła (US-017)

    Użytkownik->>Aplikacja Flutter (UI): Wprowadza email na ekranie "Zapomniałem hasła"
    Aplikacja Flutter (UI)->>AuthService (Service Layer): Wywołuje sendPasswordResetEmail(email)
    activate AuthService (Service Layer)
    AuthService (Service Layer)->>Supabase Auth (Backend): Żądanie resetu hasła dla emaila
    activate Supabase Auth (Backend)
    Supabase Auth (Backend)-->>Użytkownik: Wysyła email z linkiem do resetowania hasła
    deactivate Supabase Auth (Backend)
    Supabase Auth (Backend)-->>AuthService (Service Layer): Potwierdzenie wysłania
    deactivate AuthService (Service Layer)
    Aplikacja Flutter (UI)->>Użytkownik: Wyświetla komunikat o wysłaniu instrukcji

    %% --- Wygaśnięcie sesji / Odświeżenie tokenu ---
    Note over Użytkownik, Supabase Auth: Zarządzanie sesją (odświeżanie tokenu)

    Aplikacja Flutter (UI)->>Supabase Auth (Backend): Żądanie do chronionego zasobu z tokenem JWT
    activate Supabase Auth (Backend)
    alt Token wygasł
        Supabase Auth (Backend)-->>Aplikacja Flutter (UI): Odpowiedź 401 Unauthorized
        Note right of Aplikacja Flutter (UI): Klient supabase-flutter automatycznie próbuje odświeżyć token
        Aplikacja Flutter (UI)->>Supabase Auth (Backend): Żądanie odświeżenia tokenu (z refresh tokenem)
        Supabase Auth (Backend)-->>Aplikacja Flutter (UI): Zwraca nowy token JWT
        Aplikacja Flutter (UI)->>Supabase Auth (Backend): Ponawia pierwotne żądanie z nowym tokenem
        Supabase Auth (Backend)-->>Aplikacja Flutter (UI): Zwraca dane zasobu
    else Token ważny
        Supabase Auth (Backend)-->>Aplikacja Flutter (UI): Zwraca dane zasobu
    end
    deactivate Supabase Auth (Backend)