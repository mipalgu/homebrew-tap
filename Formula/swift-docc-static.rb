class SwiftDoccStatic < Formula
  desc "Generate static HTML/CSS documentation for Swift packages"
  homepage "https://github.com/mipalgu/swift-docc-static"
  url "https://github.com/mipalgu/swift-docc-static/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "4e633a2d0fd6badbcb3f06caf0b5f3ebbf27a6e2021def8441c0acaaad9b42bd"
  license "Apache-2.0"
  env :std
  head "https://github.com/mipalgu/swift-docc-static.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-docc-static/releases/download/v0.1.4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "a225071a173eae79148813c8acbb0937757c193522efaaee0b552b25e1e85ad3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f5af4129954e32b414f14c6a53765f7a4997568a89f040d42d82b3f8a57175c3"
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
