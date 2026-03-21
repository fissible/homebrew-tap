class Ptyunit < Formula
  desc "Test framework for bash scripts and terminal UI applications"
  homepage "https://github.com/fissible/ptyunit"
  url "https://github.com/fissible/ptyunit/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "12ccb665e59feefdbf6903b6a6603f1aa4f656a5eb50fd83fcc1145a32e5d9be"
  license "MIT"

  depends_on "bash"
  depends_on "python@3" => :recommended

  def install
    # Install core files to libexec (not in PATH directly)
    libexec.install "assert.sh", "mock.sh", "run.sh", "pty_run.py"
    libexec.install "coverage.sh", "coverage_report.py"

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
