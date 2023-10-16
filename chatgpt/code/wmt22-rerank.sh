main(){
    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=

    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
    do
        for n_samples in 50
        do
            source_lang='English'
            temperature=1.0
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

            source=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
            target=$repo_path/data/wmt22/references/$srcind-$tgtind.$ref_letter.txt
            source_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.src.repeated$n_samples
            target_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.$ref_letter.repeated$n_samples
            

            translations=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
            metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
            metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

            source $env_path/bin/activate

            mkdir $repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometkiwi
            mkdir $repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometoracle
            mkdir $repo_path/chatgpt/results/$srcind-$tgtind/rerank-singleprediction
            #mkdir $repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometkiwixxl

            best_cometkiwi=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometkiwi/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
            best_cometoracle=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometoracle/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
            single_pred=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-singleprediction/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
            #best_cometkiwixxl=$repo_path/chatgpt/results/$srcind-$tgtind/rerank-cometkiwixxl/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

            python3 $repo_path/chatgpt/code/rerank.py \
                $translations \
                $metrics \
                $n_samples \
                --save-cometkiwi $best_cometkiwi \
                --save-cometoracle $best_cometoracle \
                --save-singleprediction $single_pred
                #--save-cometkiwixxl $best_cometkiwixxl \

            metrics_cometkiwi=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometkiwi
            metrics_cometkiwi_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometkiwi
            metrics_cometoracle=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometoracle
            metrics_cometoracle_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometoracle
            metrics_singleprediction=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-singlepred
            metrics_singleprediction_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-singlepred
            #metrics_cometkiwixxl=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometkiwixxl
            #metrics_cometkiwixxl_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-cometkiwixxl

            python3 $repo_path/chatgpt/code/score-qe.py \
                $best_cometkiwi \
                $target \
                --src $source \
                --save-segment-level $metrics_cometkiwi \
                --save-corpus-level $metrics_cometkiwi_corpus \
                --no-comet-qe-xxl

            python3 $repo_path/chatgpt/code/score-qe.py \
                $best_cometoracle \
                $target \
                --src $source \
                --save-segment-level $metrics_cometoracle \
                --save-corpus-level $metrics_cometoracle_corpus \
                --no-comet-qe-xxl

            python3 $repo_path/chatgpt/code/score-qe.py \
                $single_pred \
                $target \
                --src $source \
                --save-segment-level $metrics_singleprediction \
                --save-corpus-level $metrics_singleprediction_corpus \
                --no-comet-qe-xxl

            #python3 $repo_path/chatgpt/code/score-qe.py \
            #    $best_cometkiwixxl \
            #    $target \
            #    --src $source \
            #    --save-segment-level $metrics_cometkiwixxl \
            #    --save-corpus-level $metrics_cometkiwixxl_corpus

        done
    done
}

main