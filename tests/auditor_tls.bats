@test "Falla si no se define CHECK_URL" {
  unset CHECK_URL
  run "$BATS_TEST_DIRNAME/../src/auditor_tls.sh"
  [ "$status" -ne 0 ]
}