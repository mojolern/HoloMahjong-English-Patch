# HoloMahjong English + Accessibility Patch

An unofficial English and accessibility patch for HoloMahjong.

## First-time installation

1. Download `HoloMahjong-English-Patch-DropIn.zip` from the latest release.
2. Fully close HoloMahjong.
3. Extract the ZIP directly beside `HoloMahjong.exe`.
4. Use `Launch HoloMahjong (English Patch).cmd` to update and launch.

The first-install ZIP includes BepInEx and XUnity AutoTranslator. It does not include the game or original game assets.

## Updates

`Launch HoloMahjong (English Patch).cmd` checks the update manifest before every launch. Files are compared by SHA-256, and only changed patch files are downloaded. `Update HoloMahjong English Patch.cmd` performs the same check without launching the game.

The incremental payload consists only of:

- curated English translations;
- the responsive UI and dialogue plugin;
- three numbered tile atlases.

## Safety

The updater rejects absolute paths and parent-directory traversal, downloads to temporary files, verifies SHA-256 before replacement, and does not modify original game assets.

## Uninstalling

If this was the only BepInEx mod installed, remove `BepInEx`, `dotnet`, `winhttp.dll`, `doorstop_config.ini`, and `.doorstop_version`. Do not remove shared BepInEx files if other mods use them.

This project is unaffiliated with COVER Corporation, hololive production, or the game developers.
