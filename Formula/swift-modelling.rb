class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b1439fa9c9f824c11eda8bdde29f4445374321f3f7601553055694d113df6661"
  license "MIT"
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  on_macos do
    depends_on :xcode => ["26.0", :build]
  end

  on_linux do
    # Check if swift exists in the PATH (handles both files and symlinks)
    swift_found = ENV["PATH"].split(File::PATH_SEPARATOR).any? do |dir|
      File.exist?(File.join(dir, "swift"))
    end
    depends_on "swift" => :build unless swift_found
  end

  def install
    # If using swiftly, infer and set its home directory from the binary location
    if (swift_path = which("swift")) && swift_path.to_s.include?("swiftly")
      bin_dir = File.dirname(swift_path)
      ENV["SWIFTLY_BIN_DIR"] = bin_dir
      ENV["SWIFTLY_HOME_DIR"] = File.dirname(bin_dir)
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
