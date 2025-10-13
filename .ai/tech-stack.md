# Stos Technologiczny Projektu "My Book Library"

## Frontend

- **Flutter/Dart**: Do budowy wieloplatformowej aplikacji mobilnej. W ramach MVP skupiamy się na platformie Android, ale Flutter zapewni łatwą rozbudowę o wsparcie dla iOS i Web w przyszłości. Umożliwia szybki rozwój interfejsu użytkownika.

## Backend i baza danych

- **Supabase**: Platforma typu Backend-as-a-Service (BaaS), która dostarcza kluczowe funkcjonalności bez potrzeby pisania własnego serwera.
  - **Supabase Auth**: Do obsługi uwierzytelniania użytkowników (rejestracja, logowanie).
  - **Baza Danych PostgreSQL**: Do przechowywania danych o książkach, użytkownikach i sesjach czytania. Bezpieczeństwo danych będzie zapewnione przez mechanizm Row Level Security (RLS).
  - **Auto-generowane API**: Do komunikacji między aplikacją a bazą danych.

## CI/CD

- **GitHub Actions**: Do automatyzacji procesów budowania i testowania aplikacji. Potok CI/CD będzie uruchamiany przy każdej zmianie w kodzie, aby zapewnić jego wysoką jakość i stabilność
