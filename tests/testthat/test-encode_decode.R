test_that("json_encode_dir encodes a directory to JSON", {
  dir <- tempfile()
  dir.create(dir)
  file.create(file.path(dir, "test.txt"))
  writeLines("Hello, World!", file.path(dir, "test.txt"))

  json_data <- json_encode_dir(dir)
  expect_true(grepl("test.txt", json_data))
  expect_true(grepl("Hello, World!", json_data))
})

test_that("json_decode_dir decodes JSON to a directory", {
  dir <- tempfile()
  dir.create(dir)
  file.create(file.path(dir, "test.txt"))
  writeLines("Hello, World!", file.path(dir, "test.txt"))

  json_data <- json_encode_dir(dir)

  new_dir <- tempfile()
  json_decode_dir(json_data, new_dir)

  expect_true(file.exists(file.path(new_dir, "test.txt")))
  expect_equal(readLines(file.path(new_dir, "test.txt")), "Hello, World!")
})
