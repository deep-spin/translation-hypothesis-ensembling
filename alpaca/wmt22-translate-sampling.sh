main(){

    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=
    # specify path to HF alpaca
    model_path=

    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian' 
    do
        source_lang='English'
        n_samples=20
        temperature=0.8
        top_p=0.95
        prompt=1
        beam=1
        batch_size=1

        if [ $source_lang == 'English' ]; then
            srcind="en"
        elif [ $source_lang == 'German' ]; then
            srcind="de"
        elif [ $source_lang == 'Russian' ]; then
            srcind="ru"
        elif [ $source_lang == 'Czech' ]; then
            srcind="cs"
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
        elif [ $target_lang == 'Japanese' ]; then
            tgtind="ja" 
        elif [ $target_lang == 'Ukrainian' ]; then
            tgtind="uk"   
        else
        echo "Tgt language is not supported" 
        fi

        source_file=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
        mkdir $repo_path/alpaca/results/
        output_file_dir=$repo_path/alpaca/results/$srcind-$tgtind
        mkdir $output_file_dir
        output_file=$output_file_dir/prompt$prompt-t$temperature-topp$top_p-beam$beam-n$n_samples

        source $env_path/bin/activate
        python $repo_path/alpaca/translate-sampling.py \
            --model-path $model_path \
            --source-file $source_file \
            --output-file $output_file \
            --source-lang=$source_lang \
            --target-lang=$target_lang \
            --n-samples=$n_samples \
            --batch-size $batch_size \
            --beam $beam \
            --temperature=$temperature \
            --top_p $top_p \
    done

}

main