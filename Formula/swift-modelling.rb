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
    # Check if swift is already available by asking the login shell.
    # This respects custom installations like swiftly or swiftenv.
    swift_found = which("swift") || system("#{ENV["SHELL"] || "bash"} -l -c '''which swift''' > /dev/null 2>&1")
    depends_on "swift" => :build unless swift_found
  end

  def install
    # Locate the swift executable, preferring the one from the login shell if brew PATH is scrubbed
    swift_path = which("swift") || begin
      shell_path = `#{ENV["SHELL"] || "bash"} -l -c '''which swift''' 2>/dev/null`.strip
      Pathname.new(shell_path) if !shell_path.empty? && File.executable?(shell_path)
    rescue
      nil
    end

    # If using swiftly, ensure environment variables are set correctly for the build
    if swift_path && swift_path.to_s.include?("swiftly")
      swift_bin_dir = File.dirname(swift_path.to_s)
      ENV["SWIFTLY_BIN_DIR"] ||= swift_bin_dir
      ENV["SWIFTLY_HOME_DIR"] ||= File.dirname(swift_bin_dir)
      ENV.prepend_path "PATH", swift_bin_dir
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
