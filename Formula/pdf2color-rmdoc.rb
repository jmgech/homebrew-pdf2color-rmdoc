class Pdf2colorRmdoc < Formula
  desc "Convert PDF to reMarkable .rmdoc using Drawj2d (Paper Pro color-aware)"
  homepage "https://github.com/jmgech/pdf2color-rmdoc"
  url "https://github.com/jmgech/pdf2color-rmdoc/archive/refs/tags/v0.1.0.tar.gz"
  version "0.1.0"
  sha256 "b1124c52fc23e2240abe80d3441b26210e19a9f43bcc62a289ed1eacb3ce6c13"
  license "MIT"

  depends_on "python@3.13"
  depends_on "openjdk"

  resource "drawj2d" do
    url "https://sourceforge.net/projects/drawj2d/files/1.4.0/Drawj2d-1.4.0.zip/download"
    sha256 "8df5aec5617ecb8dd5cfe29aa09779c4c1242690cccdbf79f8c34558a0e385fb"
  end

  resource "pypdf" do
    url "https://files.pythonhosted.org/packages/source/p/pypdf/pypdf-5.0.1.tar.gz"
    sha256 "a361c3c372b4a659f9c8dd438d5ce29a753c79c620dc6e1fd66977651f5547ea"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/source/r/requests/requests-2.32.5.tar.gz"
    sha256 "dbba0bac56e100853db0ea71b82b4dfd5fe2bf6d3754a8893c3af500cec7d7cf"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/source/c/certifi/certifi-2026.1.4.tar.gz"
    sha256 "ac726dd470482006e014ad384921ed6438c457018f4b3d204aea4281258b2120"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/source/c/charset-normalizer/charset_normalizer-3.4.4.tar.gz"
    sha256 "94537985111c35f28720e43603b8e7b43a6ecfb2ce1d3058bbe955b73404e21a"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/source/i/idna/idna-3.11.tar.gz"
    sha256 "795dafcc9c04ed0c1fb032c2aa73654d8e8c5023a7df64a53f39190ada629902"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/source/u/urllib3/urllib3-2.6.2.tar.gz"
    sha256 "016f9c98bb7e98085cb2b4b17b87d2c702975664e4f060c6532e64d1c1a5e797"
  end

  def install
    py = Formula["python@3.13"].opt_bin/"python3.13"

    # Create a venv WITH pip (avoid Homebrew virtualenv helpers that try to link into prefix/bin)
    system py, "-m", "venv", libexec/"venv"
    pip = libexec/"venv/bin/pip"
    python = libexec/"venv/bin/python"

    # Install vendored Python deps (no network)
    resource("pypdf").stage { system pip, "install", "--no-deps", "." }
    resource("requests").stage { system pip, "install", "--no-deps", "." }
    resource("certifi").stage { system pip, "install", "--no-deps", "." }
    resource("charset-normalizer").stage { system pip, "install", "--no-deps", "." }
    resource("idna").stage { system pip, "install", "--no-deps", "." }
    resource("urllib3").stage { system pip, "install", "--no-deps", "." }

    # Install this project into the venv (creates libexec/venv/bin/pdf2color-rmdoc)
    system pip, "install", "--no-deps", "."

    # Unpack Drawj2d into libexec/drawj2d-dist
    resource("drawj2d").stage do
      (libexec/"drawj2d-dist").install Dir["*"]
    end

    jar = (libexec/"drawj2d-dist").glob("**/*.jar").first
    odie "Drawj2d jar not found" unless jar

    # Private Drawj2d wrapper: libexec/drawj2d (do NOT install bin/drawj2d to avoid conflicts)
    (libexec/"drawj2d").write <<~EOS
      #!/bin/bash
      exec "#{Formula["openjdk"].opt_bin}/java" -jar "#{jar}" "$@"
    EOS
    chmod 0755, libexec/"drawj2d"

    # Public CLI wrapper
    (bin/"pdf2color-rmdoc").write_env_script libexec/"venv/bin/pdf2color-rmdoc", {
      "PDF2COLOR_RMDOC_DRAWJ2D" => (libexec/"drawj2d"),
      "PYTHONNOUSERSITE" => "1",
    }
  end

  test do
    system "#{bin}/pdf2color-rmdoc", "-h"
    system "#{libexec}/drawj2d", "-h"
  end
end