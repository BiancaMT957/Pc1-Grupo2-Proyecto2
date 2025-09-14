@test "Ejecución correcta con https://www.google.com" {
  CHECK_URL="https://www.google.com" \
  OUTPUT_DIR="$BATS_TEST_DIRNAME/../out" \
  run "$BATS_TEST_DIRNAME/../src/auditor_tls.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "HTTP 200" ]]
  [[ "$output" =~ "Resultado final: Todo OK" ]]
}

@test "Fallo representativo: HTTP 404 (not found)" {
  CHECK_URL="https://www.google.com/404notfound" \
  OUTPUT_DIR="$BATS_TEST_DIRNAME/../out" \
  run "$BATS_TEST_DIRNAME/../src/auditor_tls.sh"
  [ "$status" -ne 0 ]
  [[ "$output" =~ "HTTP 404" ]]
  [[ "$output" =~ "Resultado final:" ]]
}

@test "Fallo representativo: HTTP 400 (bad request)" {
  CHECK_URL="https://httpstat.us/400" \
  OUTPUT_DIR="$BATS_TEST_DIRNAME/../out" \
  run "$BATS_TEST_DIRNAME/../src/auditor_tls.sh"
  [ "$status" -ne 0 ]
  [[ "$output" =~ "HTTP 400" ]]
  [[ "$output" =~ "Resultado final:" ]]
}

@test "Falla si no se define CHECK_URL" {
  unset CHECK_URL
  run "$BATS_TEST_DIRNAME/../src/auditor_tls.sh"
  [ "$status" -ne 0 ]
}