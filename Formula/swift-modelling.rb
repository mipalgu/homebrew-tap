class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.6.4.tar.gz"
  sha256 "a884804772525fe12a9371c70c92156c31fd27e49bf536f6f3b827da9b80be3c"
  license any_of: ["BSD-4-Clause", "GPL-2.0-or-later"]
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-modelling/releases/download/v0.6.4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "79f581e73c6f83e7d71a13122085a9c4f73b096aec9c84fbf61dafab42ac4fa3"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2e552652d84fa08766f8cd2468b2d74a83e561d15e2292557cde54a676f30afe"
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
