class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "adcfa67622dc07eee10f424de44ba007cbbbbc519528b060a54d58a6f82d3065"
  license "MIT"
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-modelling/releases/download/v0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a1467a8a0e7ae3d215f4c4725d9c0b85ad064942ef81bbf2c32791da4bb98702"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c8bfaa9379d372d8fdea9cca811f6b0d6236914aaeffa1b1405bc091886db941"
  end

  on_macos do
    depends_on :xcode => ["26.0", :build]
  end

  on_linux do
    # Check the original PATH before Homebrew scrubbed it
    original_path = ENV["HOMEBREW_PATH"] || ENV["PATH"]
    swift_found = original_path.split(File::PATH_SEPARATOR).any? do |dir|
      File.exist?(File.join(dir, "swift"))
    end
    depends_on "swift" => :build unless swift_found
  end

  def install
    # If swiftly is in the PATH, ensure its environment variables are set
    # because Homebrew might have scrubbed them even if it kept the PATH.
    original_path = ENV["HOMEBREW_PATH"] || ENV["PATH"]
    swift_dir = original_path.split(File::PATH_SEPARATOR).find do |dir|
      File.exist?(File.join(dir, "swift"))
    end

    if swift_dir && swift_dir.include?("swiftly")
      ENV["SWIFTLY_BIN_DIR"] = swift_dir
      ENV["SWIFTLY_HOME_DIR"] = File.dirname(swift_dir)
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
