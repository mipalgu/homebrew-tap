class SwiftDoccStatic < Formula
  desc "Generate static HTML/CSS documentation for Swift packages"
  homepage "https://github.com/mipalgu/swift-docc-static"
  url "https://github.com/mipalgu/swift-docc-static/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "05e996cd283d464cfe6e18662b0aeeb689c2e8f20a841f5ed2aa1675e5e575e5"
  license "Apache-2.0"
  env :std
  head "https://github.com/mipalgu/swift-docc-static.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-docc-static/releases/download/v0.1.7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "bc0382402e50957b387fd96f381c9b71988eb5f83cb763e12e2ace344e0a8ffa"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "506da7b2534d98886305e136ba75011f2369b04105730b6b9e01481f4dd99785"
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
    bin.install ".build/release/docc-static"
  end

  test do
    system "#{bin}/docc-static", "--help"
  end
end
