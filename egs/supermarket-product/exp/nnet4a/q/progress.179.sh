#!/bin/bash
cd /home/nlpserver/zzilong/kaldi/egs/supermarket-product
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
nnet-show-progress --use-gpu=no exp/nnet4a/178.mdl exp/nnet4a/179.mdl ark:exp/nnet4a/egs/train_diagnostic.egs 
EOF
) >exp/nnet4a/log/progress.179.log
time1=`date +"%s"`
 ( nnet-show-progress --use-gpu=no exp/nnet4a/178.mdl exp/nnet4a/179.mdl ark:exp/nnet4a/egs/train_diagnostic.egs  ) 2>>exp/nnet4a/log/progress.179.log >>exp/nnet4a/log/progress.179.log
ret=$?
time2=`date +"%s"`
echo '#' Accounting: time=$(($time2-$time1)) threads=1 >>exp/nnet4a/log/progress.179.log
echo '#' Finished at `date` with status $ret >>exp/nnet4a/log/progress.179.log
[ $ret -eq 137 ] && exit 100;
touch exp/nnet4a/q/done.1494
exit $[$ret ? 1 : 0]
## submitted with:
# qsub -v PATH -cwd -S /bin/bash -j y -l arch=*64* -o exp/nnet4a/q/progress.179.log -l mem_free=10G,ram_free=2G,arch=*64    /home/nlpserver/zzilong/kaldi/egs/supermarket-product/exp/nnet4a/q/progress.179.sh >>exp/nnet4a/q/progress.179.log 2>&1
