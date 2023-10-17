import torch
import json
import argparse
import transformers
from typing import List, Union

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model_path", type=str, help="path for HF alpaca")
    parser.add_argument("-s", "--source-file", type=str, help="path to source file")
    parser.add_argument("-o", "--output-file", type=str, help="output file")
    parser.add_argument("--source-lang", type=str, help="source language")
    parser.add_argument("--target-lang", type=str, help="target language")
    parser.add_argument("-n", "--n-samples", type=int, default=1, help="number of samples; default's 1")
    parser.add_argument("--temperature", type=float, default=1.0, help="sampling temperature; default's 1.0")
    parser.add_argument("--top-p", type=float, default=1.0, help="top-p in nucleus sampling; default's 1.0")
    parser.add_argument("--beam", type=int, default=1, help="beam size, default's to 1")
    parser.add_argument("--batch-size", type=int, default=2, help="top-p in nucleus sampling; default's 1.0")
    args = parser.parse_args()

    tokenizer = transformers.AutoTokenizer.from_pretrained(args.model_path)
    model = transformers.AutoModelForCausalLM.from_pretrained(args.model_path).cuda()
    tokenizer.padding_side = "left"
    tokenizer.pad_token_id = 0

    max_batch_size = args.batch_size
    output_file = args.output_file

    sources = [s.strip() for s in open(args.source_file, "r").readlines()]
    prompts = [f"Translate this sentence from {args.source_lang} to {args.target_lang}.\n{args.source_lang} Source: {source}\n{args.target_lang} Translation:" for source in sources]

    generate_kwargs = {
        "max_new_tokens": 200,
        "do_sample": True,
        "num_beams": args.beam,
        "top_p": args.top_p,
        "temperature": args.temperature,
        "num_return_sequences": args.n_samples,
        "eos_token_id": tokenizer.eos_token_id,
        "pad_token_id": tokenizer.pad_token_id,
    }

    translations = []
    backup_file = open(output_file, "w", encoding="utf-8")
    backup_file_full = open(output_file+'-full', "w", encoding="utf-8")

    for i in range(0, len(prompts), max_batch_size):
        batch_prompts = prompts[i:i+max_batch_size]
        
        with torch.no_grad():
            batch = tokenizer(batch_prompts, padding=True, return_tensors="pt").to(0)
            generated_ids = model.generate(
                batch["input_ids"],
                **generate_kwargs
            )
            results = tokenizer.batch_decode(generated_ids.cpu(), skip_special_tokens=True)


        for result in results:
            print(result.split("\n")[0])
            print(result.split("\n")[1])
            print(result.split("\n")[2])
            print("\n==================================\n")
            translations.append(result.split("\n")[2]) # get continuation (hardcoded for this prompt)
            backup_file.write(result.split("\n")[2])
            backup_file.write('\n')
            backup_file_full.write(result.replace("\n","\\n"))
            backup_file_full.write('\n')



