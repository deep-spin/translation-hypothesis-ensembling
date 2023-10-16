main(){

    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=
    # bleurt
    bleurt_env= # insert bleurt env
    bleurt_dir= # insert bleurt dir
    
    for source_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
    do
        target_lang='English'
        n_samples=1
        temperature=0.1
        prompt=1
        ref_letter='refA'

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


        target=$repo_path/data/wmt22/references/$srcind-$tgtind.$ref_letter.txt
        target_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.$ref_letter.repeated$n_samples

        translations=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/segment
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/corpus
        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

        source $bleurt_env/bin/activate
        python3 $repo_path/chatgpt/code/score-bleurt.py \
            $translations \
            $target_repeat \
            --bleurt-dir $bleurt_dir \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus


        n_samples=50
        temperature=1.0

        best_cometkiwi=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometkiwi/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        best_cometoracle=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometoracle/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        single_pred=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-singleprediction/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        translations_mbr=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr

        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-singlepred
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-singlepred
        python3 $repo_path/chatgpt/code/score-bleurt.py \
            $single_pred \
            $target_repeat \
            --bleurt-dir $bleurt_dir \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus

        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
        python3 $repo_path/chatgpt/code/score-bleurt.py \
            $translations_mbr \
            $target_repeat \
            --bleurt-dir $bleurt_dir \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus

        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometkiwi
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometkiwi
        python3 $repo_path/chatgpt/code/score-bleurt.py \
            $best_cometkiwi \
            $target_repeat \
            --bleurt-dir $bleurt_dir \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus

        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometoracle
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/bleurt/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometoracle
        python3 $repo_path/chatgpt/code/score-bleurt.py \
            $best_cometoracle \
            $target_repeat \
            --bleurt-dir $bleurt_dir \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus
    done

}

main