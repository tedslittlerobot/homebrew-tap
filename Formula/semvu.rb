class Semvu < Formula
  desc "Modify semantic versions and find the latest one in git tags"
  homepage "https://github.com/tedslittlerobot/semvu"
  url "https://github.com/tedslittlerobot/semvu/archive/refs/tags/v1.4.0.tar.gz"
  sha256 "06012c80731e68070808b63fe519776710ce8a7321d129927e6d3a867419192a"
  license "MIT"

  # The latest GitHub release, so release candidates (marked as pre-releases)
  # are never picked up.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/tedslittlerobot/homebrew-tap/releases/download/semvu-1.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "144d473f769cd8a5929e4166df3e933525ae3b9d16bb5de9e9330d49e7ef91e4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "900b7419cfed60bb9f5825157e994a46042602ca01de15cb0632c770b8b1d2f0"
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
