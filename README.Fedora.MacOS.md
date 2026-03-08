ONNX-MLIR on Fedora 41 (and later) and MacOS Sequoia
====================================================

This is my fork / port of ONNX-MLIR to Fedora 41+ and MacOS Sequoia
with LLVM 21.1.4 (MacOS) and 21.1.8 (Fedora). Why is this relevant:
because the canonical release of ONNX-MLIR from Github relies on
specific LLVM commit hashes that do not necessarily represent a
numbered LLVM release.

You can get LLVM 21.1.4 and 21.1.8 from my Github repo. I did have to
make some changes (additions) to LLVM that are specific for ONNX-MLIR
and Torch-MLIR.

I am trying to write a compiler that uses Torch-MLIR and ONNX-MLIR, and
I can't have dependencies on several different versions of LLVM based on
commit hashes. Some sanity must be restored. :-)

The build scripts are in the `build-scripts` directory at toplevel.

The patches to make this work are in the `patches` directory at toplevel.
You do not need to apply the patch. It's already included in the branch commit.

To build ONNX-MLIR do this:

1. Clone this repo.
2. Create a `build` directory parallel to the cloned repo.
3. Run the script `run-cmake-configure-${macos|linux-gcc}.sh` to configure it.
4. Run the script `build-onnx-mlir-${macos|linux}.sh`.
5. Run the script `install-onnx-mlir-${macos|linux}.sh`.

The install script will install ONNX-MLIR in a directory named `install-onnx-mlir` parallel to the cloned `onnx-mlir` repo.

I have also included rpm `spec` file for Fedora.

That's it. :-)

