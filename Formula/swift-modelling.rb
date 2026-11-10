class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "bbf26e0eae371f4fe4d32b04e4e892b04fc2d9586cd16e6f3b61692d3dc6116d"
  license any_of: ["BSD-4-Clause", "GPL-2.0-or-later"]
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  bottle do
    root_url "https://github.com/mipalgu/swift-modelling/releases/download/v0.8.0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "ef7260e1eb3f83c1c97f1fa16bd168fc5a13f04e31760f858e1841f27465b7fa"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "0e656cdcb6a7a8a9b3e22c09882b40527f403f3d33469516e55bb8f4e85dc58e"
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
    tools = File.read("Scripts/tools.txt").split
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
    system "#{bin}/swift-henshin", "--help"
    system "#{bin}/swift-epsilon", "--help"
    system "#{bin}/swift-xtend", "--help"
    assert_equal "3\n", shell_output("#{bin}/swift-aql evaluate --expression 1+2")
    assert_match "java", shell_output("#{bin}/swift-atl generate --help")
  end
end
