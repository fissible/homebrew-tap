class Shellql < Formula
  desc "Terminal SQLite workbench — browse, query, and edit databases in your terminal"
  homepage "https://github.com/fissible/shellql"
  url "https://github.com/fissible/shellql/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "16f0d7205b8b1673b116757027077b563fab008c27e05d288c32a872161f7947"
  license "MIT"

  depends_on "bash"

  resource "shellframe" do
    url "https://github.com/fissible/shellframe/archive/refs/tags/v0.5.1.tar.gz"
    sha256 "5e6a437a3634100630d9f8c0c5116e787a70a001eeacf62d40d0d13fd3f2a437"
  end

  def install
    # Bundle shellframe inside libexec so shql finds it without env vars
    resource("shellframe").stage do
      (libexec/"shellframe").install Dir["*"]
    end

    # Install the ShellQL source tree to libexec
    libexec.install "bin", "src"

    # Thin wrapper: sets SHELLFRAME_DIR and delegates to the real entry point
    (bin/"shql").write <<~EOS
      #!/usr/bin/env bash
      export SHELLFRAME_DIR="#{libexec}/shellframe"
      export SHQL_VERSION="#{version}"
      exec "#{libexec}/bin/shql" "$@"
    EOS
  end

  test do
    # Use pipe mode (-q) so no TTY is required
    (testpath/"smoke.db").write ""
    system "sqlite3", testpath/"smoke.db",
           "CREATE TABLE items (id INTEGER PRIMARY KEY, name TEXT);"
    system "sqlite3", testpath/"smoke.db",
           "INSERT INTO items VALUES (1, 'hello');"
    output = shell_output("#{bin}/shql #{testpath}/smoke.db -q 'SELECT name FROM items'")
    assert_match "hello", output
  end
end
