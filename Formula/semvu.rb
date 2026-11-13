class Semvu < Formula
  desc "Modify semantic versions and find the latest one in git tags"
  homepage "https://github.com/tedslittlerobot/semvu"
  url "https://github.com/tedslittlerobot/semvu/archive/refs/tags/v1.2.3.tar.gz"
  sha256 "65e3da8e5a1c1722ad0f192b69ff2ac0e6fc24dc007baf862531633e00e2f400"
  license "MIT"

  # The latest GitHub release, so release candidates (marked as pre-releases)
  # are never picked up.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/tedslittlerobot/homebrew-tap/releases/download/semvu-1.2.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "6f730145dafe11a19fc213f38c5137a56e6fec9a209cabbaea243d74e255e4b9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e52a2816161da0b5dca19d7a49fd01aa54483ca0a294cf0090f21304b6981501"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = "-X github.com/tedslittlerobot/semvu/internal/buildinfo.version=#{version}"
    system "go", "build", *std_go_args(ldflags:), "./cmd/semvu"

    generate_completions_from_executable(bin/"semvu", "completion")
  end

  test do
    assert_equal "#{version}\n", shell_output("#{bin}/semvu --version")
    assert_equal "1.3.0\n", shell_output("#{bin}/semvu modify 1.2.3 --minor")

    git = %w[git -c user.name=Test -c user.email=test@example.com]
    system(*git, "init", "--quiet", "--initial-branch=main")
    system(*git, "commit", "--quiet", "--allow-empty", "--message=feat: first")
    system(*git, "tag", "v1.2.3")
    system(*git, "commit", "--quiet", "--allow-empty", "--message=feat: add a thing")
    assert_equal "v1.2.3\n", shell_output("#{bin}/semvu latest")
    assert_equal "v1.3.0\n", shell_output("#{bin}/semvu modify --auto")
  end
end
