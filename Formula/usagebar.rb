class Usagebar < Formula
  include Language::Python::Virtualenv

  desc "Menu bar monitor and MCP server for Claude Code usage limits"
  homepage "https://github.com/dnlbit/usagebar"
  url "https://github.com/dnlbit/usagebar/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "879c01eb0c0d424c70afa72a17b5fee3560a8d55c76167416721ac65848ebed2"
  license "MIT"

  depends_on :macos
  depends_on "python@3.15"

  resource "pyobjc-core" do
    url "https://files.pythonhosted.org/packages/a5/78/abc4ce5920305780aeb36b4067a86253378b36e29ba96673a3deb02eb03a/pyobjc_core-12.2.2.tar.gz"
    sha256 "3906452339cd06a3bb07df103c2511d4cb0f7a22d8771c0b802eba15d9a642b6"
  end

  resource "pyobjc-framework-cocoa" do
    url "https://files.pythonhosted.org/packages/75/76/49c6da2c6a831020b4854ba20079d5a1030474bffc776b7b73c2eeff8c15/pyobjc_framework_cocoa-12.2.2.tar.gz"
    sha256 "c96c0ef69a71afbbb0e6a7d594b455c5fe47d62e0db376ee7a2b4b828c16ace9"
  end

  resource "rumps" do
    url "https://files.pythonhosted.org/packages/b2/e2/2e6a47951290bd1a2831dcc50aec4b25d104c0cf00e8b7868cbd29cf3bfe/rumps-0.4.0.tar.gz"
    sha256 "17fb33c21b54b1e25db0d71d1d793dc19dc3c0b7d8c79dc6d833d0cffc8b1596"
  end

  def install
    venv = virtualenv_create(libexec, "python3.15")
    venv.pip_install resources
    libexec.install "monitor.py", "mcp_server.py"
    (bin/"usagebar").write_env_script libexec/"bin/python", libexec/"monitor.py", {}
    (bin/"usagebar-mcp").write_env_script libexec/"bin/python", libexec/"mcp_server.py", {}
  end

  def caveats
    <<~EOS
      Start the menu bar app now and at login:
        brew services start usagebar
      Add the MCP server to Claude Code:
        claude mcp add usagebar -s user -- #{opt_bin}/usagebar-mcp
    EOS
  end

  service do
    run opt_bin/"usagebar"
    environment_variables PATH: "#{Dir.home}/.local/bin:/usr/local/bin:#{std_service_path_env}"
    log_path "/tmp/usagebar.log"
    error_log_path "/tmp/usagebar.log"
  end

  test do
    system libexec/"bin/python", libexec/"monitor.py", "--test"
    system libexec/"bin/python", libexec/"mcp_server.py", "--test"
  end
end
