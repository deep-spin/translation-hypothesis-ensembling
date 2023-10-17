main(){

    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=

    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
    do

        source_lang='English'
        n_samples=20
        temperature=0.8
        top_p=0.95
        prompt=1
        beam=1
        ref_letter=refA

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
        target_file=$repo_path/data/wmt22/references/$srcind-$tgtind.$ref_letter.txt
        output_file_dir=$repo_path/alpaca/results/$srcind-$tgtind
        mkdir $output_file_dir/repeated
        output_file=$output_file_dir/prompt$prompt-t$temperature-topp$top_p-beam$beam-n$n_samples


        source_repeat=$output_file_dir/repeated/$srcind-$tgtind.src.repeated$n_samples
        target_repeat=$output_file_dir/repeated/$srcind-$tgtind.$ref_letter.repeated$n_samples
        awk "{while(i++<$n_samples)print;i=0}" $source_file > $source_repeat
        awk "{while(i++<$n_samples)print;i=0}" $target_file > $target_repeat

        translations_original=$output_file_dir/prompt$prompt-t$temperature-topp$top_p-beam$beam-n$n_samples
        translations_processed=$translations_original-processed
        sed "s/$target_lang Translation://" $translations_original > $translations_processed # remove first part from the prompt
        sed "s/^[ \t]*//" -i $translations_processed # remove whitespace in the begining

        metrics_dir=$repo_path/alpaca/results/$srcind-$tgtind/metrics
        mkdir $metrics_dir
        mkdir $metrics_dir/corpus
        mkdir $metrics_dir/segment
        metrics_corpus=$metrics_dir/corpus/prompt$prompt-t$temperature-topp$top_p-beam$beam-n$n_samples
        metrics_segment=$metrics_dir/segment/prompt$prompt-t$temperature-topp$top_p-beam$beam-n$n_samples

        source $env_path/bin/activate
        python3 $repo_path/chatgpt/code/score-qe.py \
            $translations_processed \
            $target_repeat \
            --src $source_repeat \
            --save-segment-level $metrics_segment \
            --save-corpus-level $metrics_corpus \
            --no-comet-qe-xxl

        if [ $n_samples != 1 ]; then
            translations_mbr=$translations_original-mbr
            metrics_mbr_corpus=$metrics_corpus-mbr
            metrics_mbr_segment=$metrics_segment-mbr
            
            comet-mbr -s $source_file \
                -t $translations_processed \
                --num_sample $n_samples \
                -o $translations_mbr

            python3 $repo_path/chatgpt/code/score-qe.py \
                $translations_mbr \
                $target_file \
                --src $source_file \
                --save-segment-level $metrics_mbr_segment \
                --save-corpus-level $metrics_mbr_corpus \
                --no-comet-qe-xxl
        else
        echo "Single translation: not doing MBR" 
        fi

    done


}

main