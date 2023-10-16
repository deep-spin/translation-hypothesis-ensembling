main(){

    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=

    # baseline
    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
    do
        n_samples=1
        source_lang='English'
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


        source=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
        target=$repo_path/data/wmt22/references/$srcind-$tgtind.$ref_letter.txt
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/repeated
        source_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.src.repeated$n_samples
        target_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.$ref_letter.repeated$n_samples
        
        awk "{while(i++<$n_samples)print;i=0}" $source > $source_repeat
        awk "{while(i++<$n_samples)print;i=0}" $target > $target_repeat

        translations=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus
        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

        source $env_path/bin/activate
        python3 $repo_path/chatgpt/code/score-qe.py \
            $translations \
            $target_repeat \
            --src $source_repeat \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus \
            --no-comet-qe-xxl

        if [ $n_samples != 1 ]; then
            translations_mbr=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
            metrics_mbr=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
            metrics_mbr_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
            
            comet-mbr -s $source \
                -t $translations \
                --num_sample $n_samples \
                -o $translations_mbr

            python3 $repo_path/chatgpt/code/score-qe.py\
                $translations_mbr \
                $target \
                --src $source \
                --save-segment-level $metrics_mbr \
                --save-corpus-level $metrics_mbr_corpus \
                --no-comet-qe-xxl
        else
        echo "Single translation: not doing MBR" 
        fi
        
    done

    # translation hypothesis ensembling
    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
    do

        n_samples=50
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
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/repeated
        source_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.src.repeated$n_samples
        target_repeat=$repo_path/chatgpt/results/$srcind-$tgtind/repeated/$srcind-$tgtind.$ref_letter.repeated$n_samples
        
        awk "{while(i++<$n_samples)print;i=0}" $source > $source_repeat
        awk "{while(i++<$n_samples)print;i=0}" $target > $target_repeat

        translations=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment
        mkdir $repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus
        metrics=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature
        metrics_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature

        source $env_path/bin/activate
        python3 $repo_path/chatgpt/code/score-qe.py \
            $translations \
            $target_repeat \
            --src $source_repeat \
            --save-segment-level $metrics \
            --save-corpus-level $metrics_corpus \
            --no-comet-qe-xxl

        if [ $n_samples != 1 ]; then
            translations_mbr=$repo_path/chatgpt/results/$srcind-$tgtind/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
            metrics_mbr=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/segment/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
            metrics_mbr_corpus=$repo_path/chatgpt/results/$srcind-$tgtind/metrics/corpus/prompt$prompt-chatGPT-$srcind-$tgtind-n$n_samples-t$temperature-mbr
            
            comet-mbr -s $source \
                -t $translations \
                --num_sample $n_samples \
                -o $translations_mbr

            python3 $repo_path/chatgpt/code/score-qe.py\
                $translations_mbr \
                $target \
                --src $source \
                --save-segment-level $metrics_mbr \
                --save-corpus-level $metrics_mbr_corpus \
                --no-comet-qe-xxl
        else
        echo "Single translation: not doing MBR" 
        fi
        
    done
}

main