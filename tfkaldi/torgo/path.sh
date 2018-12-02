export KALDI_ROOT=$HOME/kaldi
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/tools/extras/irstlm/bin/:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C

#  ISRLM
export SRILM=/home/akshay/kaldi/tools/srilm
export PATH=${PATH}:${SRILM}/bin/i686-m64

# SEQUITUR
export SEQUITUR=/home/akshay/kaldi/tools/sequitur-g2p
export PATH=$PATH:${SEQUITUR}/bin
_site_packages=`find ${SEQUITUR}/lib -type d -regex '.*python.*/site-packages'`
export PYTHONPATH=$PYTHONPATH:$_site_packages

# Torgo data
export DATA_ORIG="/media/akshay/d0b8fac2-cfb8-4072-be08-8a9fb8066f5e/home/akshay/datasets/TORGO"
export DATA_ROOT=`pwd`

if [ -z $DATA_ROOT ]; then
  echo "You need to set \"DATA_ROOT\" variable in path.sh to point to the directory where Torgo data will be"
  exit 1
fi
