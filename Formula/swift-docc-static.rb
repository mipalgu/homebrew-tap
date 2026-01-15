class SwiftDoccStatic < Formula
  desc "Generate static HTML/CSS documentation for Swift packages"
  homepage "https://github.com/mipalgu/swift-docc-static"
  url "https://github.com/mipalgu/swift-docc-static/archive/refs/tags/v0.1.8.tar.gz"
  sha256 "673a564bc1170df48b4f8462a258b999e344e8f22da28bfd74c63903d7b996e8"
  license "Apache-2.0"
  env :std
  head "https://github.com/mipalgu/swift-docc-static.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-docc-static/releases/download/v0.1.8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "03fb6fd214a612d5bb7eacf27f86e4535ed7fe8ea94399d7f3af3c6113d5ce75"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "988177d7ab6883eb2749fdbb6f48b86176cae10bd4f5e5bf9a0a541a43acadd6"
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
