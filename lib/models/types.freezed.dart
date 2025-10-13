// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookListItemDto _$BookListItemDtoFromJson(Map<String, dynamic> json) {
  return _BookListItemDto.fromJson(json);
}

/// @nodoc
mixin _$BookListItemDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'genre_id')
  String? get genreId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_count')
  int get pageCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_url')
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  @JsonKey(name: 'publication_year')
  int? get publicationYear => throw _privateConstructorUsedError;
  BOOK_STATUS get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_read_page_number')
  int get lastReadPageNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError; // Embedded genre relation
  GenreEmbeddedDto? get genres => throw _privateConstructorUsedError;

  /// Serializes this BookListItemDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookListItemDtoCopyWith<BookListItemDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookListItemDtoCopyWith<$Res> {
  factory $BookListItemDtoCopyWith(
    BookListItemDto value,
    $Res Function(BookListItemDto) then,
  ) = _$BookListItemDtoCopyWithImpl<$Res, BookListItemDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'genre_id') String? genreId,
    String title,
    String author,
    @JsonKey(name: 'page_count') int pageCount,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
    BOOK_STATUS status,
    @JsonKey(name: 'last_read_page_number') int lastReadPageNumber,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    GenreEmbeddedDto? genres,
  });

  $GenreEmbeddedDtoCopyWith<$Res>? get genres;
}

/// @nodoc
class _$BookListItemDtoCopyWithImpl<$Res, $Val extends BookListItemDto>
    implements $BookListItemDtoCopyWith<$Res> {
  _$BookListItemDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? genreId = freezed,
    Object? title = null,
    Object? author = null,
    Object? pageCount = null,
    Object? coverUrl = freezed,
    Object? isbn = freezed,
    Object? publisher = freezed,
    Object? publicationYear = freezed,
    Object? status = null,
    Object? lastReadPageNumber = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? genres = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            genreId: freezed == genreId
                ? _value.genreId
                : genreId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            pageCount: null == pageCount
                ? _value.pageCount
                : pageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isbn: freezed == isbn
                ? _value.isbn
                : isbn // ignore: cast_nullable_to_non_nullable
                      as String?,
            publisher: freezed == publisher
                ? _value.publisher
                : publisher // ignore: cast_nullable_to_non_nullable
                      as String?,
            publicationYear: freezed == publicationYear
                ? _value.publicationYear
                : publicationYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BOOK_STATUS,
            lastReadPageNumber: null == lastReadPageNumber
                ? _value.lastReadPageNumber
                : lastReadPageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            genres: freezed == genres
                ? _value.genres
                : genres // ignore: cast_nullable_to_non_nullable
                      as GenreEmbeddedDto?,
          )
          as $Val,
    );
  }

  /// Create a copy of BookListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GenreEmbeddedDtoCopyWith<$Res>? get genres {
    if (_value.genres == null) {
      return null;
    }

    return $GenreEmbeddedDtoCopyWith<$Res>(_value.genres!, (value) {
      return _then(_value.copyWith(genres: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookListItemDtoImplCopyWith<$Res>
    implements $BookListItemDtoCopyWith<$Res> {
  factory _$$BookListItemDtoImplCopyWith(
    _$BookListItemDtoImpl value,
    $Res Function(_$BookListItemDtoImpl) then,
  ) = __$$BookListItemDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'genre_id') String? genreId,
    String title,
    String author,
    @JsonKey(name: 'page_count') int pageCount,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
    BOOK_STATUS status,
    @JsonKey(name: 'last_read_page_number') int lastReadPageNumber,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    GenreEmbeddedDto? genres,
  });

  @override
  $GenreEmbeddedDtoCopyWith<$Res>? get genres;
}

/// @nodoc
class __$$BookListItemDtoImplCopyWithImpl<$Res>
    extends _$BookListItemDtoCopyWithImpl<$Res, _$BookListItemDtoImpl>
    implements _$$BookListItemDtoImplCopyWith<$Res> {
  __$$BookListItemDtoImplCopyWithImpl(
    _$BookListItemDtoImpl _value,
    $Res Function(_$BookListItemDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? genreId = freezed,
    Object? title = null,
    Object? author = null,
    Object? pageCount = null,
    Object? coverUrl = freezed,
    Object? isbn = freezed,
    Object? publisher = freezed,
    Object? publicationYear = freezed,
    Object? status = null,
    Object? lastReadPageNumber = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? genres = freezed,
  }) {
    return _then(
      _$BookListItemDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        genreId: freezed == genreId
            ? _value.genreId
            : genreId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        pageCount: null == pageCount
            ? _value.pageCount
            : pageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isbn: freezed == isbn
            ? _value.isbn
            : isbn // ignore: cast_nullable_to_non_nullable
                  as String?,
        publisher: freezed == publisher
            ? _value.publisher
            : publisher // ignore: cast_nullable_to_non_nullable
                  as String?,
        publicationYear: freezed == publicationYear
            ? _value.publicationYear
            : publicationYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BOOK_STATUS,
        lastReadPageNumber: null == lastReadPageNumber
            ? _value.lastReadPageNumber
            : lastReadPageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        genres: freezed == genres
            ? _value.genres
            : genres // ignore: cast_nullable_to_non_nullable
                  as GenreEmbeddedDto?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookListItemDtoImpl implements _BookListItemDto {
  const _$BookListItemDtoImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'genre_id') this.genreId,
    required this.title,
    required this.author,
    @JsonKey(name: 'page_count') required this.pageCount,
    @JsonKey(name: 'cover_url') this.coverUrl,
    this.isbn,
    this.publisher,
    @JsonKey(name: 'publication_year') this.publicationYear,
    required this.status,
    @JsonKey(name: 'last_read_page_number') required this.lastReadPageNumber,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    this.genres,
  });

  factory _$BookListItemDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookListItemDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'genre_id')
  final String? genreId;
  @override
  final String title;
  @override
  final String author;
  @override
  @JsonKey(name: 'page_count')
  final int pageCount;
  @override
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @override
  final String? isbn;
  @override
  final String? publisher;
  @override
  @JsonKey(name: 'publication_year')
  final int? publicationYear;
  @override
  final BOOK_STATUS status;
  @override
  @JsonKey(name: 'last_read_page_number')
  final int lastReadPageNumber;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  // Embedded genre relation
  @override
  final GenreEmbeddedDto? genres;

  @override
  String toString() {
    return 'BookListItemDto(id: $id, userId: $userId, genreId: $genreId, title: $title, author: $author, pageCount: $pageCount, coverUrl: $coverUrl, isbn: $isbn, publisher: $publisher, publicationYear: $publicationYear, status: $status, lastReadPageNumber: $lastReadPageNumber, createdAt: $createdAt, updatedAt: $updatedAt, genres: $genres)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookListItemDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.genreId, genreId) || other.genreId == genreId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.publicationYear, publicationYear) ||
                other.publicationYear == publicationYear) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastReadPageNumber, lastReadPageNumber) ||
                other.lastReadPageNumber == lastReadPageNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.genres, genres) || other.genres == genres));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    genreId,
    title,
    author,
    pageCount,
    coverUrl,
    isbn,
    publisher,
    publicationYear,
    status,
    lastReadPageNumber,
    createdAt,
    updatedAt,
    genres,
  );

  /// Create a copy of BookListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookListItemDtoImplCopyWith<_$BookListItemDtoImpl> get copyWith =>
      __$$BookListItemDtoImplCopyWithImpl<_$BookListItemDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BookListItemDtoImplToJson(this);
  }
}

