Follow these steps to get corpus and segment level scores for single prediction, reranking with cometkiwi, mbr decoding with comet, and reranking with comet (oracle):

1. Follow the instructions in `translation-hypothesis-ensembling/data/wmt22` to get the data.
2. Add your OpenAI API key/organization in `code/translator.py`.
3. Update the paths to the repo and virtual env in `code/wmt22-translate.sh`, `code/wmt22-score.sh`, `code/wmt22-rerank.sh`, and `code/wmt22-score-bleurt.sh`.
4. Run `bash code/wmt22-translate.sh`. 
5. Run `bash code/wmt22-score.sh`.
6. Run `bash code/wmt22-score-bleurt.sh`.
7. For translation hypothesis ensembling, run `bash code/wmt22-rerank.sh`.

The results will be saved at `results/`.