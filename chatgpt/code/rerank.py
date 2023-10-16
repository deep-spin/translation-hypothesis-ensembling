import argparse
import numpy as np
import torch
import pandas as pd

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("hyps", type=str)
    parser.add_argument("segmetrics", type=str)
    parser.add_argument("nsamples", type=int)
    parser.add_argument("--save-cometkiwi", default=None)
    parser.add_argument("--save-cometkiwixxl", default=None)
    parser.add_argument("--save-cometoracle", default=None)
    parser.add_argument("--save-singleprediction", default=None)


    args = parser.parse_args()

    # get translations df
    with open(args.hyps, encoding="utf-8") as hyp_f:
            hyps = [line.strip() for line in hyp_f.readlines()]
    translations_df = pd.DataFrame(hyps)
    # read metrics df
    metrics_df = pd.read_csv(args.segmetrics, sep=" ")

    # reranking with cometkiwi
    cometkiwi_df = metrics_df.loc[metrics_df.groupby(metrics_df.index // args.nsamples)["cometkiwi"].idxmax()]
    # get df with the best translations according to cometkiwi
    translations_cometkiwi_df = translations_df.iloc[cometkiwi_df.index]
    # convert to list
    translations_cometkiwi_l = translations_cometkiwi_df[0].values.tolist()
    # write to file
    if args.save_cometkiwi is not None:
        with open(args.save_cometkiwi, mode='wt', encoding='utf-8') as f:
            f.write('\n'.join(translations_cometkiwi_l))

    # reranking with comet (oracle)
    comet_df = metrics_df.loc[metrics_df.groupby(metrics_df.index // args.nsamples)["comet"].idxmax()]
    # get df with the best translations according to comet
    translations_comet_df = translations_df.iloc[comet_df.index]
    # convert to list
    translations_comet_l = translations_comet_df[0].values.tolist()
    # write to file
    if args.save_cometoracle is not None:
        with open(args.save_cometoracle, mode='wt', encoding='utf-8') as f:
            f.write('\n'.join(translations_comet_l))
    
    if args.save_cometkiwixxl is not None:
        # reranking with cometkiwi
        cometkiwixxl_df = metrics_df.loc[metrics_df.groupby(metrics_df.index // args.nsamples)["cometkiwi-xxl"].idxmax()]
        # get df with the best translations according to cometkiwi
        translations_cometkiwixxl_df = translations_df.iloc[cometkiwixxl_df.index]
        # convert to list
        translations_cometkiwixxl_l = translations_cometkiwixxl_df[0].values.tolist()
        # write to file
        with open(args.save_cometkiwixxl, mode='wt', encoding='utf-8') as f:
            f.write('\n'.join(translations_cometkiwixxl_l))

    # save single prediction (as if it was one sample only)
    singlepred_df = metrics_df[metrics_df.index % args.nsamples == 0]
    translations_singlepred_df = translations_df.iloc[singlepred_df.index]
    translations_singlepred_l = translations_singlepred_df[0].values.tolist()
    if args.save_singleprediction is not None:
        with open(args.save_singleprediction, mode='wt', encoding='utf-8') as f:
            f.write('\n'.join(translations_singlepred_l))


if __name__ == "__main__":
    main()