abstract class _BookListItemDto implements BookListItemDto {
  const factory _BookListItemDto({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'genre_id') final String? genreId,
    required final String title,
    required final String author,
    @JsonKey(name: 'page_count') required final int pageCount,
    @JsonKey(name: 'cover_url') final String? coverUrl,
    final String? isbn,
    final String? publisher,
    @JsonKey(name: 'publication_year') final int? publicationYear,
    required final BOOK_STATUS status,
    @JsonKey(name: 'last_read_page_number')
    required final int lastReadPageNumber,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    final GenreEmbeddedDto? genres,
  }) = _$BookListItemDtoImpl;

  factory _BookListItemDto.fromJson(Map<String, dynamic> json) =
      _$BookListItemDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'genre_id')
  String? get genreId;
  @override
  String get title;
  @override
  String get author;
  @override
  @JsonKey(name: 'page_count')
  int get pageCount;
  @override
  @JsonKey(name: 'cover_url')
  String? get coverUrl;
  @override
  String? get isbn;
  @override
  String? get publisher;
  @override
  @JsonKey(name: 'publication_year')
  int? get publicationYear;
  @override
  BOOK_STATUS get status;
  @override
  @JsonKey(name: 'last_read_page_number')
  int get lastReadPageNumber;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt; // Embedded genre relation
  @override
  GenreEmbeddedDto? get genres;

  /// Create a copy of BookListItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookListItemDtoImplCopyWith<_$BookListItemDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GenreEmbeddedDto _$GenreEmbeddedDtoFromJson(Map<String, dynamic> json) {
  return _GenreEmbeddedDto.fromJson(json);
}

