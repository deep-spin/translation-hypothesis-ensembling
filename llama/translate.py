# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the GNU General Public License version 3.

from typing import Tuple
import os
import sys
import torch
import fire
import time
import json

from pathlib import Path

from fairscale.nn.model_parallel.initialize import initialize_model_parallel

from llama import ModelArgs, Transformer, Tokenizer, LLaMA


def setup_model_parallel() -> Tuple[int, int]:
    local_rank = int(os.environ.get("LOCAL_RANK", -1))
    world_size = int(os.environ.get("WORLD_SIZE", -1))

    torch.distributed.init_process_group("nccl")
    initialize_model_parallel(world_size)
    torch.cuda.set_device(local_rank)

    # seed must be the same in all processes
    torch.manual_seed(1)
    return local_rank, world_size


def load(
    ckpt_dir: str,
    tokenizer_path: str,
    local_rank: int,
    world_size: int,
    max_seq_len: int,
    max_batch_size: int,
) -> LLaMA:
    start_time = time.time()
    checkpoints = sorted(Path(ckpt_dir).glob("*.pth"))
    assert world_size == len(
        checkpoints
    ), f"Loading a checkpoint for MP={len(checkpoints)} but world size is {world_size}"
    ckpt_path = checkpoints[local_rank]
    print("Loading")
    checkpoint = torch.load(ckpt_path, map_location="cpu")
    with open(Path(ckpt_dir) / "params.json", "r") as f:
        params = json.loads(f.read())

    model_args: ModelArgs = ModelArgs(
        max_seq_len=max_seq_len, max_batch_size=max_batch_size, **params
    )
    tokenizer = Tokenizer(model_path=tokenizer_path)
    model_args.vocab_size = tokenizer.n_words
    torch.set_default_tensor_type(torch.cuda.HalfTensor)
    model = Transformer(model_args)
    torch.set_default_tensor_type(torch.FloatTensor)
    model.load_state_dict(checkpoint, strict=False)

    generator = LLaMA(model, tokenizer)
    print(f"Loaded in {time.time() - start_time:.2f} seconds")
    return generator


def main(
    ckpt_dir: str,
    tokenizer_path: str,
    source_file: str,
    output_file: str,
    source_lang: str,
    target_lang: str,
    temperature: float = 0.8,
    top_p: float = 0.95,
    max_seq_len: int = 512,
    max_batch_size: int = 32,
    n_samples: int = 1,
):
    local_rank, world_size = setup_model_parallel()
    if local_rank > 0:
        sys.stdout = open(os.devnull, "w")

    generator = load(
        ckpt_dir, tokenizer_path, local_rank, world_size, max_seq_len, max_batch_size
    )

    print('\ntemperature:', temperature)
    print('\nsource_file:', source_file)
    sources = [s.strip() for s in open(source_file, "r").readlines()]
    prompts = [f"Translate this sentence from {source_lang} to {target_lang}.\n{source_lang} Source: {source}\n{target_lang} Translation:" for source in sources]
    repeated_prompts = []
    for prompt in prompts:
        repeated_prompts += [prompt] * n_samples
    
    translations = []
    backup_file = open(output_file, "w", encoding="utf-8")
    backup_file_full = open(output_file+'-full', "w", encoding="utf-8")
    
    for i in range(0, len(repeated_prompts), max_batch_size):
        # Get the current batch of prompts
        batch_prompts = repeated_prompts[i:i+max_batch_size]
        # Generate responses for the current batch
        results = generator.generate(
            batch_prompts, max_gen_len=256, temperature=temperature, top_p=top_p
        )
        
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


if __name__ == "__main__":
    fire.Fire(main)
