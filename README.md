# An Empirical Study of Translation Hypothesis Ensembling with Large Language Models

Official implementation of the **EMNLP 2023** paper **An Empirical Study of Translation Hypothesis Ensembling with Large Language Models**.

_António Farinhas_, _José G. C. de Souza_, and _André F. T. Martins_

**Abstract**:_Large language models (LLMs) are becoming a one-fits-many solution, but they sometimes hallucinate or produce unreliable output. In this paper, we investigate how hypothesis ensembling can improve the quality of the generated text for the specific problem of LLM-based machine translation. We experiment with several techniques for ensembling hypotheses produced by LLMs such as ChatGPT, LLaMA, and Alpaca. We provide a comprehensive study along multiple dimensions, including the method to generate hypotheses (multiple prompts, temperature-based sampling, and beam search) and the strategy to produce the final translation (instruction-based, quality-based reranking, and minimum Bayes risk (MBR) decoding). Our results show that MBR decoding is a very effective method, that translation quality can be improved using a small number of samples, and that instruction tuning has a strong impact on the relation between the diversity of the hypotheses and the sampling temperature._

## Acknowledgments

The code in this repository is based on the implementations of [Touvron et al. (2023)](https://github.com/facebookresearch/llama/tree/llama_v1) and [Taori et al. (2023)](https://github.com/tatsu-lab/stanford_alpaca).