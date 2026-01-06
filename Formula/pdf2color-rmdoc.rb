class Pdf2colorRmdoc < Formula
  include Language::Python::Virtualenv

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

  def install
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install_and_link buildpath

    resource("drawj2d").stage do
      (libexec/"drawj2d").install Dir["*"]
    end

    jar = (libexec/"drawj2d").glob("**/*.jar").first
    odie "Drawj2d jar not found" unless jar

    (bin/"drawj2d").write <<~EOS
      #!/bin/bash
      exec "#{Formula["openjdk"].opt_bin}/java" -jar "#{jar}" "$@"
    EOS
    chmod 0755, bin/"drawj2d"
  end

  test do
    system "#{bin}/pdf2color-rmdoc", "-h"
    system "#{bin}/drawj2d", "-h"
  end
end
