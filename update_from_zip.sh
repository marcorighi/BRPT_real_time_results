#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR"

ZIP_PATH="${1:-$REPO_DIR/../results_no_csv.zip}"
COMMIT_PREFIX="${COMMIT_PREFIX:-BRPT results snapshot}"

if [[ ! -f "$ZIP_PATH" ]]; then
    echo "ERRORE: archivio non trovato: $ZIP_PATH" >&2
    echo "Uso: $0 /percorso/copy_result_github.zip" >&2
    exit 1
fi

command -v unzip >/dev/null 2>&1 || {
    echo "ERRORE: comando 'unzip' non disponibile." >&2
    exit 1
}

command -v rsync >/dev/null 2>&1 || {
    echo "ERRORE: comando 'rsync' non disponibile." >&2
    exit 1
}

command -v git >/dev/null 2>&1 || {
    echo "ERRORE: comando 'git' non disponibile." >&2
    exit 1
}

if [[ ! -d "$REPO_DIR/.git" ]]; then
    echo "ERRORE: $REPO_DIR non è un repository Git." >&2
    exit 1
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/brpt-results-import.XXXXXX")"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

echo "Verifica integrità ZIP..."
unzip -tq "$ZIP_PATH" >/dev/null

echo "Estrazione in staging temporaneo..."
unzip -q "$ZIP_PATH" -d "$TMP_DIR"

echo "Validazione di tutti i JSON trasferiti..."
python3 - "$TMP_DIR" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
files = sorted(root.rglob("*.json"))

if not files:
    raise SystemExit("ERRORE: nessun file JSON presente nello snapshot.")

errors = []
for path in files:
    try:
        if path.stat().st_size == 0:
            raise ValueError("file vuoto")
        with path.open("r", encoding="utf-8") as fh:
            json.load(fh)
    except Exception as exc:
        errors.append((path.relative_to(root), exc))

if errors:
    print("ERRORE: JSON non valido/i:", file=sys.stderr)
    for path, exc in errors:
        print(f"  - {path}: {exc}", file=sys.stderr)
    raise SystemExit(2)

print(f"OK: {len(files)} JSON validati.")
PY

RESULT_DIRS=(
    results_ring
    results_primes
    results_c21
    results_psps
    results_galois
    results_plots
)

found=0
for name in "${RESULT_DIRS[@]}"; do
    src="$TMP_DIR/$name"
    dst="$REPO_DIR/$name"

    if [[ -d "$src" ]]; then
        found=1
        mkdir -p "$dst"
        rsync -a --delete "$src/" "$dst/"
    fi
done

if [[ "$found" -eq 0 ]]; then
    echo "ERRORE: lo ZIP non contiene nessuna directory results_* attesa." >&2
    exit 1
fi

echo "Seconda validazione dei JSON nel repository..."
python3 - "$REPO_DIR" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
errors = []

for dirname in (
    "results_ring",
    "results_primes",
    "results_c21",
    "results_psps",
    "results_galois",
    "results_plots",
):
    d = root / dirname
    if not d.is_dir():
        continue
    for path in sorted(d.rglob("*.json")):
        try:
            if path.stat().st_size == 0:
                raise ValueError("file vuoto")
            with path.open("r", encoding="utf-8") as fh:
                json.load(fh)
        except Exception as exc:
            errors.append((path.relative_to(root), exc))

if errors:
    print("ERRORE: validazione post-copia fallita:", file=sys.stderr)
    for path, exc in errors:
        print(f"  - {path}: {exc}", file=sys.stderr)
    raise SystemExit(3)

print("OK: JSON del repository validi.")
PY

cd "$REPO_DIR"

git add -A -- \
    README.md \
    index.html \
    .nojekyll \
    .gitignore \
    update_from_zip.sh \
    results_ring \
    results_primes \
    results_c21 \
    results_psps \
    results_galois \
    results_plots 2>/dev/null || git add -A

if git diff --cached --quiet; then
    echo "Nessuna modifica rispetto all'ultimo snapshot."
    exit 0
fi

STAMP="$(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git commit -m "$COMMIT_PREFIX - $STAMP"
git push origin main

echo
echo "OK: snapshot BRPT importato e pubblicato."
echo "Commit: $(git rev-parse --short HEAD)"
