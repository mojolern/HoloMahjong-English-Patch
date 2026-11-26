# HoloMahjong English + Accessibility Patch

An unofficial English and accessibility patch for HoloMahjong.

## First-time installation

1. Download `HoloMahjong-English-Patch-DropIn.zip` from the latest release.
2. Fully close HoloMahjong.
3. Extract the ZIP directly beside `HoloMahjong.exe`.
4. Launch HoloMahjong normally.

The first-install ZIP includes BepInEx and XUnity AutoTranslator. It does not include the game or original game assets.

## Updates

A small BepInEx preloader checks the update manifest during normal game startup, before translations and accessibility plugins load. Files are compared by SHA-256, and only changed patch files are downloaded. If GitHub cannot be reached, the game continues offline with the installed files.

The incremental payload consists only of:

- curated English translations;
- the responsive UI and dialogue plugin;
- three numbered tile atlases.

When files change, the preloader stages verified downloads, closes the game, applies replacements through a small temporary helper, and relaunches automatically. This permits safe updates even when a DLL would otherwise be locked.

## Safety

The updater rejects absolute paths and parent-directory traversal, downloads to temporary files, verifies SHA-256 before replacement, and does not modify original game assets.

## Uninstalling

If this was the only BepInEx mod installed, remove `BepInEx`, `dotnet`, `winhttp.dll`, `doorstop_config.ini`, and `.doorstop_version`. Do not remove shared BepInEx files if other mods use them.

This project is unaffiliated with COVER Corporation, hololive production, or the game developers.