/// @nodoc
mixin _$GenreEmbeddedDto {
  String get name => throw _privateConstructorUsedError;

  /// Serializes this GenreEmbeddedDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenreEmbeddedDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenreEmbeddedDtoCopyWith<GenreEmbeddedDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenreEmbeddedDtoCopyWith<$Res> {
  factory $GenreEmbeddedDtoCopyWith(
    GenreEmbeddedDto value,
    $Res Function(GenreEmbeddedDto) then,
  ) = _$GenreEmbeddedDtoCopyWithImpl<$Res, GenreEmbeddedDto>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class _$GenreEmbeddedDtoCopyWithImpl<$Res, $Val extends GenreEmbeddedDto>
    implements $GenreEmbeddedDtoCopyWith<$Res> {
  _$GenreEmbeddedDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenreEmbeddedDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GenreEmbeddedDtoImplCopyWith<$Res>
    implements $GenreEmbeddedDtoCopyWith<$Res> {
  factory _$$GenreEmbeddedDtoImplCopyWith(
    _$GenreEmbeddedDtoImpl value,
    $Res Function(_$GenreEmbeddedDtoImpl) then,
  ) = __$$GenreEmbeddedDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$GenreEmbeddedDtoImplCopyWithImpl<$Res>
    extends _$GenreEmbeddedDtoCopyWithImpl<$Res, _$GenreEmbeddedDtoImpl>
    implements _$$GenreEmbeddedDtoImplCopyWith<$Res> {
  __$$GenreEmbeddedDtoImplCopyWithImpl(
    _$GenreEmbeddedDtoImpl _value,
    $Res Function(_$GenreEmbeddedDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenreEmbeddedDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null}) {
    return _then(
      _$GenreEmbeddedDtoImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GenreEmbeddedDtoImpl implements _GenreEmbeddedDto {
  const _$GenreEmbeddedDtoImpl({required this.name});

  factory _$GenreEmbeddedDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenreEmbeddedDtoImplFromJson(json);

  @override
  final String name;

  @override
  String toString() {
    return 'GenreEmbeddedDto(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenreEmbeddedDtoImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of GenreEmbeddedDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenreEmbeddedDtoImplCopyWith<_$GenreEmbeddedDtoImpl> get copyWith =>
      __$$GenreEmbeddedDtoImplCopyWithImpl<_$GenreEmbeddedDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GenreEmbeddedDtoImplToJson(this);
  }
}

abstract class _GenreEmbeddedDto implements GenreEmbeddedDto {
  const factory _GenreEmbeddedDto({required final String name}) =
      _$GenreEmbeddedDtoImpl;

  factory _GenreEmbeddedDto.fromJson(Map<String, dynamic> json) =
      _$GenreEmbeddedDtoImpl.fromJson;

  @override
  String get name;

  /// Create a copy of GenreEmbeddedDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenreEmbeddedDtoImplCopyWith<_$GenreEmbeddedDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateBookDto _$CreateBookDtoFromJson(Map<String, dynamic> json) {
  return _CreateBookDto.fromJson(json);
}

/// @nodoc
mixin _$CreateBookDto {
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_count')
  int get pageCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'genre_id')
  String? get genreId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_url')
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  @JsonKey(name: 'publication_year')
  int? get publicationYear => throw _privateConstructorUsedError;

  /// Serializes this CreateBookDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateBookDtoCopyWith<CreateBookDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateBookDtoCopyWith<$Res> {
  factory $CreateBookDtoCopyWith(
    CreateBookDto value,
    $Res Function(CreateBookDto) then,
  ) = _$CreateBookDtoCopyWithImpl<$Res, CreateBookDto>;
  @useResult
  $Res call({
    String title,
    String author,
    @JsonKey(name: 'page_count') int pageCount,
    @JsonKey(name: 'genre_id') String? genreId,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
  });
}

/// @nodoc
class _$CreateBookDtoCopyWithImpl<$Res, $Val extends CreateBookDto>
    implements $CreateBookDtoCopyWith<$Res> {
  _$CreateBookDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? author = null,
    Object? pageCount = null,
    Object? genreId = freezed,
    Object? coverUrl = freezed,
    Object? isbn = freezed,
    Object? publisher = freezed,
    Object? publicationYear = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            author: null == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String,
            pageCount: null == pageCount
                ? _value.pageCount
                : pageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            genreId: freezed == genreId
                ? _value.genreId
                : genreId // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isbn: freezed == isbn
                ? _value.isbn
                : isbn // ignore: cast_nullable_to_non_nullable
                      as String?,
            publisher: freezed == publisher
                ? _value.publisher
                : publisher // ignore: cast_nullable_to_non_nullable
                      as String?,
            publicationYear: freezed == publicationYear
                ? _value.publicationYear
                : publicationYear // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateBookDtoImplCopyWith<$Res>
    implements $CreateBookDtoCopyWith<$Res> {
  factory _$$CreateBookDtoImplCopyWith(
    _$CreateBookDtoImpl value,
    $Res Function(_$CreateBookDtoImpl) then,
  ) = __$$CreateBookDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String author,
    @JsonKey(name: 'page_count') int pageCount,
    @JsonKey(name: 'genre_id') String? genreId,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
  });
}

/// @nodoc
class __$$CreateBookDtoImplCopyWithImpl<$Res>
    extends _$CreateBookDtoCopyWithImpl<$Res, _$CreateBookDtoImpl>
    implements _$$CreateBookDtoImplCopyWith<$Res> {
  __$$CreateBookDtoImplCopyWithImpl(
    _$CreateBookDtoImpl _value,
    $Res Function(_$CreateBookDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? author = null,
    Object? pageCount = null,
    Object? genreId = freezed,
    Object? coverUrl = freezed,
    Object? isbn = freezed,
    Object? publisher = freezed,
    Object? publicationYear = freezed,
  }) {
    return _then(
      _$CreateBookDtoImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        author: null == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String,
        pageCount: null == pageCount
            ? _value.pageCount
            : pageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        genreId: freezed == genreId
            ? _value.genreId
            : genreId // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isbn: freezed == isbn
            ? _value.isbn
            : isbn // ignore: cast_nullable_to_non_nullable
                  as String?,
        publisher: freezed == publisher
            ? _value.publisher
            : publisher // ignore: cast_nullable_to_non_nullable
                  as String?,
        publicationYear: freezed == publicationYear
            ? _value.publicationYear
            : publicationYear // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateBookDtoImpl extends _CreateBookDto {
  const _$CreateBookDtoImpl({
    required this.title,
    required this.author,
    @JsonKey(name: 'page_count') required this.pageCount,
    @JsonKey(name: 'genre_id') this.genreId,
    @JsonKey(name: 'cover_url') this.coverUrl,
    this.isbn,
    this.publisher,
    @JsonKey(name: 'publication_year') this.publicationYear,
  }) : super._();

  factory _$CreateBookDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateBookDtoImplFromJson(json);

  @override
  final String title;
  @override
  final String author;
  @override
  @JsonKey(name: 'page_count')
  final int pageCount;
  @override
  @JsonKey(name: 'genre_id')
  final String? genreId;
  @override
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @override
  final String? isbn;
  @override
  final String? publisher;
  @override
  @JsonKey(name: 'publication_year')
  final int? publicationYear;

  @override
  String toString() {
    return 'CreateBookDto(title: $title, author: $author, pageCount: $pageCount, genreId: $genreId, coverUrl: $coverUrl, isbn: $isbn, publisher: $publisher, publicationYear: $publicationYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateBookDtoImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.genreId, genreId) || other.genreId == genreId) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.publicationYear, publicationYear) ||
                other.publicationYear == publicationYear));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    author,
    pageCount,
    genreId,
    coverUrl,
    isbn,
    publisher,
    publicationYear,
  );

  /// Create a copy of CreateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateBookDtoImplCopyWith<_$CreateBookDtoImpl> get copyWith =>
      __$$CreateBookDtoImplCopyWithImpl<_$CreateBookDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateBookDtoImplToJson(this);
  }
}

abstract class _CreateBookDto extends CreateBookDto {
  const factory _CreateBookDto({
    required final String title,
    required final String author,
    @JsonKey(name: 'page_count') required final int pageCount,
    @JsonKey(name: 'genre_id') final String? genreId,
    @JsonKey(name: 'cover_url') final String? coverUrl,
    final String? isbn,
    final String? publisher,
    @JsonKey(name: 'publication_year') final int? publicationYear,
  }) = _$CreateBookDtoImpl;
  const _CreateBookDto._() : super._();

  factory _CreateBookDto.fromJson(Map<String, dynamic> json) =
      _$CreateBookDtoImpl.fromJson;

  @override
  String get title;
  @override
  String get author;
  @override
  @JsonKey(name: 'page_count')
  int get pageCount;
  @override
  @JsonKey(name: 'genre_id')
  String? get genreId;
  @override
  @JsonKey(name: 'cover_url')
  String? get coverUrl;
  @override
  String? get isbn;
  @override
  String? get publisher;
  @override
  @JsonKey(name: 'publication_year')
  int? get publicationYear;

  /// Create a copy of CreateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateBookDtoImplCopyWith<_$CreateBookDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UpdateBookDto _$UpdateBookDtoFromJson(Map<String, dynamic> json) {
  return _UpdateBookDto.fromJson(json);
}

/// @nodoc
mixin _$UpdateBookDto {
  @JsonKey(name: 'genre_id')
  String? get genreId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  @JsonKey(name: 'page_count')
  int? get pageCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_url')
  String? get coverUrl => throw _privateConstructorUsedError;
  String? get isbn => throw _privateConstructorUsedError;
  String? get publisher => throw _privateConstructorUsedError;
  @JsonKey(name: 'publication_year')
  int? get publicationYear => throw _privateConstructorUsedError;
  BOOK_STATUS? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_read_page_number')
  int? get lastReadPageNumber => throw _privateConstructorUsedError;

  /// Serializes this UpdateBookDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateBookDtoCopyWith<UpdateBookDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateBookDtoCopyWith<$Res> {
  factory $UpdateBookDtoCopyWith(
    UpdateBookDto value,
    $Res Function(UpdateBookDto) then,
  ) = _$UpdateBookDtoCopyWithImpl<$Res, UpdateBookDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'genre_id') String? genreId,
    String? title,
    String? author,
    @JsonKey(name: 'page_count') int? pageCount,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
    BOOK_STATUS? status,
    @JsonKey(name: 'last_read_page_number') int? lastReadPageNumber,
  });
}

