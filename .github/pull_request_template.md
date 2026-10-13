## What changes, and why

<!-- What it solves, in two or three sentences. If it comes from a Spec Kit
     feature, link its folder under `specs/`. -->

## How it was verified

<!-- Tick what you ran. CI runs all of it anyway, but saying so here tells the
     reviewer what to look at. -->

- [ ] `flutter test`
- [ ] `flutter analyze` comes out clean
- [ ] `npm --prefix firebase test`
- [ ] `dart run tool/verificar_metodologia.dart`
- [ ] Tried by hand with `flutter run -d chrome`

## Methodology

<!-- Delete this section if the change does not touch the domain. -->

- [ ] Changes no training rule
- [ ] Changes a rule, and I bumped the version in
      `docs/metodologia/metodologia.json` with its checksum and its note
- [ ] Every new figure the app enforces **can be cited**, and the citation is in
      `docs/metodologia/fundamento_zonas.md`

## Athlete data

<!-- Delete this section if the change does not touch swimmer data. -->

- [ ] Adds no swimmer data and exposes none
- [ ] Adds swimmer data, and respects the consent gate of principle V of the
      constitution
- [ ] No names, times, videos or swimmer identifiers in logs, analytics or tests

## Left out

<!-- What this PR deliberately leaves undone, so it does not get lost. -->
