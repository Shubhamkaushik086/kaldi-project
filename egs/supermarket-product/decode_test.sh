#!/bin/bash

pre_path=`pwd`
prefix=$pre_path/kaldi/egs/$1
. $prefix/path_decode.sh || exit 1
. $prefix/cmd.sh || exit 1

nj=1         # number of parallel jobs - 1 is perfect for such a small data set
#lm_order=1     # language model order (n-gram quantity) - 1 is enough for digits grammar
#nt=13
# Safety mechanism (possible running this script with modified arguments)
. $prefix/utils/parse_options.sh || exit 1
#[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }

# Removing previously created data (from last run.sh execution)
# rm -rf exp mfcc data/train/spk2utt data/train/utt2dur data/train/cmvn.scp data/train/feats.scp data/train/split1 data/test/spk2utt data/test/cmvn.scp data/test/feats.scp data/test/split1 data/local/lang data/lang data/local/tmp data/local/dict/lexiconp.txt
rm -rf  $prefix/mfcc/cmvn_test.scp $prefix/mfcc/cmvn_test.ark $prefix/mfcc/raw_mfcc_test.1.ark $prefix/mfcc/raw_mfcc_test.1.scp $prefix/data/test/spk2utt $prefix/data/test/cmvn.scp $prefix/data/test/feats.scp $prefix/data/test/split1 $prefix/data/test/split8 $prefix/data/test/split20
# echo
# echo "===== PREPARING ACOUSTIC DATA ====="
# echo

# Needs to be prepared by hand (or using self written scripts):
#
# spk2gender    [<speaker-id> <gender>]
# wav.scp    [<uterranceID> <full_path_to_audio_file>]
# text        [<uterranceID> <text_transcription>]
# utt2spk    [<uterranceID> <speakerID>]
# corpus.txt    [<text_transcription>]

# Making spk2utt files
# utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
  $prefix/utils/utt2spk_to_spk2utt.pl $prefix/data/test/utt2spk > $prefix/data/test/spk2utt

# echo
# echo "===== FEATURES EXTRACTION ====="
# echo

# Making feats.scp files
mfccdir=$prefix/mfcc


# utils/validate_data_dir.sh --no-feats data/train     # script for checking if prepared data is all right
# utils/fix_data_dir.sh data/train          # tool for data sorting if something goes wrong above
#
utils/validate_data_dir.sh --no-feats $prefix/data/test     # script for checking if prepared data is all right
utils/fix_data_dir.sh $prefix/data/test          # tool for data sorting if something goes wrong above

# steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" $prefix/data/test $prefix/exp/make_mfcc/test $mfccdir
#
# # Making cmvn.scp files
# steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh $prefix/data/test $prefix/exp/make_mfcc/test $mfccdir

# echo
# echo "===== PREPARING LANGUAGE DATA ====="
# echo

# Needs to be prepared by hand (or using self written scripts):
#
# lexicon.txt        [<word> <phone 1> <phone 2> ...]
# nonsilence_phones.txt    [<phone>]
# silence_phones.txt    [<phone>]
# optional_silence.txt    [<phone>]

# Preparing language data
# utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang

# echo
# echo "===== LANGUAGE MODEL CREATION ====="
# echo "===== MAKING lm.arpa ====="
# echo
#
# loc=`which ngram-count`;
# if [ -z $loc ]; then
#      if uname -a | grep 64 >/dev/null; then
#         sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
#     else
#             sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
#       fi
#       if [ -f $sdir/ngram-count ]; then
#             echo "Using SRILM language modelling tool from $sdir"
#             export PATH=$PATH:$sdir
#       else
#             echo "SRILM toolkit is probably not installed.
#               Instructions: tools/install_srilm.sh"
#             exit 1
#       fi
# fi
#
# local=data/local
#
# # original version forget to create this folder
# mkdir $local/tmp
# ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa
#
# echo
# echo "===== MAKING G.fst ====="
# echo
#
# lang=data/lang
# cat $local/tmp/lm.arpa | arpa2fst - | fstprint | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$lang/words.txt --osymbols=$lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon | fstarcsort --sort_type=ilabel > $lang/G.fst
#
# echo
# echo "===== MONO TRAINING ====="
# echo
#
# steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono  || exit 1

# echo
# echo "===== MONO DECODING ====="
# echo
#
# # utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/test exp/mono/decode

# echo
# echo "===== MONO ALIGNMENT ====="
# echo
#
# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1
#
# echo
# echo "===== TRI1 (first triphone pass) TRAINING ====="
# echo
#
# steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 data/train data/lang exp/mono_ali exp/tri1 || exit 1

