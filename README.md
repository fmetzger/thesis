# Dissertation Thesis #

This repository contains all the necessary files to compile my dissertation thesis. It is based on a custom style derived from the [classicthesis](https://code.google.com/p/classicthesis/) package and updated to better work with LuaLaTeX.


## R Scripts and Data ##

All the embedded plots are created through R scripts with ggplot2 which are all located in the scripts/ directory. The data paths are all hardcoded to my local paths but this should be an easy fix.

Unfortunately, most of the source data (especially the mobile core data) can not be made public and is therefore missing in the repository. Th other data is either in the data/ or in its respective repository.

## Build System ##

LuaLaTeX in its latest version (e.g. from the current TeX Live distribution) should be used to build the thesis. The regular PDFLaTeX path is broken but could probably be fixed up as no custom Lua code is used anywhere.
If you build with `latexmk` biber should be automatically invoked and the bibliography created. As glossaries+makeindex are used you additionally need to run `makeglossaries` after every change to the list of acronyms. 


## License ##

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/) with the exception of some third-party material and files which may state their own license.
