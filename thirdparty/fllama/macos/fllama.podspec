#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint fllama.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'fllama'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.dependency 'FlutterMacOS'
  s.swift_version = '5.0'

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 
                   'llama.cpp/src/llama.cpp',
                   'llama.cpp/src/llama-sampling.cpp',
                   'llama.cpp/src/llama-grammar.cpp',
                   'llama.cpp/ggml/src/ggml.c',
                   'llama.cpp/ggml/src/ggml-alloc.c',
                   'llama.cpp/ggml/src/ggml-backend.c',
                   'llama.cpp/ggml/src/ggml-metal.m',
                   'llama.cpp/ggml/src/ggml-quants.c',
                   'llama.cpp/ggml/src/ggml-aarch64.c',
                   'llama.cpp/src/llama-vocab.cpp',
                   'llama.cpp/src/unicode.cpp',
                   'llama.cpp/src/unicode-data.cpp',
                   'llama.cpp/common/common.cpp',
                   'llama.cpp/common/build-info.cpp',
                   'llama.cpp/common/grammar-parser.cpp',
                   'llama.cpp/common/json-schema-to-grammar.cpp',
                   'llama.cpp/common/sampling.cpp',
                   'llama.cpp/common/stb_image.h',
  s.frameworks = 'Foundation', 'Metal', 'MetalKit'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'USER_HEADER_SEARCH_PATHS' => [
      '$(PODS_TARGET_SRCROOT)/../llama.cpp/ggml/include',
      '$(PODS_TARGET_SRCROOT)/../llama.cpp/include',
      '$(PODS_TARGET_SRCROOT)/../llama.cpp/src',
      '$(PODS_TARGET_SRCROOT)/../llama.cpp/**/*.h', 
      '$(PODS_TARGET_SRCROOT)/../llama.cpp/common/**/*.h',],
      'HEADER_SEARCH_PATHS' => [
        '$(PODS_TARGET_SRCROOT)/../llama.cpp/ggml/include',
        '$(PODS_TARGET_SRCROOT)/../llama.cpp/include',
        '$(PODS_TARGET_SRCROOT)/../llama.cpp/src',
        '$(PODS_TARGET_SRCROOT)/../llama.cpp/**/*.h', 
        '$(PODS_TARGET_SRCROOT)/../llama.cpp/common/**/*.h',],
    # -w is to suppress warnings from llama.cpp, there's tons of them
    'OTHER_CFLAGS' => ['$(inherited)', '-O3', '-flto', '-fno-objc-arc', '-w', '-I$(PODS_TARGET_SRCROOT)/../llama.cpp/include', '-I$(PODS_TARGET_SRCROOT)/../llama.cpp/ggml/include', '-DGGML_LLAMAFILE=OFF'],
    'OTHER_CPLUSPLUSFLAGS' => ['$(inherited)', '-O3', '-flto', '-fno-objc-arc', '-w', '-I$(PODS_TARGET_SRCROOT)/../llama.cpp/include', '-I$(PODS_TARGET_SRCROOT)/../llama.cpp/ggml/include', '-DGGML_LLAMAFILE=OFF'],
    'GCC_PREPROCESSOR_DEFINITIONS' => ['$(inherited)', 'GGML_USE_METAL=1'],
  }
  s.script_phases = [
    {
      :name => 'Build Metal Library',
      :input_files => ["${PODS_TARGET_SRCROOT}/llama.cpp/ggml-metal.metal"],
      :output_files => ["${METAL_LIBRARY_OUTPUT_DIR}/default.metallib"],
      :execution_position => :after_compile,
      :script => <<-SCRIPT
set -e
set -u
set -o pipefail
cd "${PODS_TARGET_SRCROOT}/llama.cpp"
xcrun metal -target "air64-${LLVM_TARGET_TRIPLE_VENDOR}-${LLVM_TARGET_TRIPLE_OS_VERSION}${LLVM_TARGET_TRIPLE_SUFFIX:-\"\"}" -ffast-math -std=ios-metal2.3 -o "${METAL_LIBRARY_OUTPUT_DIR}/default.metallib" ggml/src/*.metal
SCRIPT
    }
  ]
end