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

test_that("json_encode_dir respects the type parameter", {
  dir <- tempfile()
  dir.create(dir)
  
  # Create text and binary files
  text_file <- file.path(dir, "test.txt")
  binary_file <- file.path(dir, "test.bin")
  file.create(text_file)
  file.create(binary_file)
  writeLines("This is a text file.", text_file)
  writeBin(as.raw(1:10), binary_file)

  # Test for text files only
  json_data_text <- json_encode_dir(dir, type = "text")
  expect_true(grepl("test.txt", json_data_text))
  expect_false(grepl("test.bin", json_data_text))

  # Test for binary files only
  json_data_binary <- json_encode_dir(dir, type = "binary")
  expect_false(grepl("test.txt", json_data_binary))
  expect_true(grepl("test.bin", json_data_binary))

  # Test for both text and binary files
  json_data_both <- json_encode_dir(dir, type = c("text", "binary"))
  expect_true(grepl("test.txt", json_data_both))
  expect_true(grepl("test.bin", json_data_both))
})
