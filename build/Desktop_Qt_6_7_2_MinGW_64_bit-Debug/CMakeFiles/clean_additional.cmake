# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\ra2snes_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\ra2snes_autogen.dir\\ParseCache.txt"
  "ra2snes_autogen"
  )
endif()
