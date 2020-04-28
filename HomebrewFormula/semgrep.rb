class Semgrep < Formula
  include Language::Python::Virtualenv
  desc "Like grep but for code"
  homepage "https://github.com/returntocorp/semgrep"

  stable do
    url "https://github.com/returntocorp/semgrep/archive/v0.5.0.tar.gz"
    sha256 "f7d32d0ec45933b7f933b5729174ab9464ff3b15bbc0f99990eebfd5fa79a483"

    resource "ocaml-binary" do
      url "https://github.com/returntocorp/semgrep/releases/download/v0.5.0/semgrep-v0.5.0-osx.zip"
      sha256 "0c40dd232057ca65387aeb12e5d03f0797f07630dc7ad89dc075a3d8559ea4e8"
    end
  end

  devel do
    url "https://github.com/returntocorp/semgrep/archive/v0.5.0b2.tar.gz"
    sha256 "df96144aee5ab226b0ba66fd7b932b060a4d3255794d1801924f35112f78e173"
    resource "ocaml-binary" do
      url "https://github.com/returntocorp/semgrep/releases/download/v0.5.0b2/semgrep-v0.5.0b2-osx.zip"
      sha256 "8414db3dc7c523d8c5724971c6aab77b71dd52bb7eee1c52eeec4cebae8df0c4"
    end
  end

  head do
    url "https://github.com/returntocorp/semgrep.git", :branch => "develop"
    resource "ocaml-binary" do
      # TODO: point this at the develop branch URL for the semgrep binary
      url "https://github.com/returntocorp/semgrep/releases/download/v0.5.0b1/semgrep-v0.5.0b1-osx.zip"
      sha256 "26756cad63011f305033933937c7649ffcedffd9382e2ff42b893ba6e89ff9d5"
    end
  end

  depends_on "coreutils"
  depends_on "python@3.8"

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/b8/e2/a3a86a67c3fc8249ed305fc7b7d290ebe5e4d46ad45573884761ef4dea7b/certifi-2020.4.5.1.tar.gz"
    sha256 "51fcb31174be6e6664c5f69e3e1691a2d72a1a12e90f872cbdb1567eb47b6519"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"
    sha256 "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"
  end

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/82/75/f2a4c0c94c85e2693c229142eb448840fba0f9230111faa889d1f541d12d/colorama-0.4.3.tar.gz"
    sha256 "e96da0d330793e2cb9485e9ddfd918d456036c7149416295932478192f4436a1"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"
    sha256 "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/3d/d9/ea9816aea31beeadccd03f1f8b625ecf8f645bd66744484d162d84803ce5/PyYAML-5.3.tar.gz"
    sha256 "e9f45bd5b92c7974e59bcd2dcc8631a6b6cc380a904725fce7bc08872e691615"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/01/62/ddcf76d1d19885e8579acb1b1df26a852b03472c0e46d2b959a714c90608/requests-2.22.0.tar.gz"
    sha256 "11e007a8a2aa0323f5a921e9e6a2d7e4e67d9877e85773fba9ba6419025cbeb4"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/09/06/3bc5b100fe7e878d3dee8f807a4febff1a40c213d2783e3246edde1f3419/urllib3-1.25.8.tar.gz"
    sha256 "87716c2d2a7121198ebcb7ce7cccf6ce5e9ba539041cfbaeecfb641dc0bf6acc"
  end

  def install
    (buildpath/"ocaml-binary").install resource("ocaml-binary")

    bin.install "ocaml-binary/semgrep-core"

    cd "semgrep" do
      venv = virtualenv_create(libexec, Formula["python@3.8"].bin/"python3.8")
      python_deps = resources.reject do |resource|
        resource.name == "ocaml-binary"
      end
      venv.pip_install python_deps
      venv.pip_install_and_link buildpath/python_path
    end
  end
  test do
    system "#{bin}/semgrep --help"
    (testpath/"script.py").write <<~EOS
      def silly_eq(a, b):
        return a + b == a + b
    EOS

    output = shell_output("#{bin}/semgrep script.py -l python -e '$X == $X'")
    assert_match "a + b == a + b", output
  end
end
