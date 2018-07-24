class ProxychainsNg < Formula
  desc "Hook preloader"
  homepage "https://sourceforge.net/projects/proxychains-ng/"
  url "https://github.com/rofl0r/proxychains-ng/releases/download/v4.12/proxychains-ng-4.12.tar.xz"
  sha256 "482a549935060417b629f32ddadd14f9c04df8249d9588f7f78a3303e3d03a4e"
  revision 1

  head "https://github.com/rofl0r/proxychains-ng.git"

  def install
    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    system "make"
    system "make", "install"
    system "make", "install-config"
  end

  test do
    assert_match "config file found", shell_output("#{bin}/proxychains4 test 2>&1", 1)
  end
end
