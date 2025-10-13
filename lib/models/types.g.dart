// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookListItemDtoImpl _$$BookListItemDtoImplFromJson(
  Map<String, dynamic> json,
) => _$BookListItemDtoImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  genreId: json['genre_id'] as String?,
  title: json['title'] as String,
  author: json['author'] as String,
  pageCount: (json['page_count'] as num).toInt(),
  coverUrl: json['cover_url'] as String?,
  isbn: json['isbn'] as String?,
  publisher: json['publisher'] as String?,
  publicationYear: (json['publication_year'] as num?)?.toInt(),
  status: $enumDecode(_$BOOK_STATUSEnumMap, json['status']),
  lastReadPageNumber: (json['last_read_page_number'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  genres: json['genres'] == null
      ? null
      : GenreEmbeddedDto.fromJson(json['genres'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$BookListItemDtoImplToJson(
  _$BookListItemDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'genre_id': instance.genreId,
  'title': instance.title,
  'author': instance.author,
  'page_count': instance.pageCount,
  'cover_url': instance.coverUrl,
  'isbn': instance.isbn,
  'publisher': instance.publisher,
  'publication_year': instance.publicationYear,
  'status': _$BOOK_STATUSEnumMap[instance.status]!,
  'last_read_page_number': instance.lastReadPageNumber,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'genres': instance.genres,
};

const _$BOOK_STATUSEnumMap = {
  BOOK_STATUS.unread: 'unread',
  BOOK_STATUS.in_progress: 'in_progress',
  BOOK_STATUS.finished: 'finished',
  BOOK_STATUS.abandoned: 'abandoned',
  BOOK_STATUS.planned: 'planned',
};

_$GenreEmbeddedDtoImpl _$$GenreEmbeddedDtoImplFromJson(
  Map<String, dynamic> json,
) => _$GenreEmbeddedDtoImpl(name: json['name'] as String);

Map<String, dynamic> _$$GenreEmbeddedDtoImplToJson(
  _$GenreEmbeddedDtoImpl instance,
) => <String, dynamic>{'name': instance.name};

_$CreateBookDtoImpl _$$CreateBookDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreateBookDtoImpl(
      title: json['title'] as String,
      author: json['author'] as String,
      pageCount: (json['page_count'] as num).toInt(),
      genreId: json['genre_id'] as String?,
      coverUrl: json['cover_url'] as String?,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      publicationYear: (json['publication_year'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CreateBookDtoImplToJson(_$CreateBookDtoImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'author': instance.author,
      'page_count': instance.pageCount,
      'genre_id': instance.genreId,
      'cover_url': instance.coverUrl,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'publication_year': instance.publicationYear,
    };

_$UpdateBookDtoImpl _$$UpdateBookDtoImplFromJson(Map<String, dynamic> json) =>
    _$UpdateBookDtoImpl(
      genreId: json['genre_id'] as String?,
      title: json['title'] as String?,
      author: json['author'] as String?,
      pageCount: (json['page_count'] as num?)?.toInt(),
      coverUrl: json['cover_url'] as String?,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      publicationYear: (json['publication_year'] as num?)?.toInt(),
      status: $enumDecodeNullable(_$BOOK_STATUSEnumMap, json['status']),
      lastReadPageNumber: (json['last_read_page_number'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$UpdateBookDtoImplToJson(_$UpdateBookDtoImpl instance) =>
    <String, dynamic>{
      'genre_id': instance.genreId,
      'title': instance.title,
      'author': instance.author,
      'page_count': instance.pageCount,
      'cover_url': instance.coverUrl,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'publication_year': instance.publicationYear,
      'status': _$BOOK_STATUSEnumMap[instance.status],
      'last_read_page_number': instance.lastReadPageNumber,
    };

_$ReadingSessionDtoImpl _$$ReadingSessionDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ReadingSessionDtoImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  bookId: json['book_id'] as String,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  durationMinutes: (json['duration_minutes'] as num).toInt(),
  pagesRead: (json['pages_read'] as num).toInt(),
  lastReadPageNumber: (json['last_read_page_number'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ReadingSessionDtoImplToJson(
  _$ReadingSessionDtoImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'book_id': instance.bookId,
  'start_time': instance.startTime.toIso8601String(),
  'end_time': instance.endTime.toIso8601String(),
  'duration_minutes': instance.durationMinutes,
  'pages_read': instance.pagesRead,
  'last_read_page_number': instance.lastReadPageNumber,
  'created_at': instance.createdAt.toIso8601String(),
};

_$EndReadingSessionDtoImpl _$$EndReadingSessionDtoImplFromJson(
  Map<String, dynamic> json,
) => _$EndReadingSessionDtoImpl(
  bookId: json['p_book_id'] as String,
  startTime: DateTime.parse(json['p_start_time'] as String),
  endTime: DateTime.parse(json['p_end_time'] as String),
  lastReadPage: (json['p_last_read_page'] as num).toInt(),
);

Map<String, dynamic> _$$EndReadingSessionDtoImplToJson(
  _$EndReadingSessionDtoImpl instance,
) => <String, dynamic>{
  'p_book_id': instance.bookId,
  'p_start_time': instance.startTime.toIso8601String(),
  'p_end_time': instance.endTime.toIso8601String(),
  'p_last_read_page': instance.lastReadPage,
};

_$GenreDtoImpl _$$GenreDtoImplFromJson(Map<String, dynamic> json) =>
    _$GenreDtoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$GenreDtoImplToJson(_$GenreDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$GoogleBookResultImpl _$$GoogleBookResultImplFromJson(
  Map<String, dynamic> json,
) => _$GoogleBookResultImpl(
  title: json['title'] as String,
  authors: (json['authors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  publisher: json['publisher'] as String?,
  publishedDate: json['publishedDate'] as String?,
  pageCount: (json['pageCount'] as num?)?.toInt(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  imageLinks: json['imageLinks'] == null
      ? null
      : ImageLinks.fromJson(json['imageLinks'] as Map<String, dynamic>),
  industryIdentifiers: (json['industryIdentifiers'] as List<dynamic>?)
      ?.map((e) => IndustryIdentifier.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$GoogleBookResultImplToJson(
  _$GoogleBookResultImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'authors': instance.authors,
  'publisher': instance.publisher,
  'publishedDate': instance.publishedDate,
  'pageCount': instance.pageCount,
  'categories': instance.categories,
  'imageLinks': instance.imageLinks,
  'industryIdentifiers': instance.industryIdentifiers,
};

_$ImageLinksImpl _$$ImageLinksImplFromJson(Map<String, dynamic> json) =>
    _$ImageLinksImpl(
      smallThumbnail: json['smallThumbnail'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );

Map<String, dynamic> _$$ImageLinksImplToJson(_$ImageLinksImpl instance) =>
    <String, dynamic>{
      'smallThumbnail': instance.smallThumbnail,
      'thumbnail': instance.thumbnail,
    };

_$IndustryIdentifierImpl _$$IndustryIdentifierImplFromJson(
  Map<String, dynamic> json,
) => _$IndustryIdentifierImpl(
  type: json['type'] as String,
  identifier: json['identifier'] as String,
);

Map<String, dynamic> _$$IndustryIdentifierImplToJson(
  _$IndustryIdentifierImpl instance,
) => <String, dynamic>{
  'type': instance.type,
  'identifier': instance.identifier,
};
