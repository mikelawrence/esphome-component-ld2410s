#!/bin/bash
set -uo pipefail

fix_mode=0
if [[ ${1:-} == "--fix" ]]; then
  fix_mode=1
elif (($#)); then
  echo "Usage: $0 [--fix]" >&2
  exit 2
fi

if ! python -m pip install --disable-pip-version-check --cache-dir /root/.cache/pip \
  -r .devcontainer/requirements-validation.txt; then
  echo "Could not install the pinned validation tools." >&2
  exit 1
fi

if ((fix_mode)); then
  echo "Applying clang-format..."
  mapfile -t cpp_files < <(
    find components -type f \( -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.tcc' \) -print
  )
  if ((${#cpp_files[@]})); then
    clang-format -i "${cpp_files[@]}" || exit $?
  fi

  echo "Applying Ruff formatting and safe lint fixes..."
  ruff format components || exit $?
  ruff check --fix components || exit $?

  mapfile -t python_files < <(find components -type f -name '*.py' -print | sort)
  if ((${#python_files[@]})); then
    echo "Applying pyupgrade..."
    pyupgrade --py310-plus "${python_files[@]}" || exit $?
  fi

  echo "Fixing portable text conventions..."
  python .devcontainer/check_component_conventions.py --fix || exit $?
fi

validation_failed=0

run_check() {
  name=$1
  shift
  echo "Running $name..."
  if "$@"; then
    echo "$name passed."
  else
    status=$?
    echo "$name failed (exit code $status)." >&2
    validation_failed=1
  fi
}

run_check yamllint yamllint --strict .
mapfile -t cpp_files < <(
  find components -type f \( -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' -o -name '*.tcc' \) -print
)
if ((${#cpp_files[@]})); then
  run_check "clang-format" clang-format --dry-run -Werror "${cpp_files[@]}"
fi
run_check "Ruff format" ruff format --check components
run_check "Ruff lint" ruff check components

mapfile -t python_files < <(find components -type f -name '*.py' -print | sort)
if ((${#python_files[@]})); then
  run_check flake8 flake8 "${python_files[@]}"
  run_check pylint pylint -f parseable --persistent=n "${python_files[@]}"

  check_pyupgrade() {
    temp_dir=$(mktemp -d)
    result=0
    for file in "${python_files[@]}"; do
      mkdir -p "$temp_dir/$(dirname "$file")"
      cp -- "$file" "$temp_dir/$file"
      if ! pyupgrade --py310-plus "$temp_dir/$file" >/dev/null; then
        echo "$file: pyupgrade failed" >&2
        result=1
      elif ! cmp -s "$file" "$temp_dir/$file"; then
        echo "$file: pyupgrade changes are required" >&2
        result=1
      fi
    done
    rm -rf -- "$temp_dir"
    return "$result"
  }
  run_check pyupgrade check_pyupgrade
fi

run_check "component conventions" python .devcontainer/check_component_conventions.py

if ((validation_failed)); then
  if ((fix_mode)); then
    echo "Some findings cannot be automatically fixed; review the errors above." >&2
  else
    echo "One or more component validation checks failed." >&2
  fi
  exit 1
fi

echo "All component validation checks passed."