/// @nodoc
class _$UpdateBookDtoCopyWithImpl<$Res, $Val extends UpdateBookDto>
    implements $UpdateBookDtoCopyWith<$Res> {
  _$UpdateBookDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? genreId = freezed,
    Object? title = freezed,
    Object? author = freezed,
    Object? pageCount = freezed,
    Object? coverUrl = freezed,
    Object? isbn = freezed,
    Object? publisher = freezed,
    Object? publicationYear = freezed,
    Object? status = freezed,
    Object? lastReadPageNumber = freezed,
  }) {
    return _then(
      _value.copyWith(
            genreId: freezed == genreId
                ? _value.genreId
                : genreId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String?,
            pageCount: freezed == pageCount
                ? _value.pageCount
                : pageCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            coverUrl: freezed == coverUrl
                ? _value.coverUrl
                : coverUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isbn: freezed == isbn
                ? _value.isbn
                : isbn // ignore: cast_nullable_to_non_nullable
                      as String?,
            publisher: freezed == publisher
                ? _value.publisher
                : publisher // ignore: cast_nullable_to_non_nullable
                      as String?,
            publicationYear: freezed == publicationYear
                ? _value.publicationYear
                : publicationYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as BOOK_STATUS?,
            lastReadPageNumber: freezed == lastReadPageNumber
                ? _value.lastReadPageNumber
                : lastReadPageNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateBookDtoImplCopyWith<$Res>
    implements $UpdateBookDtoCopyWith<$Res> {
  factory _$$UpdateBookDtoImplCopyWith(
    _$UpdateBookDtoImpl value,
    $Res Function(_$UpdateBookDtoImpl) then,
  ) = __$$UpdateBookDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'genre_id') String? genreId,
    String? title,
    String? author,
    @JsonKey(name: 'page_count') int? pageCount,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? isbn,
    String? publisher,
    @JsonKey(name: 'publication_year') int? publicationYear,
    BOOK_STATUS? status,
    @JsonKey(name: 'last_read_page_number') int? lastReadPageNumber,
  });
}

