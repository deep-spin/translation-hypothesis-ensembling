import argparse
import numpy as np
import torch

COMETQE_MODEL = "Unbabel/wmt22-cometkiwi-da"
COMETQE_BATCH_SIZE = 64
COMET_MODEL = "Unbabel/wmt22-comet-da"
COMET_BATCH_SIZE = 64
COMETQEXXL_MODEL = "Unbabel/wmt22-cometkiwi-da-xxl"
COMETQEXXL_BATCH_SIZE = 4

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("hyp", type=str)
    parser.add_argument("ref", type=str)
    parser.add_argument("--no-lexical-metrics", action="store_true")
    parser.add_argument("--no-comet", action="store_true")
    parser.add_argument("--no-comet-qe", action="store_true")
    parser.add_argument("--no-comet-qe-xxl", action="store_true")
    parser.add_argument("--src", type=str)
    parser.add_argument("--save-segment-level", default=None)
    parser.add_argument("--save-corpus-level", default=None)

    args = parser.parse_args()

    with open(args.hyp, encoding="utf-8") as hyp_f:
        hyps = [line.strip() for line in hyp_f.readlines()]
    with open(args.ref, encoding="utf-8") as ref_f:
        refs = [line.strip() for line in ref_f.readlines()]

    sentence_metrics = [[] for _ in range(len(refs))]

    if not args.no_lexical_metrics:
        import sacrebleu

        # gets corpus-level non-ml evaluation metrics
        # corpus-level BLEU
        bleu = sacrebleu.metrics.BLEU()
        corpus_bleu = bleu.corpus_score(hyps, [refs])
        bleu_signature = str(bleu.get_signature())
        print(corpus_bleu)
        # corpus-level chrF
        chrf = sacrebleu.metrics.CHRF()
        corpus_chrf = chrf.corpus_score(hyps, [refs])
        chrf_signature = str(chrf.get_signature())
        print(corpus_chrf)
        # corpus-level TER
        ter = sacrebleu.metrics.TER()
        corpus_ter = ter.corpus_score(hyps, [refs])
        ter_signature = str(ter.get_signature())
        print(corpus_ter)

        if args.save_segment_level is not None:
            # gets sentence-level non-ml metrics
            for i, (hyp, ref) in enumerate(zip(hyps, refs)):
                sentence_metrics[i].append(
                    ("bleu", sacrebleu.sentence_bleu(hyp, [ref]).score)
                )
                sentence_metrics[i].append(
                    ("chrf", sacrebleu.sentence_chrf(hyp, [ref]).score)
                )
                sentence_metrics[i].append(
                    ("ter", sacrebleu.sentence_ter(hyp, [ref]).score)
                )

    if not args.no_comet_qe:
        from comet import download_model, load_from_checkpoint

        assert args.src is not None, "source needs to be provided to use COMETKIWI"
        with open(args.src) as src_f:
            srcs = [line.strip() for line in src_f.readlines()]

        # downloads comet and load
        comet_path = download_model(COMETQE_MODEL)
        comet_model = load_from_checkpoint(comet_path)

        print("Running COMET evaluation...")
        comet_input = [
            {"src": src, "mt": mt} for src, mt in zip(srcs, hyps)
        ]
        # sentence-level and corpus-level COMET
        comet_output = comet_model.predict(
            comet_input, batch_size=COMETQE_BATCH_SIZE
        )

        comet_sentscores = comet_output.scores
        comet_score = comet_output.system_score

        for i, comet_sentscore in enumerate(comet_sentscores):
            sentence_metrics[i].append(("comet", comet_sentscore))

        corpus_cometkiwi = comet_score
        print(f"COMETKIWI = {comet_score:.4f}")

    if not args.no_comet:
        from comet import download_model, load_from_checkpoint

        assert args.src is not None, "source needs to be provided to use COMET"
        with open(args.src) as src_f:
            srcs = [line.strip() for line in src_f.readlines()]

        # downloads comet and load
        comet_path = download_model(COMET_MODEL)
        comet_model = load_from_checkpoint(comet_path)

        print("Running COMET evaluation...")
        comet_input = [
            {"src": src, "mt": mt, "ref": ref} for src, mt, ref in zip(srcs, hyps, refs)
        ]
        # sentence-level and corpus-level COMET
        comet_output = comet_model.predict(
            comet_input, batch_size=COMET_BATCH_SIZE
        )

        comet_sentscores = comet_output.scores
        comet_score = comet_output.system_score

        for i, comet_sentscore in enumerate(comet_sentscores):
            sentence_metrics[i].append(("comet", comet_sentscore))

        corpus_comet = comet_score
        print(f"COMET = {comet_score:.4f}")

    if not args.no_comet_qe_xxl:
        from comet import download_model, load_from_checkpoint

        assert args.src is not None, "source needs to be provided to use COMETKIWI-XXL"
        with open(args.src) as src_f:
            srcs = [line.strip() for line in src_f.readlines()]

        # downloads comet and load
        comet_path = download_model(COMETQEXXL_MODEL)
        comet_model = load_from_checkpoint(comet_path)

        print("Running COMET evaluation...")
        comet_input = [
            {"src": src, "mt": mt} for src, mt in zip(srcs, hyps)
        ]
        # sentence-level and corpus-level COMET
        comet_output = comet_model.predict(
            comet_input, batch_size=COMETQEXXL_BATCH_SIZE
        )

        comet_sentscores = comet_output.scores
        comet_score = comet_output.system_score

        for i, comet_sentscore in enumerate(comet_sentscores):
            sentence_metrics[i].append(("comet", comet_sentscore))

        corpus_cometkiwi_xxl = comet_score
        print(f"COMETKIWI-XXL = {comet_score:.4f}")

    # saves segment-level scores to the disk
    if args.save_segment_level is not None:
        with open(args.save_segment_level, "w") as f:
            if not args.no_comet_qe_xxl:
                print(" ".join(f"{metric_name}" for metric_name in ["bleu", "chrf", "ter", "cometkiwi", "comet", "cometkiwi-xxl"]), file=f)
            else:
                if not args.no_comet_qe:
                    print(" ".join(f"{metric_name}" for metric_name in ["bleu", "chrf", "ter", "cometkiwi", "comet"]), file=f)
                else:
                    print(" ".join(f"{metric_name}" for metric_name in ["bleu", "chrf", "ter", "comet"]), file=f)

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
            print("\n".join(f"{metric_value}" for metric_value in [corpus_bleu, corpus_chrf, corpus_ter]), file=f)
            if not args.no_comet_qe:
                print(f"CometKiwi = {corpus_cometkiwi}", file=f)
            print(f"Comet = {corpus_comet}", file=f)
            if not args.no_comet_qe_xxl:
                print(f"CometKiwi-XXL = {corpus_cometkiwi_xxl}", file=f)
            print("non-ml metric signatures", file=f)
            print("\n".join(f"{metric_signature}" for metric_signature in [bleu_signature, chrf_signature, ter_signature]), file=f)

if __name__ == "__main__":
    main()