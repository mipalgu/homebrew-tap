class SwiftDoccStatic < Formula
  desc "Generate static HTML/CSS documentation for Swift packages"
  homepage "https://github.com/mipalgu/swift-docc-static"
  url "https://github.com/mipalgu/swift-docc-static/archive/refs/tags/v0.1.5.tar.gz"
  sha256 "1e6985093de51a096a08582dd5323b1b99d36f63b1e37569269560f3892b31af"
  license "Apache-2.0"
  env :std
  head "https://github.com/mipalgu/swift-docc-static.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-docc-static/releases/download/v0.1.5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "87ffd439e6ab9a1ab1b2cdcfcbf051144709675fb1a3200b3ee13913a12354e9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "07acd49cecca46348310183567f9a506fb5e9d2df9bf36fcc1812ce217651bc7"
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
