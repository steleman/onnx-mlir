#!/bin/bash

llvm_version="21.1.8"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/onnx-mlir"
builddir="${here}"
llvmdir="/opt/llvm/${llvm_version}"
llvm_bindir="${llvmdir}/bin"
llvm_libdir="${llvmdir}/lib64"
outfile="${here}/onnx-mlir-build.out"
ret=0
distro="`uname -s`"

if [ "${distro}" != "Linux" ] ; then
  echo "This cmake configure script only works on Linux."
  exit 1
fi

export GMAKE="/usr/bin/gmake"
export MAKE="${GMAKE}"
export GMAKE="${GMAKE}"
export CMAKE="/usr/bin/cmake"
export PATH="${llvm_bindir}:${PATH}"
build_type="Release"

pytorch_version="2.7.1"
export PYTORCH="/opt/pytorch/${pytorch_version}"
llvm_dir="${llvm_libdir}/cmake/llvm"
mlir_dir="${llvm_libdir}/cmake/mlir"
mlir_tblgen="${llvm_bindir}/mlir-tblgen"
mlir_dll_tblgen="${llvm_libdir}/libMLIRTableGen.a"
pytorch_incdir="${PYTORCH}/include"
pytorch_libdir="${PYTORCH}/lib64"
njobs="2"

export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
export CFLAGS="-Wall -Wextra"
export CXXFLAGS="-Wall -Wextra"
export CPPFLAGS=""
export CMAKE_FLAGS=""
export USE_PROTOBUF_SHARED_LIBS=1

${CC} --version
${CXX} --version

cat /dev/null > ${outfile}

echo "gmake -j${njobs} >> ${outfile} 2>&1"
gmake -j${njobs} >> ${outfile} 2>&1
ret=$?

if [ ${ret} -eq 0 ] ; then
  echo "ONNX-MLIR Build OK."
else
  echo "ONNX-MLIR Build FAILED."
  exit 1
fi

