#!/bin/bash
set -Eeu -o pipefail

cd "$(dirname "$0")"

echo "Testing error scenarios for pptx2txt.py - Expected ideal behavior"
echo "================================================================="
echo

FAILED_TESTS=0
TEMP_DIR=$(mktemp -d)
trap 'rm -rf $TEMP_DIR' EXIT

# Function to run a test and check both exit code and output
run_test() {
  local test_name="$1"
  local command="$2"
  local expected_exit_code="$3"
  local expected_stderr_pattern="$4"
  local test_description="$5"

  echo "=== $test_name ==="
  echo "Description: $test_description"

  # Run command and capture output
  local actual_exit_code=0
  local stderr_file="$TEMP_DIR/stderr.txt"

  # Run command with both stdout and stderr captured together
  if $command &>"$stderr_file"; then
    actual_exit_code=0
  else
    actual_exit_code=$?
  fi

  # Check exit code
  local exit_code_pass=false
  if [ $actual_exit_code -eq "$expected_exit_code" ]; then
    exit_code_pass=true
    echo "✓ Exit code: $actual_exit_code (expected: $expected_exit_code)"
  else
    echo "✗ Exit code: $actual_exit_code (expected: $expected_exit_code)"
  fi

  # Check stderr content
  local stderr_content
  stderr_content=$(cat "$stderr_file")
  if [ -n "$expected_stderr_pattern" ]; then
    if echo "$stderr_content" | grep -qi "$expected_stderr_pattern"; then
      echo "✓ Expected message pattern found: '$expected_stderr_pattern'"
    else
      echo "✗ Expected message pattern NOT found: '$expected_stderr_pattern'"
      echo "  Current output:"
      echo "$stderr_content" | head -5 | sed 's/^/    /'
      exit_code_pass=false
    fi
  fi

  # Check that Python stack traces should NOT appear
  if echo "$stderr_content" | grep -q "Traceback"; then
    echo "✗ Python stack trace found - not user-friendly!"
    exit_code_pass=false
  else
    echo "✓ No Python stack trace (user-friendly)"
  fi

  if [ "$exit_code_pass" = false ]; then
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi

  echo
}

# Test 1: No arguments
run_test "Test 1: No arguments" \
  "../pptx2txt" \
  "1" \
  "ERROR: No input files specified" \
  "Should show error message when no arguments provided"

# Test 2: Nonexistent file
run_test "Test 2: Nonexistent file" \
  "../pptx2txt nonexistent.pptx" \
  "1" \
  "ERROR: File not found: nonexistent.pptx" \
  "Should show file not found message"

# Test 3: Invalid PPTX file (using pre-created invalid.pptx)
run_test "Test 3: Invalid PPTX file" \
  "../pptx2txt invalid.pptx" \
  "1" \
  "ERROR: Invalid PPTX file: invalid.pptx" \
  "Should show invalid file format message"

# Test 4: Write permission error (using pre-created write_test.txt directory)
run_test "Test 4: Write permission error" \
  "../pptx2txt write_test.pptx" \
  "1" \
  "Cannot write\\|Permission denied\\|unable to write.*write_test.txt\\|Is a directory" \
  "Should show write permission error"

# Test 5: Valid file processing
run_test "Test 5: Valid file processing" \
  "../pptx2txt sample1.pptx" \
  "0" \
  "was saved" \
  "Should process file successfully with success message"
rm -f sample1.txt

echo "========================================="
echo "Test Summary: $((5 - FAILED_TESTS))/5 tests passed"
if [ $FAILED_TESTS -gt 0 ]; then
  echo "Failed tests: $FAILED_TESTS"
  exit 1
fi
