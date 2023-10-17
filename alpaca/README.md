Follow these steps to get corpus and segment level scores for single prediction, reranking with cometkiwi, mbr decoding with comet, and reranking with comet (oracle):

1. Follow the instructions in `translation-hypothesis-ensembling/data/wmt22` to get the data, if you haven't done it before.
2. Install the requirements to run Alpaca by following the instructions in https://github.com/tatsu-lab/stanford_alpaca.
3. Update the paths to the repo, virtual env, and Alpaca checkpoints (when needed) in `wmt22-translate-sampling.sh`, `wmt22-score-sampling.sh`, and `wmt22-rerank-sampling.sh`.
4. Run `bash wmt22-translate-sampling.sh`. 
5. Run `bash wmt22-score-sampling.sh`.
6. For translation hypothesis ensembling, run `bash wmt22-rerank-sampling.sh`.

The results will be saved at `results/`.