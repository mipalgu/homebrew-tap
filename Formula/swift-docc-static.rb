class SwiftDoccStatic < Formula
  desc "Generate static HTML/CSS documentation for Swift packages"
  homepage "https://github.com/mipalgu/swift-docc-static"
  url "https://github.com/mipalgu/swift-docc-static/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "03928b89eb771db88f76215a883ca0aa1da7d4d98e2cc81606c3c6d52e55a7d9"
  license "Apache-2.0"
  env :std
  head "https://github.com/mipalgu/swift-docc-static.git", branch: "main"

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
