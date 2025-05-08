#' Encode a Directory to JSON
#'
#' This function encodes all files in a directory into a JSON format.
#'
#' @param dir A character string specifying the directory to encode.
#' @param type A character vector specifying the file types to include
#' ("text", "binary", or both). Defaults to both.
#' @param metadata A character vector specifying additional metadata to
#'  include in the JSON (e.g., "file_size", "creation_time", 
#' "last_modified_time"). Defaults to NULL.
#' @param ignore A character vector specifying file names or patterns to exclude from encoding. Defaults to NULL.
#' @return A JSON string representing the directory's contents.
#' @export
json_encode_dir <- function(dir, type = c("text", "binary"), metadata = NULL, ignore = NULL) {
  stopifnot(fs::dir_exists(dir))
  
  type <- match.arg(type, several.ok = TRUE)
  
  files <- fs::dir_ls(dir, recurse = TRUE, type = "file")
  files <- fs::path_abs(files)
  files <- files[!grepl("^(\\.|_)", fs::path_file(files))]
  
  if (!is.null(ignore)) {
    files <- files[!fs::path_file(files) %in% ignore]
  }
  
  names <- fs::path_rel(files, dir)
  
  files <- Filter(function(file) {
    ext <- tolower(fs::path_ext(file))
    if ("text" %in% type && ext %in% text_file_extensions()) {
      return(TRUE)
    }
    if ("binary" %in% type && !(ext %in% text_file_extensions())) {
      return(TRUE)
    }
    return(FALSE)
  }, files)
  
  bundle <- unname(Map(function(file, name) {
    file_list <- as_file_list(file, name)
    if (!is.null(metadata)) {
      if ("file_size" %in% metadata) {
        file_list$file_size <- fs::file_size(file)
      }
      if ("creation_time" %in% metadata) {
        file_list$creation_time <- fs::file_info(file)$birth_time
      }
      if ("last_modified_time" %in% metadata) {
        file_list$last_modified_time <- fs::file_info(file)$modification_time
      }
    }
    file_list
  }, files, names))
  
  bundle <- jsonlite::toJSON(bundle, auto_unbox = TRUE, null = "null", na = "null")
  
  return(bundle)
}

#' Decode JSON to a Directory
#'
#' This function decodes a JSON string into a directory structure.
#'
#' @param json_data A JSON string representing the directory's contents.
#' @param dir A character string specifying the target directory.
#' @return None. Creates files in the specified directory.
#' @export
json_decode_dir <- function(json_data, dir) {
  sl_app <- jsonlite::fromJSON(json_data, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE)
  
  if (!fs::dir_exists(dir)) {
    fs::dir_create(dir)
  }
  
  write_files(sl_app, dir)
}

#' Write Files to a Directory
#'
#' This function writes files to a specified directory based on a structured list.
#'
#' @param sl_app A structured list representing files and their contents.
#' @param dest A character string specifying the target directory.
#' @return None. Writes files to the specified directory.
#' @export
write_files <- function(sl_app, dest) {
  for (file in sl_app) {
    if ("type" %in% names(file) && file[["type"]] == "binary") {
      file_content <- base64enc::base64decode(file[["content"]])
      writeBin(file_content, file.path(dest, file[["name"]]))
    } else {
      file_content <- iconv(file[["content"]], "UTF-8", "UTF-8", sub = "")
      writeLines(file_content, file.path(dest, file[["name"]]), sep = "")
    }
  }
}

#' Convert a File to a List
#'
#' This function converts a file into a structured list for encoding.
#'
#' @param path A character string specifying the file path.
#' @param name An optional character string specifying the file name.
#' @param type An optional character string specifying the file type ("text" or "binary").
#' @return A structured list representing the file.
#' @export
as_file_list <- function(path, name = fs::path_file(path), type = NULL) {
  if (is.null(type)) {
    ext <- tolower(fs::path_ext(path))
    type <- if (ext %in% text_file_extensions()) "text" else "binary"
  } else {
    rlang::arg_match(type, c("text", "binary"))
  }
  
  content <-
    if (type == "text") {
      read_utf8(path)
    } else {
      rlang::check_installed("base64enc", "for binary file encoding.")
      base64enc::base64encode(read_raw(path))
    }
  
  ret <- list(name = name, content = content)
  if (type == "binary") ret$type <- "binary"
  
  ret
}

#' Get Text File Extensions
#'
#' This function returns a vector of common text file extensions.
#'
#' @return A character vector of text file extensions.
#' @export
text_file_extensions <- function() {
  c(
    "r", "rmd", "rnw", "rpres", "rhtml", "qmd",
    "py", "ipynb", "js", "ts", "jl", "sas",
    "html", "css", "scss", "less", "sass",
    "tex", "txt", "md", "markdown", "html", "htm",
    "json", "yml", "yaml", "xml", "svg", "yml",
    "sh", "bash", "zsh", "fish", "bat", "cmd",
    "sql", "csv", "tsv", "tab",
    "log", "dcf", "ini", "cfg", "conf", "properties", "env", "envrc",
    "gitignore", "gitattributes", "gitmodules", "gitconfig", "gitkeep",
    "htaccess", "htpasswd", "htgroups", "htdigest"
  )
}
