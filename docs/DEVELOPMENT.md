# Development

Swimming training-plan app built on the coach's methodology, documented in
[`docs/metodologia/`](metodologia/).

The app does not interpret the methodology: **it verifies it**. A plan that
breaks the no-invention rule, the per-category volumes or the ATR distributions
cannot be approved.

> The methodology documents and the feature documents under `specs/` are in
> Spanish, and stay that way: they quote the coach's normative document, and
> translating them would break traceability to it. See the language note in
> [`CONTRIBUTING.md`](../CONTRIBUTING.md).

## What is built

- **Deterministic microcycle generator**: the coach declares category, ATR phase,
  target stroke, the week's accentuated component, days and pool length, and the
  app returns the whole week already squared — volume within the category range,
  the phase's zone distribution, technical percentage, stroke split, and only
  exercises from the official Library. Same inputs, same plan. Offline and free:
  the composition comes from coded rules, not from a language model.
- **If the data is insufficient or contradictory, it generates nothing**: it
  explains what is missing or why it is impossible, with concrete numbers, and
  leaves nothing half-built.
- **Session editor with hybrid input**: the coach writes in his usual notation
  (`4x100 AL SNK PN / 2'`) and the app immediately shows what it understood in
  editable fields. What he corrects by hand wins over the automatic reading.
- **Notation parser** that never throws: when it does not understand something it
  returns partial results and flags the fragment with its exact position.
- **Audit engine** with the eleven criteria of section 16 — four blocking, seven
  justifiable.
- **Plan lifecycle**: `borrador` → `aprobado` → `publicado`. Approving stamps the
  methodology version; an approved plan is immutable.
- **Swimmer profiles** and plan assignment.
- **The swimmer consumes the plan**: they open the app at the poolside, see
  today's session, mark it done, record their RPE and observations, and report
  discomfort in a field of its own. The coach reads all of it next to the
  session that produced it, with external load and internal load side by side
  and never merged into one number.
- **It works with no signal.** Reading the plan, today's session and your own
  progress never waits for the network. Writing offline is kept on the device,
  the app says so, and it goes out on its own when the connection returns.

## Working offline

The split is deliberate, and documented in
[`specs/003-consumo-del-nadador/research.md`](../specs/003-consumo-del-nadador/research.md):

| | Mechanism |
|---|---|
| **Reading** plans and sessions | Firestore's cache. Reimplementing a read cache would be wasted work |
| **Writing** the swimmer's records | An **outbox of our own**, in the domain |

Writing is not delegated to Firestore's offline queue for three reasons: it could
not be tested without testing Firebase, it gives no control over the idempotency
FR-020 needs, and it would make "pending" a reflection of a database detail
instead of a domain concept.

One thing worth knowing rather than discovering later: **offline reading only
covers what was downloaded at least once.** A swimmer who never opened the app
with a connection has nothing to read. The promise the feature keeps is that
once the plan has been obtained, consulting it never needs the network again —
which is why the UI shows when it last synced.

To verify it:

```bash
flutter test test/dominio/sincronizacion/bandeja_salida_test.dart
```

Those are the eight guarantees of the synchronisation contract, in pure Dart with
the network and the clock faked. The swimmer's journey with the network down is
in `test/ui/nadador/`.

**Neither replaces checking it by hand on a real device in flight mode.** A
network emulator is not a swimming pool.

## Requirements

All verified on the development machine:

| Tool | Version |
|---|---|
| Flutter | 3.44+ |
| Dart | 3.12+ |
| Node | 20+ (rules tests only) |
| Firebase CLI | 15+ (rules tests only) |
| Java | 17+ (required by the Firestore emulator) |

## Getting started

Install dependencies:

```bash
flutter pub get
```

Run the app in the browser:

```bash
flutter run -d chrome
```

With local emulators, in two terminals:

```bash
firebase emulators:start --project demo-natacion --config firebase/firebase.json
```

```bash
flutter run -d chrome --dart-define=USAR_EMULADORES=true
```

`demo-natacion` is a dummy project id. The emulators accept it without anything
existing in the cloud, so there is no risk of carelessly writing into a real
project. The flag defaults to false on purpose.

## Tests

Domain, UI and the architecture boundary:

```bash
flutter test
```

Static analysis, which must come out clean:

```bash
flutter analyze
```

Firestore security rules, with their negative cases:

```bash
npm --prefix firebase test
```

Normative document checksums — fails if one changed without bumping the
manifest version:

```bash
dart run tool/verificar_metodologia.dart
```

## Layout

```text
lib/
├── dominio/      Pure Dart. No Flutter, no Firebase. All the rules.
├── datos/        Firestore, in-memory, bundled assets and export.
└── ui/           Screens.

firebase/         Security rules, emulator config and their tests.
docs/metodologia/ Normative source of the domain.
specs/            Specification, plan and tasks for each feature.
tool/             Utilities: Library extraction, Excel reading, checks.
```

A test watches that `lib/dominio/` imports neither Flutter nor Firebase. That is
principle II of the constitution, turned into something the system verifies
instead of something somebody has to remember.

## Regenerating the exercise Library

The Library is extracted from section 19 of the normative document:

```bash
dart run tool/extraer_biblioteca.dart
```

The result **must be reviewed by the coach** before it is taken as valid: a
mistranscribed exercise is a misapplied rule.

## The coach's diagnosis vocabulary

When the coach declares a technical fault, the generator picks the corrective
exercise through the **term index** in
[`assets/biblioteca/terminos_diagnostico.json`](../assets/biblioteca/terminos_diagnostico.json):
every way he names a fault, and the exercises that correspond to it in his order
of priority. He confirmed each correspondence one by one; the record is in
[`docs/metodologia/correspondencia_diagnostico.md`](metodologia/correspondencia_diagnostico.md).

The entries are in Spanish because they are his own words, exactly as he writes
them at the poolside.

What the index tolerates and what it does not:

- `patada desde rodillas` and `patada desde las rodillas` are the same thing.
  Articles, accents and capitals decide nothing.
- `no gira la cadera` and `gira la cadera` are **not** the same thing. The
  negation is never discarded: they are opposite faults.
- `patada` on its own is not enough. It is too generic to pick a corrective, and
  it is reported as a gap.
- **There is no letter-similarity matching.** That tolerance would match
  `patada` with `brazada` before it matched `dosiflexión` with `dorsiflexión`.
  Both spellings of that word are declared as entries of their own.

A phrase that is not in the index is reported as a Library gap. The session's
technical block is then filled from the section 15 progression — a session
cannot be left without technique — but **never** with an exercise picked by eye
for that fault.

The index does **not** modify section 19. The prose of the «error que corrige»
field stays untouched, so the methodology version does not change and approved
plans keep their traceability.

To check what the app finds for any phrase:

```bash
dart run tool/probar_diagnostico.dart "codo bajo" "dosiflexion"
```

To see the full catalogue with its fault field:

```bash
dart run tool/probar_diagnostico.dart --vocabulario
```

## Governance

The project is governed by
[`.specify/memory/constitution.md`](../.specify/memory/constitution.md). Every
feature follows the Spec Kit flow: `/speckit-specify` → `/speckit-plan` →
`/speckit-tasks` → `/speckit-implement`.

How work lands in this repository, and the language split: see
[`CONTRIBUTING.md`](../CONTRIBUTING.md).
