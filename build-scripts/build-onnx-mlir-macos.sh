#!/bin/bash

llvm_version="21.1.8"
llvm_root="/opt/llvm/${llvm_version}"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/onnx-mlir"
builddir="${here}"
llvmdir="/opt/llvm/${llvm_version}"
outfile="${here}/onnx-mlir-build.out"
cret=0
distro="`uname -s`"

if [ "${distro}" != "Darwin" ] ; then
  echo "This cmake configure script only works on Apple MacOS (Darwin)."
  exit 1
fi

if [ -e /opt/homebrew/bin/brew ] ; then
  /opt/homebrew/bin/brew shellenv >& /tmp/brewshellenv.$$
  source /tmp/brewshellenv.$$
  rm -f /tmp/brewshellenv.$$
fi

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:${here}/bin"
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}"
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:${PATH}"
export PATH="/opt/homebrew/opt/findutils/libexec/gnubin:${PATH}"
export PATH="/opt/homebrew/opt/diffutils/libexec/gnubin:${PATH}"
export GMAKE="/opt/homebrew/bin/gmake"
export MAKE="${GMAKE}"
export GMAKE="${GMAKE}"
export CMAKE="/opt/homebrew/opt/cmake/bin/cmake"
build_type="Release"

pytorch_version="2.7.1"
export PYTORCH="/opt/pytorch/${pytorch_version}"
llvm_dir="${llvmdir}/lib/cmake/llvm"
mlir_dir="${llvmdir}/lib/cmake/mlir"
mlir_tblgen="${llvmdir}/bin/mlir-tblgen"
mlir_dll_tblgen="${llvmdir}/lib/libMLIRTableGen.a"
pytorch_incdir="${PYTORCH}/include"
pytorch_libdir="${PYTORCH}/lib"
njobs="2"

export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"
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

