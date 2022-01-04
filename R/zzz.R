.onLoad <- function(libname, pkgname) {
  pydub <- reticulate::py_module_available(module = "pydub")
  #if (isFALSE(pydub)) reticulate::py_install(packages = "pydub")
  audioop <- reticulate::py_module_available(module = "audioop")
  #if (isFALSE(audioop)) reticulate::py_install(packages = "audioop")
}

