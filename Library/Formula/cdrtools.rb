class Cdrtools < Formula
  desc "CD/DVD/Blu-ray premastering and recording software"
  homepage "http://cdrecord.org/"
  revision 1

  stable do
    url "https://downloads.sourceforge.net/project/cdrtools/cdrtools-3.01.tar.bz2"
    mirror "https://www.mirrorservice.org/sites/downloads.sourceforge.net/c/cd/cdrtools/cdrtools-3.01.tar.bz2"
    mirror "https://fossies.org/linux/misc/cdrtools-3.01.tar.bz2"
    sha256 "ed282eb6276c4154ce6a0b5dee0bdb81940d0cbbfc7d03f769c4735ef5f5860f"

    patch do
      url "https://downloads.sourceforge.net/project/cdrtools/cdrtools-3.01-fix-20151126-mkisofs-isoinfo.patch"
      sha256 "4e07a2be599c0b910ab3401744cec417dbdabf30ea867ee59030a7ad1906498b"
    end
  end

  bottle do
    sha256 "b5a0c5a733c4f33e3ff186f77eeb54a560b1cc9a0ab4436d05996a92822ca72d" => :el_capitan
    sha256 "a7514a01e0318ae4a3d992faa39e411b960f1ff9191903c37c0ed6805e6e76f3" => :yosemite
    sha256 "79aa34f5484ca2b160902805379135d291a22148331ed6247984883d76f6f57d" => :mavericks
  end

  devel do
    url "https://downloads.sourceforge.net/project/cdrtools/alpha/cdrtools-3.02a02.tar.bz2"
    mirror "https://fossies.org/linux/misc/cdrtools-3.02a02.tar.bz2"
    sha256 "b5c33d6cfbe265806f24f365bdb885dfe35194ef716f4b6f809b4377ec159c05"

    patch do
      url "https://downloads.sourceforge.net/project/cdrtools/alpha/cdrtools-3.02a02-fix-20151126-mkisofs.patch"
      sha256 "ae7eb217a4f4b1dd8399899282306fc75aaa3b62b269e7f189448657e3944ac6"
    end
  end

  depends_on "smake" => :build

  conflicts_with "dvdrtools",
    :because => "both dvdrtools and cdrtools install binaries by the same name"

  def install
    # Speed-up the build by skipping the compilation of the profiled libraries.
    # This could be done by dropping each occurence of *_p.mk from the definition
    # of MK_FILES in every lib*/Makefile. But it is much easier to just remove all
    # lib*/*_p.mk files. The latter method produces warnings but works fine.
    rm_f Dir["lib*/*_p.mk"]
    system "smake", "INS_BASE=#{prefix}", "INS_RBASE=#{prefix}", "install"
    # cdrtools tries to install some generic smake headers, libraries and
    # manpages, which conflict with the copies installed by smake itself
    (include/"schily").rmtree
    %w[libschily.a libdeflt.a libfind.a].each do |file|
      (lib/file).unlink
    end
    man5.rmtree
  end

  test do
    system "#{bin}/cdrecord", "-version"
    system "#{bin}/cdda2wav", "-version"
    date = shell_output("date")
    mkdir "subdir" do
      (testpath/"subdir/testfile.txt").write(date)
      system "#{bin}/mkisofs", "-r", "-o", "../test.iso", "."
    end
    assert (testpath/"test.iso").exist?
    system "#{bin}/isoinfo", "-R", "-i", "test.iso", "-X"
    assert (testpath/"testfile.txt").exist?
    assert_equal date, File.read("testfile.txt")
  end
end
