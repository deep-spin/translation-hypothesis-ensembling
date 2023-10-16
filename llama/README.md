
The code in this repo is based on the implementation of [LLaMA](https://github.com/facebookresearch/llama/tree/llama_v1). Follow these steps to get corpus and segment level scores for single prediction, reranking with cometkiwi, mbr decoding with comet, and reranking with comet (oracle):

1. Follow the instructions in `translation-hypothesis-ensembling/data/wmt22` to get the data, if you haven't done it before.
2. Install the requirements to run LLaMA (v1) by following the instructions in https://github.com/facebookresearch/llama/tree/llama_v1. You may want to move the files in this dir to your local copy of [LLaMA](https://github.com/facebookresearch/llama/tree/llama_v1).
3. Update the paths to the repo, virtual env, and LLaMA checkpoints (when needed) in `wmt22-translate-multiple.sh`, `wmt22-score-multiple.sh`, and `wmt22-rerank-multiple.sh`.
4. Run `bash wmt22-translate-multiple.sh`. 
5. Run `bash wmt22-score-multiple.sh`.
6. For translation hypothesis ensembling, run `bash code/wmt22-rerank-multiple.sh`.

The results will be saved at `results/`.


