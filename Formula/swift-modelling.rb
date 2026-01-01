class SwiftModelling < Formula
  desc "A CLI wrapper for the Swift Modelling Framework (EMF, ATL, MTL)"
  homepage "https://github.com/mipalgu/swift-modelling"
  url "https://github.com/mipalgu/swift-modelling/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b1439fa9c9f824c11eda8bdde29f4445374321f3f7601553055694d113df6661"
  license "MIT"
  env :std
  head "https://github.com/mipalgu/swift-modelling.git", branch: "main"

  if OS.mac?
    depends_on :xcode => ["26.0", :build]
  else
    depends_on "swift" => :build if which("swift").nil?
  end

  def install
    # Support swiftly by detecting its home directory from the swift path
    swift_path = which("swift")
    if swift_path && swift_path.to_s.include?("/swiftly/bin/swift")
      swift_bin = swift_path.to_s
      swiftly_home = File.dirname(File.dirname(swift_bin))
      ENV["SWIFTLY_HOME_DIR"] = swiftly_home
      ENV["SWIFTLY_BIN_DIR"] = File.dirname(swift_bin)
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
