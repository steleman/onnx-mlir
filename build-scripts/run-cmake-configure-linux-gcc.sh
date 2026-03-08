#!/bin/bash

here="`pwd`"
tophere="`dirname ${here}`"
basehere="`basename ${here}`"
llvm_version="21.1.8"
llvmdir="/opt/llvm"
llvm_prefix="${llvmdir}/${llvm_version}"
llvm_bindir="${llvm_prefix}/bin"
llvm_libdir="${llvm_prefix}/lib64"
llvm_incdir="${llvm_prefix}/include"
llvm_cmake_module_path="${llvm_libdir}/cmake/llvm/"
mlir_cmake_module_path="${llvm_libdir}/cmake/mlir/"
prefix=${llvm_prefix}
pytorch_version="2.7.1"
pytorch="/opt/pytorch/${pytorch_version}"
pytorch_libdir="${pytorch}/lib64"
pytorch_bindir="${pytorch}/bin"
rc=0

onnxmlir="${tophere}/onnx-mlir"
llvmbuilddir="${tophere}/llvm-onnx-mlir-build"
outfile="${here}/configure-onnx-mlir.out"
osname="`uname -s`"

exe_linker_flags="-fPIE"
exe_linker_flags="${exe_linker_flags} -Wl,-rpath -Wl,${prefix}/lib64"
exe_linker_flags="${exe_linker_flags} -Wl,-rpath -Wl,${llvm_libdir}"
exe_linker_flags="${exe_linker_flags} -Wl,-rpath -Wl,${pytorch_libdir}"

shared_linker_flags="-fPIC"
shared_linker_flags="${shared_linker_flags} -Wl,-rpath -Wl,${prefix}/lib64"
shared_linker_flags="${shared_linker_flags} -Wl,-rpath -Wl,${pytorch_libdir}"
shared_linker_flags="${shared_linker_flags} -Wl,-rpath -Wl,${llvm_libdir}"
cmake_build_rpath="${here}/lib;${here}/lib64;${llvm_libdir};${pytorch_libdir};"
cmake_install_rpath="${llvm_libdir};${pytorch_libdir};"

if [ "${osname}" != "Linux" ] ; then
  echo "This cmake configure script will only work on Linux."
  exit 1
fi

if [ "${basehere}" != "build-onnx-mlir" ] ; then
  echo "You are in the wrong build directory."
  exit 1
fi

export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"

cflags="-Wall -Wextra"
export CFLAGS="${cflags}"

cxxflags="-Wall -Wextra"
export CXXFLAGS="${cxxflags}"

export PATH="${llvm_bindir}:${pytorch_bindir}:${PATH}"
export LLVM_DIR="${llvm_libdir}/cmake/llvm"
export MLIR_DIR="${llvm_libdir}/cmake/mlir"
export PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:${PKG_CONFIG_PATH}"
export GMAKE="/usr/bin/gmake"
export CMAKE="/usr/bin/cmake"

gsed="/usr/bin/sed"
build_type="Release"

cmake_flags="-DCMAKE_INSTALL_PREFIX=${prefix}"
cmake_flags="${cmake_flags} -DCMAKE_MAKE_PROGRAM:FILEPATH=${GMAKE}"
cmake_flags="${cmake_flags} -DCMAKE_SUPPRESS_REGENERATION:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_C_COMPILER:FILEPATH=${CC}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_COMPILER:FILEPATH=${CXX}"
cmake_flags="${cmake_flags} -DCMAKE_ASM_COMPILER:FILEPATH=${CC}"
cmake_flags="${cmake_flags} -DCMAKE_C_FLAGS=${CFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_FLAGS=${CXXFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_C_FLAGS_RELEASE=${CFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_FLAGS_RELEASE=${CXXFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_C_FLAGS_DEBUG=${CFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_CXX_FLAGS_DEBUG=${CXXFLAGS}"
cmake_flags="${cmake_flags} -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON"
cmake_flags="${cmake_flags} -DCMAKE_LINKER_TYPE:STRING=BFD"
cmake_flags="${cmake_flags} -DCMAKE_EXE_LINKER_FLAGS:STRING=${exe_linker_flags}"
cmake_flags="${cmake_flags} -DCMAKE_MODULE_LINKER_FLAGS:STRING=${shared_linker_flags}"
cmake_flags="${cmake_flags} -DCMAKE_SHARED_LINKER_FLAGS:STRING=${shared_linker_flags}"
cmake_flags="${cmake_flags} -DCMAKE_BUILD_RPATH:STRING=${cmake_build_rpath}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_RPATH:STRING=${cmake_install_rpath}"
cmake_flags="${cmake_flags} -DONNX_MLIR_CCACHE_BUILD:BOOL=OFF"
cmake_flags="${cmake_flags} -DONNX_MLIR_USE_SYSTEM_LLVM:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_MLIR_USE_SYSTEM_MLIR:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_MLIR_USE_SYSTEM_ONNX:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_MLIR_USE_SYSTEM_OPENMP:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_MLIR_USE_SYSTEM_PYBIND11:BOOL=ON"

