class Ptyunit < Formula
  desc "Test framework for bash scripts and terminal UI applications"
  homepage "https://github.com/fissible/ptyunit"
  url "https://github.com/fissible/ptyunit/archive/refs/tags/v1.5.0.tar.gz"
  sha256 "6941612b419e1f394f769522906c4c2b318794601d702301be8776d1ab9a1268"
  license "MIT"

  depends_on "bash"
  depends_on "python@3" => :recommended

  def install
    # Install core files to libexec (not in PATH directly)
    libexec.install "assert.sh", "mock.sh", "run.sh", "help.sh", "pty_run.py", "pty_session.py"
    libexec.install "coverage.sh", "coverage_report.py", "VERSION"

    # Create a wrapper script in bin
    (bin/"ptyunit").write <<~EOS
      #!/bin/bash
      exec bash "#{libexec}/run.sh" "$@"
    EOS
  end

  test do
    # Write a minimal test file
    (testpath/"test-smoke.sh").write <<~EOS
      source "#{libexec}/assert.sh"
      test_that "math works"
      assert_eq "4" "$(( 2 + 2 ))"
      ptyunit_test_summary
    EOS
    output = shell_output("bash test-smoke.sh")
    assert_match "1/1 tests passed", output
  end
end
