main.dart
├── MyApp (MaterialApp)
    └── MultiBlocProvider
        ├── Providers:
        │   ├── BookService
        │   ├── GenreService
        │   ├── GoogleBooksService
        │   ├── ReadingSessionService
        │   ├── AuthService
        │   ├── OnboardingService
        │   ├── ThemeCubit
        │   ├── AuthBloc
        │   └── OnboardingCubit
        │
        └── AuthGate (BlocBuilder<AuthBloc>)
            ├── [if AuthInitial/AuthLoading]
            │   └── Scaffold
            │       └── CircularProgressIndicator
            │
            ├── [if Authenticated]
            │   └── OnboardingWrapper
            │       └── ShowCaseWidget
            │           └── BlocProvider<HomeScreenBloc>
            │               └── HomeScreenContent
            │                   └── Scaffold
            │                       ├── AppBar (with Showcase)
            │                       │   ├── FilterSortButton
            │                       │   └── IconButton → ProfileScreen
            │                       │
            │                       ├── body: BlocBuilder<HomeScreenBloc>
            │                       │   ├── [if Loading] → LoadingSkeletonWidget
            │                       │   ├── [if Empty] → EmptyStateWidget
            │                       │   └── [if Success]
            │                       │       └── RefreshIndicator
            │                       │           └── BookGrid (with Showcase)
            │                       │               └── BookCard(s) → BookDetailScreen
            │                       │
            │                       └── FloatingActionButton (with Showcase)
            │                           └── → AddBookScreen
            │
            └── [if Unauthenticated]
                └── AuthenticationScreen
                    └── LoginScreen
                        └── Scaffold
                            ├── AppBar
                            └── BlocConsumer<AuthBloc>
                                └── Form
                                    ├── Icon (library_books)
                                    ├── AuthTextField (email)
                                    ├── PasswordField (password)
                                    ├── FilledButton (login)
                                    ├── TextButton → ForgotPasswordScreen
                                    └── TextButton → RegisterScreen

features/auth/view/
│
├── LoginScreen
│   └── Scaffold
│       └── Form
│           ├── Icon
│           ├── AuthTextField (email)
│           ├── PasswordField (password)
│           ├── FilledButton (login)
│           ├── TextButton → ForgotPasswordScreen
│           └── TextButton → RegisterScreen
│
├── RegisterScreen
│   └── Scaffold
│       └── Form
│           ├── Icon
│           ├── AuthTextField (email)
│           ├── PasswordField (password)
│           ├── PasswordField (confirm)
│           ├── FilledButton (register)
│           └── TextButton → LoginScreen
│
├── ForgotPasswordScreen
│   └── Scaffold
│       └── [if email sent]
│           └── SuccessView
│       └── [else]
│           └── Form
│               ├── Icon
│               ├── AuthTextField (email)
│               └── FilledButton (send reset link)
│
└── UpdatePasswordScreen
    └── Scaffold
        └── Form
            ├── Icon
            ├── PasswordField (new password)
            ├── PasswordField (confirm)
            └── FilledButton (update)

features/home/view/
│
├── HomeScreenView (BlocProvider wrapper)
│   └── HomeScreenContent
│
└── HomeScreenContent
    └── Scaffold
        ├── AppBar
        │   ├── FilterSortButton
        │   └── IconButton → ProfileScreen
        │
        ├── body: BlocConsumer<HomeScreenBloc>
        │   ├── [if Loading] → LoadingSkeletonWidget
        │   ├── [if Empty] → EmptyStateWidget
        │   └── [if Success]
        │       └── RefreshIndicator
        │           └── BookGrid
        │               └── BookCard(s) → BookDetailScreen
        │
        └── FloatingActionButton → AddBookScreen

features/add_book/view/
│
├── AddBookScreen
│   └── BlocProvider<AddBookBloc>
│       └── _AddBookView
│           └── Scaffold
│               ├── AppBar
│               └── BlocConsumer<AddBookBloc>
│                   └── SingleChildScrollView
│                       ├── Icon
│                       ├── Text (heading)
│                       ├── IsbnInputField
│                       ├── ScanIsbnButton
│                       ├── FilledButton (search by ISBN)
│                       └── TextButton → BookFormScreen
│
└── BookFormScreen
    └── BlocProvider<AddBookBloc>
        └── _BookFormView
            └── Scaffold
                ├── AppBar
                └── BlocConsumer<AddBookBloc>
                    └── Form
                        ├── TextFormField (title)
                        ├── TextFormField (author)
                        ├── TextFormField (page count)
                        ├── DropdownButtonFormField (genre)
                        ├── TextFormField (cover URL)
                        ├── TextFormField (ISBN)
                        ├── TextFormField (publisher)
                        ├── TextFormField (year)
                        └── FilledButton (save)

features/book_detail/
│
└── BookDetailScreen
    └── BlocProvider<BookDetailsBloc>
        └── _BookDetailView
            └── Scaffold
                ├── AppBar
                │   ├── IconButton (edit) → BookFormScreen
                │   └── PopupMenuButton
                │       ├── Mark as read
                │       └── Delete
                │
                └── BlocConsumer<BookDetailsBloc>
                    └── SingleChildScrollView
                        ├── BookInfoHeader
                        ├── BookProgressIndicator
                        ├── BookActionButtons
                        │   ├── FilledButton → ReadingSessionScreen
                        │   └── OutlinedButton (mark as read)
                        └── ReadingSessionHistory

features/profile/
│
└── ProfileScreen
    └── Scaffold
        ├── AppBar
        └── SingleChildScrollView
            ├── UserInfoCard
            ├── BookStatsCard
            ├── ThemeToggleCard
            ├── AppVersionCard
            └── LogoutButton

features/reading_session/view/
│
└── ReadingSessionScreen
    └── BlocProvider<ReadingSessionBloc>
        └── _ReadingSessionView
            └── Scaffold
                ├── AppBar
                └── BlocListener<ReadingSessionBloc>
                    └── Padding
                        ├── BookInfoHeader
                        ├── StopwatchDisplay
                        └── EndSessionButton
                            └── [on tap] → _EndSessionDialog
                                └── AlertDialog
                                    ├── TextFormField (last page)
                                    ├── TextButton (cancel)
                                    └── FilledButton (save)