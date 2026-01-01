class SwiftCompilerRequirement < Requirement
  fatal true
  default_formula "swift"

  satisfy(build_values: false) { !which("swift").nil? }

  def message
    "Swift compiler not found in PATH. Please install Swift or ensure it is available in your PATH."
  end
end

class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b1439fa9c9f824c11eda8bdde29f4445374321f3f7601553055694d113df6661"
  license "MIT"
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  if OS.mac?
    depends_on :xcode => ["26.0", :build]
  else
    depends_on SwiftCompilerRequirement => :build
  end

  def install
    # If using swiftly, ensure environment variables are set.
    # We infer them from the location of the swift binary.
    swift_path = which("swift")
    if swift_path && swift_path.to_s.include?("swiftly")
      swift_bin_dir = File.dirname(swift_path.to_s)
      ENV["SWIFTLY_BIN_DIR"] ||= swift_bin_dir
      ENV["SWIFTLY_HOME_DIR"] ||= File.dirname(swift_bin_dir)
    end

    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/swift-ecore"
    bin.install ".build/release/swift-atl"
    bin.install ".build/release/swift-mtl"
  end

  test do
    system "#{bin}/swift-ecore", "--help"
    system "#{bin}/swift-atl", "--help"
    system "#{bin}/swift-mtl", "--help"
  end
end
