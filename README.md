# MoisesSearch

iOS app for searching the **iTunes Search API**, playing **30-second previews**, and browsing the **album** behind a track. Built as a code challenge with a focus on architecture, edge cases, and automated tests.

---

## Demo

Walkthroughs of the main flows on **iPhone** and **iPad**:

| iPhone | iPad |
|--------|------|
| [![Watch on YouTube — iPhone](https://img.youtube.com/vi/PqudXLYePZk/maxresdefault.jpg)](https://youtu.be/PqudXLYePZk) | [![Watch on YouTube — iPad](https://img.youtube.com/vi/kyBLiLmT2ak/maxresdefault.jpg)](https://youtu.be/kyBLiLmT2ak) |

---

## Highlights

- **Playback:** `AVPlayer` drives real previews — periodic time observer for the slider, scrubbing seeks, end-of-track advances the queue when possible, `AVAudioSession` configured for playback with the silent switch.
- **Offline-first home:** with an empty search field, **recently played** tracks load from **SwiftData** without network.
- **Replaceable networking:** requests are built from `TargetType` targets and executed through `APIClientType`, so swapping the iTunes implementation stays localized.
- **Adaptive UI:** **Light and Dark** appearances are both first-class across the main flows; on regular width, the player adds a **queue sidebar** and the album screen scales typography and hero artwork. Snapshots cover compact and regular size classes where layout diverges.
- **Tests:** Swift Testing with **`.unit`** / **`.snapshot`** tags; unit tests for view models, mappers, and persistence; snapshot tests across screens (both appearances, Dynamic Type, RTL where relevant).

---

## Features

| Screen | What it does |
|--------|----------------|
| **Splash** | Branded intro (~1.5 s), then cross-fades into Songs Home. |
| **Songs Home** | Debounced search (300 ms). Empty query shows SwiftData recents. Collapsing header, retryable errors, distinct empty vs. no-results states. |
| **Player** | Preview playback, scrubbing, prev/next, auto-advance at end of track. Toolbar opens **View album** when the track has a `collectionId`. iPad: queue sidebar. |
| **Album** | Hero + track list from iTunes `/lookup`, with loading / loaded / error. |
| **Errors & empty states** | Shared **`RetryableErrorView`** for failed fetches. Player shows a **Preview unavailable** note when there is no preview URL or the asset fails to load. |

---

## Tech stack

- **Swift 6** — strict concurrency; `@MainActor` on view models and persistence boundaries where appropriate.
- **SwiftUI** + **`@Observable`** view models.
- **MVVM** — view models depend on repository **protocols**, not concrete network or SwiftData types.
- **Swift concurrency** — `async/await`, structured tasks, cancellation for debounced search and async loads.
- **SwiftData** — recently played (offline-first empty state).
- **AVFoundation** — preview playback.
- **iTunes Search API** — [`/search`](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html), `/lookup`.
- **swift-snapshot-testing** + **Swift Testing** — tagged suites for selective runs.

---

## Architecture

Layered modules in a single iOS target. View models depend on protocols; wiring lives in **`MoisesSearchApp`**.

```
MoisesSearch/
├── App/                       MoisesSearchApp, AppRoute
├── Common/                    RetryableErrorView
├── Domain/
│   ├── Models/                SongListItem, AlbumDetail
│   └── Repositories/          SongSearchRepository, AlbumRepository, PlaybackHistoryRepository
├── Data/
│   ├── Network/               TargetType, APIClient(Type), HTTPMethod, APIError
│   │   └── ITunes/            ITunesSearchTarget, DTOs, ITunesSongSearchRepository, ITunesAlbumRepository
│   └── Persistence/           PlayedTrackEntity, SwiftDataPlaybackHistoryRepository, EmptyPlaybackHistoryRepository
└── Features/
    ├── Splash/                SplashView
    ├── SongsHome/             View, ViewModel, SupportViews/…
    ├── Player/                PlayerView, PlayerViewModel, PlaybackQueue, SupportViews/…
    └── Album/                 AlbumView, AlbumViewModel, AlbumTrackRowView, SupportViews/…
MoisesSearchTests/
├── Tests/                     Unit (.unit)
├── SnapshotTests/             Snapshots (.snapshot)
├── Doubles/                   MockSongSearchRepository, MockAlbumRepository, MockPlaybackHistoryRepository
└── Utils/                     Snapshot helpers, test tags
```

**Composition:** `MoisesSearchApp` creates the SwiftData container, **`ITunesAlbumRepository`**, and **`SongsHomeViewModel`**. `SongsHomeView` receives the album repository for the **`.album(collectionId:)`** destination.

**Queue:** `PlaybackQueue` is owned by **`SongsHomeViewModel`**. Starting playback **snapshots** the visible list at tap time; album playback routes through the same coordinator so there is one queue story.

**Navigation:** **`AppRoute`** (`.player`, `.album(collectionId:)`) backs **`NavigationStack`**. The player reports “view album” via a callback; it does not own the path.

---

## Main flows

| Flow | Path |
|------|------|
| **Launch** | Splash → cross-fade → Songs Home. |
| **Search** | Debounced query → `ITunesSongSearchRepository`; stale work cancelled on new input. |
| **Empty field** | SwiftData `recentTracks`; first launch → “No searches yet”. |
| **Play from home** | Record play → fill `PlaybackQueue` from the current list → push `.player`. |
| **Player → album** | Toolbar or row **View album** → `.album(collectionId:)` when `collectionId` exists. |
| **Album → play** | Row tap → `AlbumViewModel` → `SongsHomeViewModel.playTracks(_:startAt:)` → player with album as queue. |

---

## Reliability & testing notes

- **Empty vs. no results:** `EmptySearchPlaceholderView` covers both (empty/recents vs. query with zero hits).
- **API errors:** `RetryableErrorView` + `retrySearch()` / album reload; messages use `localizedDescription`.
- **Recents:** upsert on playback (best-effort); empty query reads SwiftData only.
- **Playback:** `PlayerViewModel` holds `AVPlayer`; dismiss stops audio. No preview URL or failed load → disabled play + footnote; prev/next still move the queue.
- **Snapshots:** `RECORD_SNAPSHOTS=1` in the scheme drives centralized recording; mocks live under **`MoisesSearchTests/Doubles/`**.

---

## How to run

**Requirements:** Xcode 17+, iOS 18+ simulator or device.

1. Open **`MoisesSearch.xcodeproj`**.
2. Select the **MoisesSearch** scheme.
3. Build and run.

Set a **Development Team** if signing prompts appear. SPM resolves **swift-snapshot-testing** via the project’s package settings.

**Tests** (adjust simulator name to match your install):

```bash
xcodebuild test \
  -project MoisesSearch.xcodeproj \
  -scheme MoisesSearch \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Filter by tag in the Test navigator (**⌘6**), or narrow with `-only-testing:` to a specific test class or suite.

**Re-record snapshots** after intentional UI changes:

```bash
RECORD_SNAPSHOTS=1 xcodebuild test \
  -project MoisesSearch.xcodeproj \
  -scheme MoisesSearch \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:MoisesSearchTests/<SuiteName>
```

---

## Design choices (short list)

- **Album coordination:** `AlbumViewModel` takes an `onPlayTracks` closure instead of a one-off protocol — single consumer, single implementation.
- **iTunes `/lookup`:** permissive DTO + post-decode partition of mixed `results` (collection + tracks) instead of a fragile custom `Decodable` tree.
- **`didSet` on `isPlaying`:** keeps play/pause side effects in one place for bindings and programmatic updates.
- **`loadGeneration` in `PlayerViewModel`:** avoids stale duration writes when skipping faster than network resolves.
- **Snapshot seams:** selected `PlayerViewModel` properties are mutable for tests to pin states without a heavy mock framework.
- **Composition root:** stays in **`MoisesSearchApp`** — splash is a `ZStack` + flag, no separate coordinator type.

---

## Notes for reviewers

- Search uses **one bounded request** (`limit: 25`) — **no pagination** or infinite scroll; tests assume that contract.
- **iPad** is treated as first-class where layout differs (player sidebar, album hero).
- **watchOS** target exists but is **out of scope** for this submission.
- **Background audio / Now Playing** are **not** in scope; audio stops when leaving the player.
- Default App Transport Security; iTunes assets are HTTPS.

The presentation layer is structured so that incremental visual refinement—motion, illustration, or micro-interactions—can ship on top of the current flows without revisiting the architecture.

**Entry point:** `MoisesSearch/App/MoisesSearchApp.swift`.
