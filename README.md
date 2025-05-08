
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dir2json <img src="man/figures/logo.png" align="right" height="120"/>

<!-- badges: start -->
<!-- badges: end -->

The goal of `dir2json` is to provide a utility for converting
directories into JSON format and decoding JSON back into directory
structures. This is particularly useful for archiving, sharing, or
analyzing directory contents in a structured format. The package can
handle a variety of file types within the directory, including text and
binary files (e.g., images, PDFs), converting them to and from JSON.

## Features

- **Encode a directory**: Convert a directory structure (including its
  files) into a JSON object.

- **Decode a JSON object**: Convert a JSON object back into the original
  directory structure, restoring files and folders.

- **Supports mixed file types**: Handles both text and binary files by
  encoding binary files in base64 and text files as plain text.

- **JSON schema**: The structure of the JSON output follows a defined
  schema, allowing for efficient storage and easy parsing.

### JSON Schema

The JSON schema used by `dir2json` is very simple and flat. Each file
(or directory) is represented by an object with two main fields:

- **`name`**: The file or directory name.

- **`content`**: The content of the file. For text files, this is the
  raw content as a string. For binary files, it is a base64-encoded
  string.

## Installation

You can install the development version of `dir2json` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("parmsam/codebase2json")
```

## Example

This is a basic example which shows you how to encode a directory into
JSON and decode it back:

``` r
library(dir2json)

# Create a temporary directory with a file
example_dir <- tempfile()
dir.create(example_dir)
file.create(file.path(example_dir, "example.txt"))
#> [1] TRUE
writeLines("Hello, dir2json!", file.path(example_dir, "example.txt"))

# Encode the directory to JSON
json_data <- json_encode_dir(example_dir)
cat(json_data)
#> [{"name":"example.txt","content":"Hello, dir2json!\n"}]

# Decode the JSON back to a new directory
new_dir <- tempfile()
json_decode_dir(json_data, new_dir)

# Verify the contents
list.files(new_dir, recursive = TRUE)
#> [1] "example.txt"
readLines(file.path(new_dir, "example.txt"))
#> [1] "Hello, dir2json!"
```

## JSON Encoding and Decoding Process

**Encoding a Directory**: The `json_encode_dir` function traverses the
directory recursively, reading each file and determining if it is a text
or binary file. Text files are directly stored as their contents in the
JSON, while binary files are base64-encoded for safe transport within
the JSON format.

**Decoding a JSON Object**: The `json_decode_dir` function reads the
JSON object, restores the directory structure, and writes files back to
the file system. Binary files are decoded from base64 back to their
original binary format, and text files are written as plain text.