/// @nodoc
class __$$UpdateBookDtoImplCopyWithImpl<$Res>
    extends _$UpdateBookDtoCopyWithImpl<$Res, _$UpdateBookDtoImpl>
    implements _$$UpdateBookDtoImplCopyWith<$Res> {
  __$$UpdateBookDtoImplCopyWithImpl(
    _$UpdateBookDtoImpl _value,
    $Res Function(_$UpdateBookDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? genreId = freezed,
    Object? title = freezed,
    Object? author = freezed,
    Object? pageCount = freezed,
    Object? coverUrl = freezed,
    Object? isbn = freezed,
    Object? publisher = freezed,
    Object? publicationYear = freezed,
    Object? status = freezed,
    Object? lastReadPageNumber = freezed,
  }) {
    return _then(
      _$UpdateBookDtoImpl(
        genreId: freezed == genreId
            ? _value.genreId
            : genreId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String?,
        pageCount: freezed == pageCount
            ? _value.pageCount
            : pageCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        coverUrl: freezed == coverUrl
            ? _value.coverUrl
            : coverUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isbn: freezed == isbn
            ? _value.isbn
            : isbn // ignore: cast_nullable_to_non_nullable
                  as String?,
        publisher: freezed == publisher
            ? _value.publisher
            : publisher // ignore: cast_nullable_to_non_nullable
                  as String?,
        publicationYear: freezed == publicationYear
            ? _value.publicationYear
            : publicationYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as BOOK_STATUS?,
        lastReadPageNumber: freezed == lastReadPageNumber
            ? _value.lastReadPageNumber
            : lastReadPageNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateBookDtoImpl extends _UpdateBookDto {
  const _$UpdateBookDtoImpl({
    @JsonKey(name: 'genre_id') this.genreId,
    this.title,
    this.author,
    @JsonKey(name: 'page_count') this.pageCount,
    @JsonKey(name: 'cover_url') this.coverUrl,
    this.isbn,
    this.publisher,
    @JsonKey(name: 'publication_year') this.publicationYear,
    this.status,
    @JsonKey(name: 'last_read_page_number') this.lastReadPageNumber,
  }) : super._();

  factory _$UpdateBookDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UpdateBookDtoImplFromJson(json);

  @override
  @JsonKey(name: 'genre_id')
  final String? genreId;
  @override
  final String? title;
  @override
  final String? author;
  @override
  @JsonKey(name: 'page_count')
  final int? pageCount;
  @override
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  @override
  final String? isbn;
  @override
  final String? publisher;
  @override
  @JsonKey(name: 'publication_year')
  final int? publicationYear;
  @override
  final BOOK_STATUS? status;
  @override
  @JsonKey(name: 'last_read_page_number')
  final int? lastReadPageNumber;

  @override
  String toString() {
    return 'UpdateBookDto(genreId: $genreId, title: $title, author: $author, pageCount: $pageCount, coverUrl: $coverUrl, isbn: $isbn, publisher: $publisher, publicationYear: $publicationYear, status: $status, lastReadPageNumber: $lastReadPageNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateBookDtoImpl &&
            (identical(other.genreId, genreId) || other.genreId == genreId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.pageCount, pageCount) ||
                other.pageCount == pageCount) &&
            (identical(other.coverUrl, coverUrl) ||
                other.coverUrl == coverUrl) &&
            (identical(other.isbn, isbn) || other.isbn == isbn) &&
            (identical(other.publisher, publisher) ||
                other.publisher == publisher) &&
            (identical(other.publicationYear, publicationYear) ||
                other.publicationYear == publicationYear) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastReadPageNumber, lastReadPageNumber) ||
                other.lastReadPageNumber == lastReadPageNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    genreId,
    title,
    author,
    pageCount,
    coverUrl,
    isbn,
    publisher,
    publicationYear,
    status,
    lastReadPageNumber,
  );

  /// Create a copy of UpdateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateBookDtoImplCopyWith<_$UpdateBookDtoImpl> get copyWith =>
      __$$UpdateBookDtoImplCopyWithImpl<_$UpdateBookDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateBookDtoImplToJson(this);
  }
}

abstract class _UpdateBookDto extends UpdateBookDto {
  const factory _UpdateBookDto({
    @JsonKey(name: 'genre_id') final String? genreId,
    final String? title,
    final String? author,
    @JsonKey(name: 'page_count') final int? pageCount,
    @JsonKey(name: 'cover_url') final String? coverUrl,
    final String? isbn,
    final String? publisher,
    @JsonKey(name: 'publication_year') final int? publicationYear,
    final BOOK_STATUS? status,
    @JsonKey(name: 'last_read_page_number') final int? lastReadPageNumber,
  }) = _$UpdateBookDtoImpl;
  const _UpdateBookDto._() : super._();

  factory _UpdateBookDto.fromJson(Map<String, dynamic> json) =
      _$UpdateBookDtoImpl.fromJson;

  @override
  @JsonKey(name: 'genre_id')
  String? get genreId;
  @override
  String? get title;
  @override
  String? get author;
  @override
  @JsonKey(name: 'page_count')
  int? get pageCount;
  @override
  @JsonKey(name: 'cover_url')
  String? get coverUrl;
  @override
  String? get isbn;
  @override
  String? get publisher;
  @override
  @JsonKey(name: 'publication_year')
  int? get publicationYear;
  @override
  BOOK_STATUS? get status;
  @override
  @JsonKey(name: 'last_read_page_number')
  int? get lastReadPageNumber;

  /// Create a copy of UpdateBookDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateBookDtoImplCopyWith<_$UpdateBookDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReadingSessionDto _$ReadingSessionDtoFromJson(Map<String, dynamic> json) {
  return _ReadingSessionDto.fromJson(json);
}

/// @nodoc
mixin _$ReadingSessionDto {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'book_id')
  String get bookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_time')
  DateTime get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'pages_read')
  int get pagesRead => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_read_page_number')
  int get lastReadPageNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReadingSessionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReadingSessionDtoCopyWith<ReadingSessionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingSessionDtoCopyWith<$Res> {
  factory $ReadingSessionDtoCopyWith(
    ReadingSessionDto value,
    $Res Function(ReadingSessionDto) then,
  ) = _$ReadingSessionDtoCopyWithImpl<$Res, ReadingSessionDto>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'book_id') String bookId,
    @JsonKey(name: 'start_time') DateTime startTime,
    @JsonKey(name: 'end_time') DateTime endTime,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'pages_read') int pagesRead,
    @JsonKey(name: 'last_read_page_number') int lastReadPageNumber,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$ReadingSessionDtoCopyWithImpl<$Res, $Val extends ReadingSessionDto>
    implements $ReadingSessionDtoCopyWith<$Res> {
  _$ReadingSessionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bookId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? durationMinutes = null,
    Object? pagesRead = null,
    Object? lastReadPageNumber = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            bookId: null == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            pagesRead: null == pagesRead
                ? _value.pagesRead
                : pagesRead // ignore: cast_nullable_to_non_nullable
                      as int,
            lastReadPageNumber: null == lastReadPageNumber
                ? _value.lastReadPageNumber
                : lastReadPageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReadingSessionDtoImplCopyWith<$Res>
    implements $ReadingSessionDtoCopyWith<$Res> {
  factory _$$ReadingSessionDtoImplCopyWith(
    _$ReadingSessionDtoImpl value,
    $Res Function(_$ReadingSessionDtoImpl) then,
  ) = __$$ReadingSessionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'book_id') String bookId,
    @JsonKey(name: 'start_time') DateTime startTime,
    @JsonKey(name: 'end_time') DateTime endTime,
    @JsonKey(name: 'duration_minutes') int durationMinutes,
    @JsonKey(name: 'pages_read') int pagesRead,
    @JsonKey(name: 'last_read_page_number') int lastReadPageNumber,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$ReadingSessionDtoImplCopyWithImpl<$Res>
    extends _$ReadingSessionDtoCopyWithImpl<$Res, _$ReadingSessionDtoImpl>
    implements _$$ReadingSessionDtoImplCopyWith<$Res> {
  __$$ReadingSessionDtoImplCopyWithImpl(
    _$ReadingSessionDtoImpl _value,
    $Res Function(_$ReadingSessionDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bookId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? durationMinutes = null,
    Object? pagesRead = null,
    Object? lastReadPageNumber = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ReadingSessionDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        bookId: null == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        pagesRead: null == pagesRead
            ? _value.pagesRead
            : pagesRead // ignore: cast_nullable_to_non_nullable
                  as int,
        lastReadPageNumber: null == lastReadPageNumber
            ? _value.lastReadPageNumber
            : lastReadPageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReadingSessionDtoImpl implements _ReadingSessionDto {
  const _$ReadingSessionDtoImpl({
    required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'book_id') required this.bookId,
    @JsonKey(name: 'start_time') required this.startTime,
    @JsonKey(name: 'end_time') required this.endTime,
    @JsonKey(name: 'duration_minutes') required this.durationMinutes,
    @JsonKey(name: 'pages_read') required this.pagesRead,
    @JsonKey(name: 'last_read_page_number') required this.lastReadPageNumber,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$ReadingSessionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReadingSessionDtoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'book_id')
  final String bookId;
  @override
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @override
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'pages_read')
  final int pagesRead;
  @override
  @JsonKey(name: 'last_read_page_number')
  final int lastReadPageNumber;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ReadingSessionDto(id: $id, userId: $userId, bookId: $bookId, startTime: $startTime, endTime: $endTime, durationMinutes: $durationMinutes, pagesRead: $pagesRead, lastReadPageNumber: $lastReadPageNumber, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingSessionDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.pagesRead, pagesRead) ||
                other.pagesRead == pagesRead) &&
            (identical(other.lastReadPageNumber, lastReadPageNumber) ||
                other.lastReadPageNumber == lastReadPageNumber) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    bookId,
    startTime,
    endTime,
    durationMinutes,
    pagesRead,
    lastReadPageNumber,
    createdAt,
  );

  /// Create a copy of ReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingSessionDtoImplCopyWith<_$ReadingSessionDtoImpl> get copyWith =>
      __$$ReadingSessionDtoImplCopyWithImpl<_$ReadingSessionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReadingSessionDtoImplToJson(this);
  }
}