# echo
# echo "===== TRI1 (first triphone pass) DECODING ====="
# echo
#
# # utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode
#

# # align tri1
# echo
# echo "===== TRI1 (first triphone pass) ALIGNE ====="
# echo
#
# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri1 exp/tri1_ali
#
# # train and decode tri2b [LDA+MLLT]
# steps/train_lda_mllt.sh --cmd "$train_cmd" 1800 9000 data/train data/lang exp/tri1_ali exp/tri2b
# utils/mkgraph.sh data/lang exp/tri2b exp/tri2b/graph

# echo
# echo "===== Tri2b [LDA+MLLT] DECODING ====="
# echo
#
# steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b/decode
#


# # Align all data with LDA+MLLT system (tri2b)
# steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri2b exp/tri2b_ali

# #  Do MMI on top of LDA+MLLT.
# steps/make_denlats.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/tri2b exp/tri2b_denlats
# steps/train_mmi.sh data/train data/lang exp/tri2b_ali exp/tri2b_denlats exp/tri2b_mmi
#
# steps/decode.sh --config conf/decode.config --iter 4 --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b_mmi/decode_it4
# steps/decode.sh --config conf/decode.config --iter 3 --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b_mmi/decode_it3
#
# # Do the same with boosting.
# steps/train_mmi.sh --boost 0.05 data/train data/lang exp/tri2b_ali exp/tri2b_denlats exp/tri2b_mmi_b0.05
# steps/decode.sh --config conf/decode.config --iter 4 --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b_mmi_b0.05/decode_it4
# steps/decode.sh --config conf/decode.config --iter 3 --nj $nj --cmd "$decode_cmd" exp/tri2b/graph data/test exp/tri2b_mmi_b0.05/decode_it3
#
# # Do MPE.
# steps/train_mpe.sh data/train data/lang exp/tri2b_ali exp/tri2b_denlats exp/tri2b_mpe
# steps/decode.sh --config conf/decode.config --iter 4 --nj $nj --cmd "$decode_cmd"  exp/tri2b/graph data/test exp/tri2b_mpe/decode_it4
# steps/decode.sh --config conf/decode.config --iter 3 --nj $nj --cmd "$decode_cmd"  exp/tri2b/graph data/test exp/tri2b_mpe/decode_it3

## Do LDA+MLLT+SAT, and decode.
# steps/train_sat.sh 1800 9000 data/train data/lang exp/tri2b_ali exp/tri3b
# utils/mkgraph.sh data/lang exp/tri3b exp/tri3b/graph


# echo
# echo "===== Tri3b [LDA+MLLT+SAT] DECODING ====="
# echo
#
# steps/decode_fmllr.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" \
#   exp/tri3b/graph data/test exp/tri3b/decode
#
#
# Align all data with LDA+MLLT+SAT system (tri3b)
# steps/align_fmllr.sh --nj $nt --cmd "$train_cmd"  \
#     data/train data/lang exp/tri3b exp/tri3b_ali


echo
echo "===== SGMM  DECODING ====="
echo

$prefix/steps/decode_sgmm2.sh --config $prefix/conf/decode.config --nj $nj --cmd "$decode_cmd" \
  --transform-dir $prefix/exp/tri3c/decode  $prefix/exp/sgmm2_4c/graph $prefix/data/test $prefix/exp/sgmm2_4c/decode || exit 1;


# echo
# echo "===== DNN  DECODING ====="
# echo
#
# steps/nnet2/decode.sh --config conf/decode.config --cmd "$decode_cmd" --nj $nj --feat-type raw \
#     --transform-dir exp/tri3c/decode \
#     exp/tri3c/graph data/test exp/nnet4a/decode
#

echo
echo "===== Raw_fMLLR  DECODING ====="
echo

steps/decode_raw_fmllr.sh --config $prefix/conf/decode.config --nj 1 --cmd "$decode_cmd" \
       $prefix/exp/tri3c/graph $prefix/data/test $prefix/exp/tri3c/decode


echo
echo "===== Normal_fMLLR  DECODING ====="
echo

steps/decode_raw_fmllr.sh --use-normal-fmllr true --config $prefix/conf/decode.config --nj 1 --cmd "$decode_cmd" \
      $prefix/exp/tri3c/graph $prefix/data/test $prefix/exp/tri3c/decode_2fmllr


# local/run_raw_fmllr.sh
# local/nnet2/run_4a.sh
#local/run_sgmm2.sh

echo
echo "===== run.sh script is finished ====="
echo
