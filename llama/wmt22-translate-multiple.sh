# specify path to repo
repo_path=
# specity path to your env
env_path=
# llama checkpoint dir path
ckpt_dir=

# translation hypothesis ensembling
for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
do
    source_lang='English'
    model_size='7B'
    prompt=1
    temperature=0.8
    top_p=0.95
    n_samples=50
    max_batch_size=100

    if [ $source_lang == 'English' ]; then
        srcind="en"
    elif [ $source_lang == 'German' ]; then
        srcind="de"
    elif [ $source_lang == 'Russian' ]; then
        srcind="ru"
    elif [ $source_lang == 'Czech' ]; then
        srcind="cs"
        ref_letter='refB' # for cs-en
    elif [ $source_lang == 'Japanese' ]; then
        srcind="ja"     
    elif [ $source_lang == 'Ukrainian' ]; then
        srcind="uk"     
    else
    echo "Src language is not supported" 
    fi
    if [ $target_lang == 'English' ]; then
        tgtind="en"
    elif [ $target_lang == 'German' ]; then
        tgtind="de"
    elif [ $target_lang == 'Russian' ]; then
        tgtind="ru"
    elif [ $target_lang == 'Czech' ]; then
        tgtind="cs"
        ref_letter='refB' # for en-cs
    elif [ $target_lang == 'Japanese' ]; then
        tgtind="ja" 
    elif [ $target_lang == 'Ukrainian' ]; then
        tgtind="uk"   
    else
    echo "Tgt language is not supported" 
    fi

    source_file=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
    mkdir $repo_path/llama/results/
    mkdir $repo_path/llama/results/$srcind-$tgtind/
    output_file_dir=$repo_path/llama/results/$srcind-$tgtind/translations
    mkdir $output_file_dir
    output_file=$output_file_dir/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples

    source $env_path/bin/activate
    torchrun --nproc_per_node 1 $repo_path/llama/translate.py \
        --ckpt_dir $ckpt_dir/llama/$model_size \
        --tokenizer_path $ckpt_dir/llama/tokenizer.model \
        --source_lang $source_lang \
        --target_lang $target_lang \
        --source_file $source_file \
        --output_file $output_file \
        --temperature $temperature \
        --top_p $top_p \
        --max_batch_size $max_batch_size \
        --n_samples $n_samples
done

# baseline
for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
do
    source_lang='English'
    model_size='7B'
    prompt=1
    temperature=0.0
    top_p=0.0
    n_samples=1
    max_batch_size=100

    if [ $source_lang == 'English' ]; then
        srcind="en"
    elif [ $source_lang == 'German' ]; then
        srcind="de"
    elif [ $source_lang == 'Russian' ]; then
        srcind="ru"
    elif [ $source_lang == 'Czech' ]; then
        srcind="cs"
        ref_letter='refB' # for cs-en
    elif [ $source_lang == 'Japanese' ]; then
        srcind="ja"     
    elif [ $source_lang == 'Ukrainian' ]; then
        srcind="uk"     
    else
    echo "Src language is not supported" 
    fi
    if [ $target_lang == 'English' ]; then
        tgtind="en"
    elif [ $target_lang == 'German' ]; then
        tgtind="de"
    elif [ $target_lang == 'Russian' ]; then
        tgtind="ru"
    elif [ $target_lang == 'Czech' ]; then
        tgtind="cs"
        ref_letter='refB' # for en-cs
    elif [ $target_lang == 'Japanese' ]; then
        tgtind="ja" 
    elif [ $target_lang == 'Ukrainian' ]; then
        tgtind="uk"   
    else
    echo "Tgt language is not supported" 
    fi

    source_file=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
    mkdir $repo_path/llama/results/
    mkdir $repo_path/llama/results/$srcind-$tgtind/
    output_file_dir=$repo_path/llama/results/$srcind-$tgtind/translations
    mkdir $output_file_dir
    output_file=$output_file_dir/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples

    source $env_path/bin/activate
    torchrun --nproc_per_node 1 $repo_path/llama/translate.py \
        --ckpt_dir $ckpt_dir/llama/$model_size \
        --tokenizer_path $ckpt_dir/llama/tokenizer.model \
        --source_lang $source_lang \
        --target_lang $target_lang \
        --source_file $source_file \
        --output_file $output_file \
        --temperature $temperature \
        --top_p $top_p \
        --max_batch_size $max_batch_size \
        --n_samples $n_samples
done