#!/bin/bash

# Author: Cristina Espana-Bonet
# Adaptation from Voxforge run.sh:
# Copyright 2012 Vassil Panayotov
# Apache 2.0
# Paths to software and data
. ./path.sh || exit 1

# If you have cluster of machines running GridEngine you may want to
# change the train and decode commands in the file below
. ./cmd.sh || exit 1

# The number of parallel jobs to be started for some parts of the recipe
# Since the test is just one speaker we don't parellelize it
# Make sure you have enough resources(CPUs and RAM) to accomodate this number of jobs
njobs=1
njobsT=1

# Test-time language model order
lm_order=2

# Word position dependent phones?
pos_dep_phones=true

# Test user
spk_test=$1

# Number of leaves and total gaussians
leaves=1800
gaussians=9000

# The user of this script could change some of the above parameters. Example:
# /bin/bash run.sh --pos-dep-phones false
. utils/parse_options.sh || exit 1

[[ $# -ge 2 ]] && { echo "Unexpected arguments"; exit 1; }



# Initial extraction and distribution of the data: data/{train,test} directories
## TODO: aixo no em funciona i hauria pq es standard
#local/torgo_data_prep.sh --spk_test ${spk_test} || exit 1
local/torgo_data_prep.sh ${spk_test} || exit 1

# Prepare ARPA LM and vocabulary using SRILM
local/torgo_prepare_lm.sh --order ${lm_order} || exit 1

# Prepare the lexicon and various phone lists
# Pronunciations for OOV words are obtained using a pre-trained Sequitur model
local/torgo_prepare_dict.sh || exit 1

# Prepare data/lang and data/local/lang directories
echo ""
echo "=== Preparing data/lang and data/local/lang directories ..."
echo ""
utils/prepare_lang.sh --position-dependent-phones $pos_dep_phones \
  data/local/dict '!SIL' data/local/lang data/lang || exit 1

# Prepare G.fst and data/{train,test} directories
local/torgo_prepare_grammar.sh "test" || exit 1
