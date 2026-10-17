---
paths:
  - "lib/features/crews/**"
  - "lib/features/custom_character/**"
  - "lib/features/duels/**"
  - "lib/shared/utils/role_icon_mapper.dart"
  - "lib/core/utils/character_localization_mapper.dart"
---

# Domain — user crews, custom characters, duels

## Glossary → code

| Term | Code |
|---|---|
| Crew / nakama | `CrewModel`, `CrewMember`; `CustomCharacterModel.crew` holds the crew **name** |
| Crew role | `CrewMember.role`, `CrewModel.rolesFilled`, `CustomCharacterModel.occupation` |
| Jolly Roger / ship | `jollyRogerUrl`, `boatImageUrl`, `boatName` (AI-generated) |
| Bounty | `bounty` — a **String** like `'3,000,000,000'` |
| Devil fruit | `CustomCharacterModel.devilFruit` stores `DevilFruit.romanName` |
| Haki | `haki` list of stable keys (`Haoshoku…`, `Busoshoku…`, `Kenbunshoku…`) |
| Affiliation | `affiliations` keys (yonkou, admiral, shichibukai, marines, ...) |
| Fighting style | `FightingStyleModel{name, type, weapons, attacks}`; `type`: swordsman, martial_arts, sniper, ... |
| Status | alive / deceased / captured / unknown |
| Signo | zodiac sign derived from `birthDate` (`ZodiacIcons`) |

Data stores stable English keys; text comes from `character_localization_mapper.dart`
and the ARBs.

## Crews (`crews`, Firestore `crews`)

- 11 role keys: `captain`, `viceCaptain`, `helmsman`, `navigator`, `cook`, `doctor`,
  `musician`, `carpenter`, `sharpshooter`, `archaeologist`, `boatswain`.
- **Each role can be filled once** (`rolesFilled`) → at most 11 members.
- **A character belongs to at most one of the user's crews.** Adding a member also
  writes `character.crew = crew.name`.
- Crew name ≥ 3 characters. `captain`/`viceCaptain` store names, not ids.
- Firestore rule: any signed-in user can read crews (public listing); only the owner
  (`userId`, legacy `ownerId`) can update or delete one (`firebase.md`).
- Images come from `ICrewImageService` (Gemini) with a placeholder fallback.
- BLoCs: `ListCrewsBloc`, `CrewDetailsBloc` (`registerFactoryParam` with the crew;
  owns delete / add member / ownership via `IAuthService`), `CreateCrewBloc`
  (`registerFactoryParam` with `userId`), `EditCrewBloc`, `CrewImageCubit` (shared
  by create/edit). Routes `/createCrew`, `/editCrew`, `/listCrews` are private;
  `/crewDetails` is public.
- Debt — don't copy, flag if relevant:
  - Role spelling disagrees: UI writes `viceCaptain`, the repository checks
    `vice-captain`/`vicecaptain`, `updateCrewMember` checks `vice captain`. Use
    `viceCaptain` and normalize at the boundary when you touch it.
  - `DeleteCrew` reloads *all* crews, not the user's.

## Custom characters (Firestore `custom_characters`)

- Owner-only (strict rule). At most **3 occupations**. Age and `signo` are derived
  from `birthDate`. Placeholder image when none is given.
- Deleting a character **cascades**: removed from crews, captain/vice-captain cleared.
- Create can attach to a crew (`crewId`, `crewRole`) in the same flow.
- Routes `/createCustomCharacter`, `/customCharacterList`, `/editCustomCharacter`
  — all private.
- BLoCs: `CustomCharacterBloc` (factory) and `CharacterFormOptionsCubit` (devil
  fruits + user crews for the create/edit form). Bounties are compared as numbers
  (`bountyValue`).
- Editing keeps the stored devil fruit and crew names as the source of truth and
  only looks them up in the loaded options to display them
  (`custom_character/data/character_form_choices.dart`): options that are missing
  or still loading never change what is saved.

## Duels (no persistence)

- `DuelsBloc` loads canon (`getAllOnePieceCharacters(limit: 100)`) + custom
  characters. The same character can't take both slots.
- Score per side:
  - Haki: King's +50, Armament +40, Observation +30
  - Devil fruit +25
  - Affiliation yonkou/admiral/shichibukai/four emperors +30
  - Style: swordsman +20, martial_arts +15, other +10
  - Matchups: Armament vs fruit user +20; Observation vs swordsman/martial_arts +10;
    King's vs no haki +20; fruit user vs Armament −20
  - Random 0–79; **tie goes to character 1**; 2 s suspense delay.
- Keep scoring in a pure, testable function if you change it.
- `DuelsBloc` is a DI factory.
- Loads only the signed-in user's custom characters (`getUserCustomCharacters()`);
  the route is public, so a guest duels canon characters only.
