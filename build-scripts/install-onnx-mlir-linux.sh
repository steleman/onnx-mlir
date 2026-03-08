#!/bin/bash

llvm_version="21.1.8"
llvmdir="/opt/llvm/${llvm_version}"
here="`pwd`"
topdir="`dirname ${here}`"
srcdir="${topdir}/onnx-mlir"
builddir="${here}"
destdir="${topdir}/install-onnx-mlir"
destbindir="${destdir}/${llvmdir}/bin"
destlibdir="${destdir}/${llvmdir}/lib"
llvm_libdir="${llvmdir}/bin"
llvm_libdir="${llvmdir}/lib64"
outfile="${here}/onnx-mlir-install.out"
cret=0
distro="`uname -s`"

if [ "${distro}" != "Linux" ] ; then
  echo "This cmake configure script only works on Linux."
  exit 1
fi

export PATH="${llvm_bindir}:${PATH}"
export GMAKE="/usr/bin/gmake"
export MAKE="${GMAKE}"
export GMAKE="${GMAKE}"
export CMAKE="/usr/bin/cmake"
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

export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
export CFLAGS="-Wall -Wextra"
export CXXFLAGS="-Wall -Wextra"
export CPPFLAGS=""
export CMAKE_FLAGS=""
export USE_PROTOBUF_SHARED_LIBS=1

if [ ! -d ${destdir} ] ; then
  mkdir -p ${destdir}
fi

cat /dev/null > ${outfile}

echo "gmake DESTDIR=${destdir} install >> ${outfile} 2>&1"
gmake DESTDIR=${destdir} install >> ${outfile} 2>&1

filelist="/tmp/onnxmlirlib.$$"

echo "cd ${destlibdir}"
cd ${destlibdir}

echo "cat /dev/null > ${filelist}"
cat /dev/null > ${filelist}

echo "ls -1 lib*.a > ${filelist}"
ls -1 lib*.a > ${filelist}

while read -r line
do
  if [ -e ${llvm_libdir}/${line} ] ; then
    echo "rm -f ${line}"
    rm -f ${line}
  fi
done < ${filelist}

echo "rm -f ${filelist}"
rm -f ${filelist}

echo "cd ${destbindir}"
cd ${destbindir}

if [ -e ./binary-decoder ] ; then
  echo "mv ./binary-decoder ./onnx-mlir-binary-decoder"
  mv ./binary-decoder ./onnx-mlir-binary-decoder
  echo "ln -sf onnx-mlir-binary-decoder binary-decoder"
  ln -sf onnx-mlir-binary-decoder binary-decoder
else
  echo "file ./binary-decoder was not found where expected."
  exit 1
fi

echo "cd ${here}"
cd ${here}

