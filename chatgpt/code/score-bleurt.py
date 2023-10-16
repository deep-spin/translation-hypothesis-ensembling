import argparse
import numpy as np


BLEURT_BATCH_SIZE = 64

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("hyp", type=str)
    parser.add_argument("ref", type=str)
    parser.add_argument("--bleurt-dir", type=str, default=None)
    parser.add_argument("--save-segment-level", default=None)
    parser.add_argument("--save-corpus-level", default=None)

    args = parser.parse_args()

    with open(args.hyp, encoding="utf-8") as hyp_f:
        hyps = [line.strip() for line in hyp_f.readlines()]
    with open(args.ref, encoding="utf-8") as ref_f:
        refs = [line.strip() for line in ref_f.readlines()]

    sentence_metrics = [[] for _ in range(len(refs))]

    # gets BLEURT scores
    if args.bleurt_dir is not None:
        from bleurt import score

        checkpoint = args.bleurt_dir

        bleurt_scorer = score.LengthBatchingBleurtScorer(checkpoint)
        bleurt_scores = bleurt_scorer.score(
            references=refs, candidates=hyps, batch_size=BLEURT_BATCH_SIZE
        )
        assert type(bleurt_scores) == list
        # corpus-level BLEURT
        print(f"BLEURT = {np.array(bleurt_scores).mean():.4f}")
        for i, bleurt_score in enumerate(bleurt_scores):
            sentence_metrics[i].append(("bleurt", bleurt_score))

    # saves segment-level scores to the disk
    if args.save_segment_level is not None:
        with open(args.save_segment_level, "w") as f:

            print(" ".join(f"{metric_name}" for metric_name in ["bleurt"]), file=f)
            for metrics in sentence_metrics:
                print(
                    " ".join(
                        f"{value}" for metric_name, value in metrics
                    ),
                    file=f,
                )
    
    # saves corpus-level scores to the disk
    if args.save_corpus_level is not None:
        with open(args.save_corpus_level, "w") as f:
            print(f"BLEURT = {np.array(bleurt_scores).mean():.4f}", file=f)

if __name__ == "__main__":
    main()