<!--
This repository is public. Anything merged here is visible to anyone, and stays
in the history even if a later commit removes it. The checks below are not
bureaucracy: they are the last point at which something can be stopped cheaply.
-->

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

## Safe to publish

<!-- Every PR answers this one. The repository is public. -->

- [ ] **No third-party copyrighted material.** No books, manuals, papers or
      datasets that somebody else owns. Cite them in prose instead of committing
      the file.
- [ ] **No athlete data.** No names, birth dates, times, videos or identifiers,
      not in code, tests, fixtures, screenshots or commit messages.
- [ ] **No credentials.** No API keys, gateway secrets or service-account files.
      They are injected at runtime or build time.
- [ ] I am aware that **removing a file in a later commit does not remove it
      from the history**, and that taking it out for good means rewriting
      history.

## Methodology

<!-- Delete this section if the change does not touch the domain. -->

- [ ] Changes no training rule
- [ ] Changes a rule, and I bumped the version in
      `docs/metodologia/metodologia.json` with its checksum and its note
- [ ] Every new figure the app enforces **can be cited**, and the citation is in
      `docs/metodologia/fundamento_zonas.md`

## Athlete-facing behaviour

<!-- Delete this section if no swimmer ever sees the result of this change. -->

- [ ] Respects the consent gate of principle V of the constitution
- [ ] Reading a plan or progress still works with no network
- [ ] Generated work is still born a draft, marked as generated, and reaches no
      swimmer without the coach's signature

## Left out

<!-- What this PR deliberately leaves undone, so it does not get lost. -->
