class Semvu < Formula
  desc "Modify semantic versions and find the latest one in git tags"
  homepage "https://github.com/tedslittlerobot/semvu"
  url "https://github.com/tedslittlerobot/semvu/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  # The latest GitHub release, so release candidates (marked as pre-releases)
  # are never picked up.
  livecheck do
    url :stable
    strategy :github_latest
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
