
# Installation

See full release notes at [sdk.w4.gd](https://sdk.w4.gd).

# Changelog

## [v0.8.0](https://sdk.w4.gd/releases/v0.8.0) - 2024-10-18

### Commits

- Add login_steam and login_auto to W4AuthHelper
- Refactor IDP login
- Update smauth to support multiple providers
- Fix docs syntax and references
- Fix W4LobbyHelper referencing W4GD
- Show profile settings when unconfigured
- Add W4LobbyHelper node
- Implement "safe" timers with consistent behavior
- Allow "test" users login in debug builds
- Add steam login
- Implement auto-refresh via refresh token
- Add async requests auto-retry
- Replace base client auth with smauth
- Implement best-effort promise cancellation
- Add paging to auth admin get_users
- Add create_user admin endpoint
- Add table synchronizer
- Add .gdignore file to the ci folder
- Add sidebar to dashboard, split features in tabs
- Add web builds upload to dashboard
- Customize url/key on export according to profile
- Fix web dashboard link not being updated
- Rework workspace profiles UI
- Fix APIResult debugging
- Add new webrtc modes

### Merge Requests

- Add login_steam and login_auto to W4AuthHelper (see [!52](https://sdk.w4.gd/mrs/52))
- Refactor IDP login (see [!51](https://sdk.w4.gd/mrs/51))
- Update smauth to support multiple providers (see [!50](https://sdk.w4.gd/mrs/50))
- Fix docs syntax and references (see [!49](https://sdk.w4.gd/mrs/49))
- Fix W4LobbyHelper referencing W4GD (see [!48](https://sdk.w4.gd/mrs/48))
- Show profile settings when unconfigured (see [!47](https://sdk.w4.gd/mrs/47))
- Add W4LobbyHelper node (see [!21](https://sdk.w4.gd/mrs/21))
- Implement "safe" timers with consistent behavior (see [!45](https://sdk.w4.gd/mrs/45))
- Add steam login (see [!41](https://sdk.w4.gd/mrs/41))
- Allow "test" users login in debug builds (see [!46](https://sdk.w4.gd/mrs/46))
- Implement auto-refresh via refresh token (see [!44](https://sdk.w4.gd/mrs/44))
- Add async requests auto-retry (see [!43](https://sdk.w4.gd/mrs/43))
- Replace base client auth with smauth (see [!42](https://sdk.w4.gd/mrs/42))
- Implement best-effort promise cancellation (see [!31](https://sdk.w4.gd/mrs/31))
- Add table synchronizer (see [!35](https://sdk.w4.gd/mrs/35))
- Admin endpoints improvements (see [!39](https://sdk.w4.gd/mrs/39))
- Add web builds upload, use sidebar to split dashboard features (see [!34](https://sdk.w4.gd/mrs/34))
- Add .gdignore file to the ci folder (see [!38](https://sdk.w4.gd/mrs/38))
- Customize url/key on export according to profile (see [!37](https://sdk.w4.gd/mrs/37))
- Fix web dashboard link not being updated (see [!36](https://sdk.w4.gd/mrs/36))
- Rework workspace profiles UI (see [!33](https://sdk.w4.gd/mrs/33))
- Fix APIResult debugging (see [!32](https://sdk.w4.gd/mrs/32))
- Add new webrtc modes (see [!24](https://sdk.w4.gd/mrs/24))

## [v0.5.1](https://sdk.w4.gd/releases/v0.5.1) - 2024-06-14

### Commits

- Fix auth helper calling an undefined function
- Fix deep promise result resolution
- Use proxy mode for device login on the Web
- Fix realtime reconnect timer not being freed.
- Track refresh tokens, add refresh token login
- Add method for parallel promises await
- Rename rest-client directory to rest

### Merge Requests

- Fix auth helper calling an undefined function (see [!30](https://sdk.w4.gd/mrs/30))
- Fix deep promise result resolution (see [!29](https://sdk.w4.gd/mrs/29))
- Use proxy mode for device login on the Web (see [!28](https://sdk.w4.gd/mrs/28))
- Track refresh tokens, add refresh token login (see [!26](https://sdk.w4.gd/mrs/26))
- Add method for parallel promises await (see [!25](https://sdk.w4.gd/mrs/25))
- Fix realtime reconnect timer not being freed. (see [!27](https://sdk.w4.gd/mrs/27))
- Rename rest-client directory (see [!23](https://sdk.w4.gd/mrs/23))

## [v0.5.0](https://sdk.w4.gd/releases/v0.5.0) - 2024-05-08

### Commits

- New editor plugin UI

### Merge Requests

- New editor plugin UI (see [!20](https://sdk.w4.gd/mrs/20))

## [v0.4.4](https://sdk.w4.gd/releases/v0.4.4) - 2024-05-08

### Commits

- Fix server uploader preset detection in Godot 4.3
- Fix auth helper error signals argument type

### Merge Requests

- Fix server uploader preset detection in Godot 4.3 (see [!22](https://sdk.w4.gd/mrs/22))
- Fix auth helper error signals argument type (see [!19](https://sdk.w4.gd/mrs/19))

## [v0.4.3](https://sdk.w4.gd/releases/v0.4.3) - 2024-04-04

### Commits

- Move reconnect logic inside module

### Merge Requests

- Move reconnect logic inside module (see [!18](https://sdk.w4.gd/mrs/18))

## [v0.4.2](https://sdk.w4.gd/releases/v0.4.2) - 2024-04-03

### Commits

- Fix watchers using old realtime syntax
- Add Auth node helper
- Fix incorrect lobby delete behavior

### Merge Requests

- Add Auth node helper (see [!13](https://sdk.w4.gd/mrs/13))
- Fix watchers using old realtime syntax (see [!16](https://sdk.w4.gd/mrs/16))
- Fix incorrect lobby delete behavior (see [!15](https://sdk.w4.gd/mrs/15))

## [v0.4.1](https://sdk.w4.gd/releases/v0.4.1) - 2024-03-08

### Commits

- Update to new schema name 'w4analytics'
- Expose request, result, and error types
- Prevent error during signup with email verification
- Fix cyclic references memory leak
- Fix requests lifecycle and memory leak
- Always emit identity_changed on token reset
- Improving handling of empty base urls

### Merge Requests

- Update to new schema name 'w4analytics' (see [!14](https://sdk.w4.gd/mrs/14))
- Expose request, result, and error types (see [!12](https://sdk.w4.gd/mrs/12))
- Prevent error during signup with email verification (see [!10](https://sdk.w4.gd/mrs/10))
- Fix cyclic references memory leaks (see [!9](https://sdk.w4.gd/mrs/9))
- Improve handling of empty credentials (see [!8](https://sdk.w4.gd/mrs/8))

## [v0.4.0](https://sdk.w4.gd/releases/v0.4.0) - 2024-02-12

### Commits

- [**breaking**] Compatibility with W4 Cloud v0.3+
- Automate release process

### Merge Requests

- [**breaking**] Compatibility with W4 Cloud v0.3+ (see [!7](https://sdk.w4.gd/mrs/7))

## [v0.3.2](https://sdk.w4.gd/releases/v0.3.2) - 2024-02-09

### Commits

- Fix packaging command
- Always run tests
- Automate package and release
- Reopen realtime channels which still have subscriptions
- Fix realtime spamming close channel requests
- Fix WebRTCManager emitting signals too soon

### Merge Requests

- Automate package and release (see [!5](https://sdk.w4.gd/mrs/5))
- Fix realtime channel close, reopen channels with active subscriptions (see [!4](https://sdk.w4.gd/mrs/4))
- Fix WebRTCManager emitting signals too soon (see [!3](https://sdk.w4.gd/mrs/3))

## [v0.3.1](https://sdk.w4.gd/releases/v0.3.1) - 2023-11-05

### Commits

- Make W4Client always process
- Rename inner Player class to W4Player

## [v0.3.0](https://sdk.w4.gd/releases/v0.3.0) - 2023-11-02

### Commits

- W4GD IS OPEN SOURCE