abstract class _ReadingSessionDto implements ReadingSessionDto {
  const factory _ReadingSessionDto({
    required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'book_id') required final String bookId,
    @JsonKey(name: 'start_time') required final DateTime startTime,
    @JsonKey(name: 'end_time') required final DateTime endTime,
    @JsonKey(name: 'duration_minutes') required final int durationMinutes,
    @JsonKey(name: 'pages_read') required final int pagesRead,
    @JsonKey(name: 'last_read_page_number')
    required final int lastReadPageNumber,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$ReadingSessionDtoImpl;

  factory _ReadingSessionDto.fromJson(Map<String, dynamic> json) =
      _$ReadingSessionDtoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'book_id')
  String get bookId;
  @override
  @JsonKey(name: 'start_time')
  DateTime get startTime;
  @override
  @JsonKey(name: 'end_time')
  DateTime get endTime;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'pages_read')
  int get pagesRead;
  @override
  @JsonKey(name: 'last_read_page_number')
  int get lastReadPageNumber;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadingSessionDtoImplCopyWith<_$ReadingSessionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EndReadingSessionDto _$EndReadingSessionDtoFromJson(Map<String, dynamic> json) {
  return _EndReadingSessionDto.fromJson(json);
}

/// @nodoc
mixin _$EndReadingSessionDto {
  @JsonKey(name: 'p_book_id')
  String get bookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'p_start_time')
  DateTime get startTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'p_end_time')
  DateTime get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'p_last_read_page')
  int get lastReadPage => throw _privateConstructorUsedError;

  /// Serializes this EndReadingSessionDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EndReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EndReadingSessionDtoCopyWith<EndReadingSessionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EndReadingSessionDtoCopyWith<$Res> {
  factory $EndReadingSessionDtoCopyWith(
    EndReadingSessionDto value,
    $Res Function(EndReadingSessionDto) then,
  ) = _$EndReadingSessionDtoCopyWithImpl<$Res, EndReadingSessionDto>;
  @useResult
  $Res call({
    @JsonKey(name: 'p_book_id') String bookId,
    @JsonKey(name: 'p_start_time') DateTime startTime,
    @JsonKey(name: 'p_end_time') DateTime endTime,
    @JsonKey(name: 'p_last_read_page') int lastReadPage,
  });
}

