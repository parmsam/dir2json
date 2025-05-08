encode_dir_to_json <- function(dir) {
  stopifnot(fs::dir_exists(dir))
  
  files <- fs::dir_ls(dir, recurse = TRUE, type = "file")
  files <- fs::path_abs(files)
  files <- files[!grepl("^(\\.|_)", fs::path_file(files))]
  
  names <- fs::path_rel(files, dir)
  bundle <- unname(Map(as_file_list, files, names))
  bundle <- jsonlite::toJSON(bundle, auto_unbox = TRUE, null = "null", na = "null")
  
  return(bundle)
}

decode_json_to_dir <- function(json_data, dir) {
  sl_app <- jsonlite::fromJSON(json_data, simplifyVector = FALSE, simplifyDataFrame = FALSE, simplifyMatrix = FALSE)
  
  if (!fs::dir_exists(dir)) {
    fs::dir_create(dir)
  }
  
  write_files(sl_app, dir)
}

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

as_file_list <- function(path, name = fs::path_file(path), type = NULL) {
  if (is.null(type)) {
    ext <- tolower(fs::path_ext(path))
    type <- if (ext %in% text_file_extensions()) "text" else "binary"
  } else {
    rlang::arg_match(type, c("text", "binary"))
  }
  
  content <-
    if (type == "text") {
      xfun::read_utf8(path)
    } else {
      rlang::check_installed("base64enc", "for binary file encoding.")
      base64enc::base64encode(read_raw(path))
    }
  
  ret <- list(name = name, content = content)
  if (type == "binary") ret$type <- "binary"
  
  ret
}

text_file_extensions <- function() {
  c(
    "r", "rmd", "rnw", "rpres", "rhtml", "qmd",
    "py", "ipynb", "js", "ts", "jl", "sas", "log",
    "html", "css", "scss", "less", "sass",
    "tex", "txt", "md", "markdown", "html", "htm",
    "json", "yml", "yaml", "xml", "svg",
    "sh", "bash", "zsh", "fish", "bat", "cmd",
    "sql", "csv", "tsv", "tab",
    "log", "dcf", "ini", "cfg", "conf", "properties", "env", "envrc",
    "gitignore", "gitattributes", "gitmodules", "gitconfig", "gitkeep",
    "htaccess", "htpasswd", "htgroups", "htdigest"
  )
}

# Example usage:
# Encode directory to JSON
json_data <- encode_dir_to_json("example")

# Decode JSON back to directory
decode_json_to_dir(json_data, "example2")
