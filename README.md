# homebrew-pdf2color-rmdoc

Homebrew tap for `pdf2color-rmdoc`, a tool that converts PDF files into
reMarkable `.rmdoc` notebooks using Drawj2d, with color support on
reMarkable Paper Pro when supported by the source PDF.

## Install

Add the tap and install the formula:

    brew tap jmgech/pdf2color-rmdoc
    brew install pdf2color-rmdoc

## Usage

Convert a PDF to `.rmdoc`:

    pdf2color-rmdoc input.pdf

Specify an output file:

    pdf2color-rmdoc input.pdf -o output.rmdoc

Optional scaling resolution (useful for Paper Pro):

    pdf2color-rmdoc input.pdf --resolution 229

## Notes

- Color preservation depends on Drawj2d’s reMarkable backend and the
  exact colors used in the source PDF.
- PDFs using unsupported or near colors may still appear partially or
  fully grayscale.
- Java (OpenJDK) is installed automatically as a dependency.

## Upstream project

Application repository:
https://github.com/jmgech/pdf2color-rmdoc