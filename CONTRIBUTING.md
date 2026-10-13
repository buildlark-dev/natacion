# How work happens in this repository

To set the project up, run the tests and understand its layout, see
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md). This document covers only the
workflow.

## A note on language

The repository is bilingual on purpose, and the split is not arbitrary:

| In English | In Spanish |
|---|---|
| Everything GitHub shows: commits, pull requests, README, this file, CI, templates | The UI and every message a user reads |
| Branch names | The methodology documents under `docs/metodologia/` |
| | Feature documents under `specs/` |
| | Domain vocabulary in code: `Zona`, `FaseAtr`, `Microciclo` |

The domain vocabulary stays in Spanish because it maps one to one onto the
coach's normative document. `Zona` in the code *is* the «zona» of section 9.
Translating it would insert a translation layer in the exact place this project
is built to avoid interpretation, and a mistranslation would become a wrong
training rule.

The UI stays in Spanish because the swimmers are Colombian, and some of them are
seven years old.

## Nothing lands on `main` directly

Every change goes on a branch and lands through a pull request, down to one-line
fixes. `main` is what gets deployed and what stamps the methodology version onto
approved plans: it is not written to by hand.

```bash
git checkout -b <type>/<short-description>
```

| Prefix | For |
|---|---|
| `NNN-feature-name` | A Spec Kit feature, with its folder under `specs/` |
| `fix/` | Fixing a defect |
| `docs/` | Documentation only |
| `ci/` | Continuous integration, tooling, repository configuration |
| `chore/` | Maintenance that changes no behaviour |

## CI has to be green

Every pull request runs [`.github/workflows/ci.yml`](.github/workflows/ci.yml):
static analysis, domain and UI tests, the domain boundary, the normative
document checksums, the web build, and the Firestore security rules with their
negative cases.

Running the same thing locally before opening the PR is faster than waiting for
CI:

```bash
flutter analyze && flutter test && dart run tool/verificar_metodologia.dart
```

```bash
npm --prefix firebase test
```

The rules tests need the Firebase CLI and Java 21, because the Firestore
emulator runs on the JVM:

```bash
npm install -g firebase-tools@15.29.0
```

## Features follow the Spec Kit flow

`/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`,
with `/speckit-clarify` when the specification has gaps. Each feature's documents
live in `specs/NNN-name/` and are part of the deliverable: the specification, the
plan and the tasks get reviewed like code.

## Rules that are not up for negotiation

They come from [`.specify/memory/constitution.md`](.specify/memory/constitution.md),
and the pull request template asks about them:

- **The coach's methodology is the norm.** The app does not interpret it, it
  verifies it. If the app enforces a figure, that figure must be citable.
- **The domain is pure Dart.** `lib/dominio/` imports neither Flutter nor
  Firebase, and a test watches for it.
- **Rules that reach a swimmer get tested**, with their negative cases.
- **The coach's judgement is not delegated.** Generated work is born a draft,
  carries a generated marker, and reaches no swimmer without his signature.
- **Athlete data**: verifiable guardian consent is a publication gate. No names,
  times, videos or identifiers in logs or analytics.
- **Not one credential in the repository.** No API key ever travels to the
  client: model calls go through a server.

## Commit messages

In English, imperative mood, prefixed with the type of change:

```text
fix: correct the zone split when a session is not a multiple of the pool length
```

The body explains **why**, not what: the what is already in the diff. When the
change comes from a decision by the coach or from a published source, the body
names it.

Commits made before 2026-10-13 are in Spanish. They are not being rewritten:
history that has already been pushed stays as it is.
