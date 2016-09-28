#!/usr/bin/env bash

##
###

oc_ver="7.06"

echo "Autobuild OpenConnect $oc_ver"
echo " "
echo "This script uses apt-get and make install via sudo rights"
echo "To simplify this, we're going to use sudo -v to pre-authenticate you"
sudo -k
sudo -v

## Pre-req packages
sudo apt-get install curl vpnc-scripts build-essential libssl-dev libxml2-dev liblz4-dev
curl -O ftp://ftp.infradead.org/pub/openconnect/openconnect-${oc_ver}.tar.gz
curl -O ftp://ftp.infradead.org/pub/openconnect/openconnect-${oc_ver}.tar.gz.asc
gpg --keyserver pgp.mit.edu --recv-key 67e2f359

if gpg --verify openconnect-${oc_ver}.tar.gz.asc 2>/dev/null 
then
  echo -e "\n++++ GPG Signature Verified OK! ++++\n\n"
else
  gpg --verify openconnect-${oc_ver}.tar.gz.asc  
  echo -e "\n!!!! GPG Signature FAILED. Not proceeding with autobuild !!!!\n\n"
  exit 127
fi

tar xzf openconnect-${oc_ver}.tar.gz
cd openconnect-${oc_ver}

if ! (./configure --without-gnutls --with-vpnc-script=/usr/share/vpnc-scripts/vpnc-script)
then
  echo "!! Configuration was not successful, not proceeding with autobuild"
  exit 1
fi

if ! (make)
then
  echo "!! build was not successful, not proceeding with install"
  exit 2
fi

if ! (sudo make install)
then
  echo "!! installation failed"
  exit 3
fi

if ! (sudo ldconfig /usr/local/lib)
then
  echo "?? error running ldconfig; this MAY be a problem"
  echo "   but we will not exit with an error for it"
fi

exit 0
  