/// @nodoc
class _$EndReadingSessionDtoCopyWithImpl<
  $Res,
  $Val extends EndReadingSessionDto
>
    implements $EndReadingSessionDtoCopyWith<$Res> {
  _$EndReadingSessionDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EndReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? lastReadPage = null,
  }) {
    return _then(
      _value.copyWith(
            bookId: null == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastReadPage: null == lastReadPage
                ? _value.lastReadPage
                : lastReadPage // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EndReadingSessionDtoImplCopyWith<$Res>
    implements $EndReadingSessionDtoCopyWith<$Res> {
  factory _$$EndReadingSessionDtoImplCopyWith(
    _$EndReadingSessionDtoImpl value,
    $Res Function(_$EndReadingSessionDtoImpl) then,
  ) = __$$EndReadingSessionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'p_book_id') String bookId,
    @JsonKey(name: 'p_start_time') DateTime startTime,
    @JsonKey(name: 'p_end_time') DateTime endTime,
    @JsonKey(name: 'p_last_read_page') int lastReadPage,
  });
}

/// @nodoc
class __$$EndReadingSessionDtoImplCopyWithImpl<$Res>
    extends _$EndReadingSessionDtoCopyWithImpl<$Res, _$EndReadingSessionDtoImpl>
    implements _$$EndReadingSessionDtoImplCopyWith<$Res> {
  __$$EndReadingSessionDtoImplCopyWithImpl(
    _$EndReadingSessionDtoImpl _value,
    $Res Function(_$EndReadingSessionDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EndReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? lastReadPage = null,
  }) {
    return _then(
      _$EndReadingSessionDtoImpl(
        bookId: null == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastReadPage: null == lastReadPage
            ? _value.lastReadPage
            : lastReadPage // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EndReadingSessionDtoImpl extends _EndReadingSessionDto {
  const _$EndReadingSessionDtoImpl({
    @JsonKey(name: 'p_book_id') required this.bookId,
    @JsonKey(name: 'p_start_time') required this.startTime,
    @JsonKey(name: 'p_end_time') required this.endTime,
    @JsonKey(name: 'p_last_read_page') required this.lastReadPage,
  }) : super._();

  factory _$EndReadingSessionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EndReadingSessionDtoImplFromJson(json);

  @override
  @JsonKey(name: 'p_book_id')
  final String bookId;
  @override
  @JsonKey(name: 'p_start_time')
  final DateTime startTime;
  @override
  @JsonKey(name: 'p_end_time')
  final DateTime endTime;
  @override
  @JsonKey(name: 'p_last_read_page')
  final int lastReadPage;

  @override
  String toString() {
    return 'EndReadingSessionDto(bookId: $bookId, startTime: $startTime, endTime: $endTime, lastReadPage: $lastReadPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EndReadingSessionDtoImpl &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.lastReadPage, lastReadPage) ||
                other.lastReadPage == lastReadPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, bookId, startTime, endTime, lastReadPage);

  /// Create a copy of EndReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EndReadingSessionDtoImplCopyWith<_$EndReadingSessionDtoImpl>
  get copyWith =>
      __$$EndReadingSessionDtoImplCopyWithImpl<_$EndReadingSessionDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EndReadingSessionDtoImplToJson(this);
  }
}

abstract class _EndReadingSessionDto extends EndReadingSessionDto {
  const factory _EndReadingSessionDto({
    @JsonKey(name: 'p_book_id') required final String bookId,
    @JsonKey(name: 'p_start_time') required final DateTime startTime,
    @JsonKey(name: 'p_end_time') required final DateTime endTime,
    @JsonKey(name: 'p_last_read_page') required final int lastReadPage,
  }) = _$EndReadingSessionDtoImpl;
  const _EndReadingSessionDto._() : super._();

  factory _EndReadingSessionDto.fromJson(Map<String, dynamic> json) =
      _$EndReadingSessionDtoImpl.fromJson;

  @override
  @JsonKey(name: 'p_book_id')
  String get bookId;
  @override
  @JsonKey(name: 'p_start_time')
  DateTime get startTime;
  @override
  @JsonKey(name: 'p_end_time')
  DateTime get endTime;
  @override
  @JsonKey(name: 'p_last_read_page')
  int get lastReadPage;

  /// Create a copy of EndReadingSessionDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EndReadingSessionDtoImplCopyWith<_$EndReadingSessionDtoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GenreDto _$GenreDtoFromJson(Map<String, dynamic> json) {
  return _GenreDto.fromJson(json);
}

/// @nodoc
mixin _$GenreDto {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GenreDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GenreDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GenreDtoCopyWith<GenreDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GenreDtoCopyWith<$Res> {
  factory $GenreDtoCopyWith(GenreDto value, $Res Function(GenreDto) then) =
      _$GenreDtoCopyWithImpl<$Res, GenreDto>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$GenreDtoCopyWithImpl<$Res, $Val extends GenreDto>
    implements $GenreDtoCopyWith<$Res> {
  _$GenreDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GenreDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GenreDtoImplCopyWith<$Res>
    implements $GenreDtoCopyWith<$Res> {
  factory _$$GenreDtoImplCopyWith(
    _$GenreDtoImpl value,
    $Res Function(_$GenreDtoImpl) then,
  ) = __$$GenreDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$GenreDtoImplCopyWithImpl<$Res>
    extends _$GenreDtoCopyWithImpl<$Res, _$GenreDtoImpl>
    implements _$$GenreDtoImplCopyWith<$Res> {
  __$$GenreDtoImplCopyWithImpl(
    _$GenreDtoImpl _value,
    $Res Function(_$GenreDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GenreDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$GenreDtoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GenreDtoImpl implements _GenreDto {
  const _$GenreDtoImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$GenreDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$GenreDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'GenreDto(id: $id, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GenreDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, createdAt);

  /// Create a copy of GenreDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GenreDtoImplCopyWith<_$GenreDtoImpl> get copyWith =>
      __$$GenreDtoImplCopyWithImpl<_$GenreDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GenreDtoImplToJson(this);
  }
}

abstract class _GenreDto implements GenreDto {
  const factory _GenreDto({
    required final String id,
    required final String name,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$GenreDtoImpl;

  factory _GenreDto.fromJson(Map<String, dynamic> json) =
      _$GenreDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of GenreDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GenreDtoImplCopyWith<_$GenreDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
