# SPDX-License-Identifier: Apache-2.0

add_unittest(TestDisposableElementsAttr
  TestDisposableElementsAttr.cpp

  LINK_LIBS PRIVATE
  OMONNXOps
  ONNX::onnx_proto
  ONNX::onnx)

