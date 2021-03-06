#! /bin/sh
# Export and build an exiv2 release, 26-Jan-06, ahu

if [ $# -eq 0 ] ; then
    echo "Usage: `basename $0` <tagname>|trunk"
    cat <<EOF

Export and build an Exiv2 release.
EOF
    exit 1
fi

rel=$1
here=$PWD
(
if [ -e $rel ] ; then
    echo File $rel already exists, exiting...
    exit 1
fi
if [ -e exiv2-$rel ] ; then
    echo File exiv2-$rel already exists, exiting...
    exit 1
fi
echo
echo ==========================================================================
echo Exporting sources, this may take a while...
echo
path=tags/$rel
if [ $rel = trunk ] ; then
    path=trunk
fi
svn export svn://dev.exiv2.org/svn/$path
version=$(grep AC_INIT $path/config/configure.ac  | cut -d, -f 2 | sed -E -e 's/ //g')
mv $rel exiv2-$version-$rel
rel="$version-$rel"

echo
echo ==========================================================================
echo Preparing the source code
echo
cd exiv2-$rel
make config
./configure --disable-shared
make -j4
sudo make install
make -j4 samples
make doc
make tests
rm -f  ABOUT-NLS
rm -f .gitignore
rm -rf kdevelop/
sudo make uninstall
make   distclean
rm -rf test/tmp
rm -f  Makefile
rm -f  bootstrap.linux
rm -rf xmpsdk/src/.libs
rm -f  config.log
rm -rf website
rm -f  fixxml.sh
echo
echo ==========================================================================
echo Creating source and doc packages
echo
cd ..
COPYFILE_DISABLE=1 tar zcvf exiv2-$rel-doc.tar.gz exiv2-$rel/doc/index.html exiv2-$rel/doc/html exiv2-$rel/doc/include
rm -rf exiv2-$rel/doc/html
COPYFILE_DISABLE=1 tar zcvf exiv2-$rel.tar.gz exiv2-$rel
echo
echo ==========================================================================
echo Testing the tarball: unpack, build and run tests
echo
rm -rf exiv2-$rel
tar zxvf exiv2-$rel.tar.gz
cd exiv2-$rel
./configure
make -j4
sudo make install
make -j4 samples
echo Exporting tests, this may take a while...
svn  export svn://dev.exiv2.org/svn/$rel/test
du -sk test/
make  tests
echo
echo ==========================================================================
echo Error-summary
echo
grep 'Error ' $here/exiv2-buildrelease-$rel.out | grep -v -e'BasicError ' -e'Error 1 (ignored)'

) 2>&1 | tee $here/exiv2-buildrelease-$rel.out 2>&1

if [ -e exiv2-$rel.tar.gz ]; then
	ls -alt exiv2-$rel.tar.gz
fi

# That's all Folks
##

