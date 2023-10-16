main(){

    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=
    
    # baseline
    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian' 
    do
        source_lang='English'
        n_samples=1
        temperature=0.1
        prompt=1

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

        source=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
        mkdir $repo_path/chatgpt/results
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/
        output=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

        source $env_path/bin/activate
        python $repo_path/chatgpt/code/translate.py \
            --source $source \
            --output $output \
            --source-lang=$source_lang \
            --target-lang=$target_lang \
            --n-samples=$n_samples \
            --temperature=$temperature \
            --template-idx=$prompt
    done

    # translation hypothesis ensembling
    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian' 
    do
        source_lang='English'
        n_samples=50
        temperature=1.0
        prompt=1

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

        source=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
        mkdir $repo_path/chatgpt/results
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/
        output=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

        source $env_path/bin/activate
        python $repo_path/chatgpt/code/translate.py \
            --source $source \
            --output $output \
            --source-lang=$source_lang \
            --target-lang=$target_lang \
            --n-samples=$n_samples \
            --temperature=$temperature \
            --template-idx=$prompt
    done


}

main