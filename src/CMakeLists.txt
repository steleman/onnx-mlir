# SPDX-License-Identifier: Apache-2.0

include(GNUInstallDirs)
include(AddLLVM)
include(LLVMConfig)
include(AddMLIR)
include(MLIRConfig)

if (ONNX_MLIR_ENABLE_PYRUNTIME_LIGHT)
  add_subdirectory(Runtime)
  # Accelerators introduces a target AcceleratorsInc. Define a dummy one here
  add_custom_target(AcceleratorsInc
      COMMAND echo "This is the dummy definition for AcceleratorsInc")
  add_compile_definitions(ENABLE_PYRUNTIME_LIGHT)
  return()
endif()

if (APPLE)
  find_package(OpenMP COMPONENTS C CXX)
elseif (LINUX)
  find_package(OpenMP)
endif()

message(STATUS "OpenMP_FOUND: ${OpenMP_FOUND}")
message(STATUS "OpenMP_C_FOUND: ${OpenMP_C_FOUND}")
message(STATUS "OpenMP_CXX_FOUND: ${OpenMP_CXX_FOUND}")

if (OpenMP_FOUND)
  message(STATUS "OpenMP_C_INCLUDE_DIRS: ${OpenMP_C_INCLUDE_DIRS}")
  message(STATUS "OpenMP_C_LIBRARY: ${OpenMP_C_LIBRARY}")

  if (APPLE)
    set(OPENMP_INCLUDE_DIR ${OpenMP_C_INCLUDE_DIRS})
    find_path(OPENMP_LIBRARY_DIR
              NAMES libomp.dylib
              HINTS ${OpenMP_C_LIBRARY}
              PATHS ${OpenMP_C_LIBRARY})
    message(STATUS "OPENMP_INCLUDE_DIR: ${OPENMP_INCLUDE_DIR}")
    message(STATUS "OPENMP_LIBRARY_DIR: ${OPENMP_LIBRARY_DIR}")
    set(OMP_SUPPORTED ON)
  elseif (LINUX)
    set(OMP_SUPPORTED ON)
  endif()
else()
  # Find OpenMP headers built by LLVM
  find_path(OPENMP_INCLUDE_DIR
            NAMES omp.h
            HINTS
            ${OpenMP_DIR}
            ${OpenMP_DIR}/include
            /usr/local/include
            ${LLVM_INCLUDE_DIRS}
            ${LLVM_BUILD_BINARY_DIR}/lib/clang/*/include
            PATHS
            ${OpenMP_DIR}
            ${OpenMP_DIR}/include
            /usr/local/include
            ${LLVM_INCLUDE_DIRS}
            ${LLVM_BUILD_BINARY_DIR}/lib/clang/*/include)

  if(OPENMP_INCLUDE_DIR)
    set(OMP_SUPPORTED ON)
  else()
    set(OMP_SUPPORTED OFF)
  endif()

  if (APPLE)
    find_path(OPENMP_LIBRARY_DIR
              NAMES libomp.dylib
              HINTS /usr/local/lib
              ${LLVM_LIBRARY_DIRS}
              ${LLVM_BUILD_BINARY_DIR}/lib
              PATHS
              /usr/local/lib
              ${LLVM_LIBRARY_DIRS}
              ${LLVM_BUILD_BINARY_DIR}/lib)
  elseif (LINUX)
    find_path(OPENMP_LIBRARY_DIR
              NAMES libgomp.so
              HINTS
              ${OpenMP_DIR}
              ${OpenMP_DIR}/lib64
              PATHS
              ${OpenMP_DIR}
              ${OpenMP_DIR}/lib64
              ${LLVM_BUILD_BINARY_DIR}/lib64)
  endif()

  if (OPENMP_LIBRARY_DIR)
    set(OPENMP_SUPPORTED ON)
  else()
    set(OMP_SUPPORTED OFF)
  endif()
endif()

message(STATUS "OpenMP Support: ${OMP_SUPPORTED}")

if (OMP_SUPPORTED)
  add_compile_options(-fopenmp)
endif()

if (APPLE)
  message(STATUS "OPENMP_INCLUDE_DIR: ${OPENMP_INCLUDE_DIR}")
  message(STATUS "OPENMP_LIBRARY_DIR: ${OPENMP_LIBRARY_DIR}")
endif()

add_compile_options(-I${CMAKE_SOURCE_DIR}/include)
add_compile_options(-I${CMAKE_SOURCE_DIR})
add_compile_options(-I${CMAKE_BINARY_DIR}/include)
add_compile_options(-I${CMAKE_BINARY_DIR})

add_subdirectory(Accelerators)
add_subdirectory(Interface)
add_subdirectory(Dialect)
add_subdirectory(Support)
add_subdirectory(Conversion)
add_subdirectory(Transform)
add_subdirectory(Builder)
add_subdirectory(Runtime)
add_subdirectory(Tools)
add_subdirectory(Version)
add_subdirectory(Compiler)

add_onnx_mlir_executable(onnx-mlir
  onnx-mlir.cpp

  LINK_LIBS PRIVATE
  OMCompilerOptions
  OMCompilerUtils
  OMOptionUtils
  ONNX::onnx_proto
  ONNX::onnx)

