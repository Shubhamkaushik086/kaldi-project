#!/bin/bash
cd /home/nlpserver/zzilong/kaldi/egs/supermarket-product
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
nnet-am-average exp/nnet4a/91.1.mdl exp/nnet4a/91.2.mdl exp/nnet4a/91.3.mdl exp/nnet4a/91.4.mdl exp/nnet4a/91.5.mdl exp/nnet4a/91.6.mdl exp/nnet4a/91.7.mdl exp/nnet4a/91.8.mdl - | nnet-am-copy --learning-rates=0.00886465476882747:0.00443232738441374:0.00443232738441374 - exp/nnet4a/91.mdl 
EOF
) >exp/nnet4a/log/average.90.log
time1=`date +"%s"`
 ( nnet-am-average exp/nnet4a/91.1.mdl exp/nnet4a/91.2.mdl exp/nnet4a/91.3.mdl exp/nnet4a/91.4.mdl exp/nnet4a/91.5.mdl exp/nnet4a/91.6.mdl exp/nnet4a/91.7.mdl exp/nnet4a/91.8.mdl - | nnet-am-copy --learning-rates=0.00886465476882747:0.00443232738441374:0.00443232738441374 - exp/nnet4a/91.mdl  ) 2>>exp/nnet4a/log/average.90.log >>exp/nnet4a/log/average.90.log
ret=$?
time2=`date +"%s"`
echo '#' Accounting: time=$(($time2-$time1)) threads=1 >>exp/nnet4a/log/average.90.log
echo '#' Finished at `date` with status $ret >>exp/nnet4a/log/average.90.log
[ $ret -eq 137 ] && exit 100;
touch exp/nnet4a/q/done.26452
exit $[$ret ? 1 : 0]
## submitted with:
# qsub -v PATH -cwd -S /bin/bash -j y -l arch=*64* -o exp/nnet4a/q/average.90.log -l mem_free=10G,ram_free=2G,arch=*64    /home/nlpserver/zzilong/kaldi/egs/supermarket-product/exp/nnet4a/q/average.90.sh >>exp/nnet4a/q/average.90.log 2>&1
