class Shellql < Formula
  desc "Terminal SQLite workbench — browse, query, and edit databases in your terminal"
  homepage "https://github.com/fissible/shellql"
  url "https://github.com/fissible/shellql/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
  license "MIT"

  depends_on "bash"

  resource "shellframe" do
    url "https://github.com/fissible/shellframe/archive/refs/tags/v0.5.0.tar.gz"
    sha256 "49ce89f8fc83f29e0c11e16ad9550b2bdb1a0a01d7fd1ae81f35ff3e683f07d7"
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