cmake_flags="${cmake_flags} -DLLVM_CMAKE_MODULE_PATH:FILEPATH=${llvm_cmake_module_path}"
cmake_flags="${cmake_flags} -DMLIR_CMAKE_MODULE_PATH:FILEPATH=${mlir_cmake_module_path}"

cmake_flags="${cmake_flags} -DCMAKE_BUILD_TYPE=${build_type}"
cmake_flags="${cmake_flags} -DONNX_MLIR_ENABLE_JAVA:BOOL=OFF"
cmake_flags="${cmake_flags} -DONNX_MLIR_ENABLE_WERROR:BOOL=OFF"
cmake_flags="${cmake_flags} -DONNX_MLIR_SUPPRESS_THIRD_PARTY_WARNINGS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_ML:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_WERROR:BOOL=OFF"
cmake_flags="${cmake_flags} -DONNX_USE_PROTOBUF_SHARED_LIBS:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_ENABLE_LLD:BOOL=OFF"
cmake_flags="${cmake_flags} -DBUILD_ONNX_PYTHON:BOOL=ON"
cmake_flags="${cmake_flags} -DONNX_DISABLE_EXCEPTIONS:BOOL=OFF"
cmake_flags="${cmake_flags} -DONNX_BUILD_SHARED_LIBS:BOOL=OFF"
cmake_flags="${cmake_flags} -DSTABLEHLO_BUILD_EMBEDDED:BOOL=ON"
cmake_flags="${cmake_flags} -DSTABLEHLO_ENABLE_BINDINGS_PYTHON:BOOL=ON"
cmake_flags="${cmake_flags} -DSTABLEHLO_ENABLE_LLD:BOOL=ON"
cmake_flags="${cmake_flags} -DSTABLEHLO_ENABLE_SPLIT_DWARF:BOOL=OFF"
cmake_flags="${cmake_flags} -DMLIR_DIR:FILEPATH=${MLIR_DIR}"
cmake_flags="${cmake_flags} -DLLVM_DIR:FILEPATH=${LLVM_DIR}"
cmake_flags="${cmake_flags} -DCMAKE_INSTALL_LOCAL_ONLY:BOOL=ON"

cat /dev/null > ${outfile}
echo "Running cmake ${cmake_flags} ${onnxmlir} >> ${outfile} 2>&1"
cmake ${cmake_flags} ${onnxmlir} >> ${outfile} 2>&1
rc=$?

if [ ${rc} -ne 0 ] ; then
  echo "CMake configuration FAILED."
  exit 1
else
  echo "CMake configuration succeeded."
fi

echo "Fixing compiler and linker flags garbage ..."

listfile="/tmp/flat-namespace.$$"
cat /dev/null > ${listfile}

find . -type f -name "*.txt" -print >> ${listfile} 2>&1
find . -type f -name "*.make" -print >> ${listfile} 2>&1

while read -r line
do
  baseline="`basename ${line}`"
  cp -fp ${line} "${line}.orig"
  ${gsed} -i 's#-DONNX_ML="1##g' ${line}
  ${gsed} -i 's#-D__STDC_LIMIT_MACROS" -DONNX_ML="1 -DONNX_NAMESPACE=onnx -DUSE_ML=1 -D_DARWIN_C_SOURCE##g' ${line}
  ${gsed} -i 's#-DONNX_NAMESPACE="onnx ##g' ${line}
  ${gsed} -i 's#-D__STDC_LIMIT_MACROS"#-D__STDC_LIMIT_MACROS#g' ${line}
  ${gsed} -i 's#-stdlib=libc++##g' ${line}
  ${gsed} -i 's#-I/usr/local/include/onnx#-I/usr/local/include#g' ${line}
  ${gsed} -i 's#-Werror=unguarded-availability-new ##g' ${line}
  ${gsed} -i 's#-fvisibility=hidden##g' ${line}
  ${gsed} -i 's#-fvisibility-inlines-hidden##g' ${line}
  ${gsed} -i 's#-I/lib/clang/19/include##g' ${line}
  touch -r "${line}.orig" -acm ${line}
  rm -f "${line}.orig"
done < ${listfile}

rm -f ${listfile}

echo "Done."

