#!/bin/bash
cd /home/nlpserver/zzilong/kaldi/egs/supermarket-product
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
nnet-am-average exp/nnet4a/235.1.mdl exp/nnet4a/235.2.mdl exp/nnet4a/235.3.mdl exp/nnet4a/235.4.mdl exp/nnet4a/235.5.mdl exp/nnet4a/235.6.mdl exp/nnet4a/235.7.mdl exp/nnet4a/235.8.mdl - | nnet-am-copy --learning-rates=0.004:0.002:0.002 - exp/nnet4a/235.mdl 
EOF
) >exp/nnet4a/log/average.234.log
time1=`date +"%s"`
 ( nnet-am-average exp/nnet4a/235.1.mdl exp/nnet4a/235.2.mdl exp/nnet4a/235.3.mdl exp/nnet4a/235.4.mdl exp/nnet4a/235.5.mdl exp/nnet4a/235.6.mdl exp/nnet4a/235.7.mdl exp/nnet4a/235.8.mdl - | nnet-am-copy --learning-rates=0.004:0.002:0.002 - exp/nnet4a/235.mdl  ) 2>>exp/nnet4a/log/average.234.log >>exp/nnet4a/log/average.234.log
ret=$?
time2=`date +"%s"`
echo '#' Accounting: time=$(($time2-$time1)) threads=1 >>exp/nnet4a/log/average.234.log
echo '#' Finished at `date` with status $ret >>exp/nnet4a/log/average.234.log
[ $ret -eq 137 ] && exit 100;
touch exp/nnet4a/q/done.16414
exit $[$ret ? 1 : 0]
## submitted with:
# qsub -v PATH -cwd -S /bin/bash -j y -l arch=*64* -o exp/nnet4a/q/average.234.log -l mem_free=10G,ram_free=2G,arch=*64    /home/nlpserver/zzilong/kaldi/egs/supermarket-product/exp/nnet4a/q/average.234.sh >>exp/nnet4a/q/average.234.log 2>&1
