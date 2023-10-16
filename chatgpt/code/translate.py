import sys, argparse, json, os, pickle
import numpy as np
import torch
from translator import OpenAITranslator
import openai
from tqdm import tqdm

def main():
    parser = argparse.ArgumentParser(description='Description.')
    parser.add_argument("-s", "--source", type=str, help="path to source file")
    parser.add_argument("-o", "--output", type=str, help="output file")
    parser.add_argument("--source-lang", type=str, help="source language")
    parser.add_argument("--target-lang", type=str, help="target language")
    parser.add_argument("-n", "--n-samples", type=int, default=1, help="number of samples; default's 1")
    parser.add_argument("--temperature", type=float, default=1.0, help="sampling temperature; default's 1.0")
    parser.add_argument("--top-p", type=float, default=1.0, help="top-p in nucleus sampling; default's 1.0")
    parser.add_argument("--openai-model", type=str, default="gpt-3.5-turbo", help="openAI model; default's gpt-3.5-turbo")    
    parser.add_argument("-i", "--template-idx", type=int, default=1, help="template index; default's 1")

    args = parser.parse_args()

    translator = OpenAITranslator(
        source_lang=args.source_lang,
        target_lang=args.target_lang,
        openai_model=args.openai_model,
    )
    translator.setup_key()

    sources = [s.strip() for s in open(args.source, "r").readlines()]
    translations_l, total_tokens, prompt_tokens, n_failures = [], 0, 0, 0
    n_toolong, n_tooshort = 0, 0
    backup_file = open(args.output+'_backup', "w", encoding="utf-8")
    for text in tqdm(sources, desc="Translation...", dynamic_ncols=True):
        translations, token_count, prompt_count, failed_attempts = translator.translate(
            text,
            n_samples=args.n_samples,
            temperature=args.temperature,
            top_p=args.top_p,
            template_idx=args.template_idx,
            ts_prompt=True,
        )

        if args.template_idx != 5:
            for i in range(args.n_samples):
                translations_l.append(translations[i].replace('\n',''))
                backup_file.write(translations[i].replace('\n',''))
                backup_file.write('\n')

        if args.template_idx==5:
            # generate *5* translations at once (hardcoded)
            # only works for n_samples=1 for now
            all_translations = translations[0].split('\n')
            diff_len = 5 - len(all_translations)
            if diff_len < 0:
                all_translations = all_translations[0:5]
                n_toolong += 1
            else:
                all_translations = all_translations + [""] * diff_len
                if diff_len != 0:
                    n_tooshort += 1

            for i in range(len(all_translations)):
                translations_l.append(all_translations[i])
                backup_file.write(all_translations[i])
                backup_file.write('\n')

        total_tokens += token_count
        prompt_tokens += prompt_count
        n_failures += failed_attempts


    translations_l = [h.lstrip() for h in translations_l]
    with open(args.output, "w", encoding="utf-8") as outfile:
        outfile.write('\n'.join(translations_l))
    
    with open(args.output+'_extrainfo', "w", encoding="utf-8") as outfile:
        outfile.write(f"Total cost: {total_tokens*0.002/1000} \nPrompt cost: {prompt_tokens*0.002/1000} \nFailed attempts: {n_failures}")
        outfile.write(f"\nToo long: {n_toolong} \nToo short: {n_tooshort}")

    if args.openai_model == "gpt-3.5-turbo":
        print("Total translation cost in dollars:", total_tokens*0.002/1000)
        print("Prompt cost in dollars:", prompt_tokens*0.002/1000)

    
    print("Total number of failed attempts:", n_failures)
    print("Too long:", n_toolong)
    print("Too short:", n_tooshort)

if __name__ == "__main__":
    main()