---
paths:
  - "lib/features/one_piece/**"
  - "lib/features/devil_fruit/**"
  - "lib/features/home/**"
  - "lib/features/youtube/**"
  - "lib/features/fav_character_selection/**"
  - "lib/core/services/one_piece/**"
  - "lib/core/services/youtube/**"
---

# Domain — One Piece catalog

Read-mostly canon content: characters, devil fruits, the daily featured character
and AMV videos. All routes here are public.

## one_piece — character catalog

- `CharactersCubit` + `SearchCubit` (`lib/features/one_piece/bloc/`) over
  `IFeaturedCharacterRepository` (owned by `home`). Both are provided globally in
  `main.dart`.
- Canon characters reuse `CustomCharacterModel` (`isCustomCharacter => userId != null`).
- Search: case-insensitive over name, nickname, affiliations, crew. **One filter at
  a time** (`addStatusFilter` clears the others). An empty filter result falls back
  to the full list. "Straw Hat" is special-cased.
- Routes: `/onePiece`, `/characterDetails` (arg `CustomCharacterModel`).
- Debt: no data/ folder; `hasMoreData` is just `_characters.isEmpty`; a hardcoded
  1 s delay; `character_selection_grid.dart` calls `getIt<SearchCubit>()` directly.

## devil_fruit — encyclopedia

- `DevilFruit` (`@JsonSerializable`): `id`, `name`, `description`, `romanName`
  (`roman_name`), `type` (Paramecia / Zoan / Logia), `filename`, `technicalFile`.
- Source: One Piece API via Dio, base URL from `IEnvironmentService.devilFruitApiUrl`
  (default `https://api.api-onepiece.com/v2/fruits/en`). In-memory cache only.
- `DevilFruitBloc` depends on `IDevilFruitService` directly (no repository).
- Debt: `DevilFruitLoaded.copyWith` can't reset `selectedType`, so clearing the type
  filter leaves the chip selected.

## home — dashboard

- `IFeaturedCharacterRepository` composes Firestore `featuredCharacters` (global
  catalog) + Hive box `featured_character_box` (key `current_featured_character`,
  `TodayCharacter`).
- **Character of the day:** if the cached `TodayCharacter.isToday`, reuse it;
  otherwise pick randomly from 100 and cache. A manual pick sets
  `isManuallySelected = true`. Falls back to Luffy when nothing loads.
- `HomeBloc` also loads an AMV for the character via `IYouTubeService`, and has an
  `Offline` state.
- Debt: `HomeBloc` injects `ConnectivityCubit` (BLoC→BLoC).

## youtube

- `IYouTubeService` searches `q="<name> AMV One Piece"` on the YouTube Data API
  (`YOUTUBE_API_KEY`). Quota errors fall back to mock videos — keep that behaviour.
- `/youtubePlayer` (arg `YouTubeVideo`). YouTube red in the player is an allowed
  brand colour.

## fav_character_selection

`/characterSelection` returns the chosen `CustomCharacterModel` via
`Navigator.pop`. Wraps the shared `CharacterSelectionGrid`; no bloc of its own.
