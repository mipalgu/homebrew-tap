class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "f4d8987b8494a32cb7bb165c1ae1be5b148cbb18c761c123c16c28dee4c59f5b"
  license any_of: ["BSD-4-Clause", "GPL-2.0-or-later"]
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-modelling/releases/download/v0.5.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "41a87d91e9dfa15d15a738e57d08d42d246b83162d24d735cc19c7cf0b211493"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "62ec881425883c9a25bc09d69e5d18d8c9db1590dfbd85cf3f2a851bce37443a"
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

    # The tools load their bundled templates, transformations and metamodels
    # from resource bundles next to the executable, so both go into libexec.
    tools = %w[swift-ecore swift-atl swift-mtl]
    tools.each { |tool| libexec.install ".build/release/#{tool}" }
    bundles = Dir[".build/release/*.bundle", ".build/release/*.resources"].reject do |bundle|
      File.basename(bundle).match?(/(Tests|-tests)\.(bundle|resources)\z/)
    end
    odie "No resource bundles were built" if bundles.empty?
    libexec.install bundles
    tools.each { |tool| bin.write_exec_script libexec/tool }
  end

  test do
    system "#{bin}/swift-ecore", "--help"
    system "#{bin}/swift-atl", "--help"
    system "#{bin}/swift-mtl", "--help"
    assert_match "java", shell_output("#{bin}/swift-atl generate --help")
  end
end
