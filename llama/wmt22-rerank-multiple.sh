main(){

    # specify path to repo
    repo_path=
    # specity path to your env
    env_path=

    # translation hypothesis ensembling
    for target_lang in 'German' 'Russian' 'Czech' 'Ukrainian'
    do

        source_lang='English'
        model_size='7B'
        prompt=1
        temperature=0.8
        top_p=0.95
        n_samples=50
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

        source_file=$repo_path/data/wmt22/sources/$srcind-$tgtind.txt
        target_file=$repo_path/data/wmt22/references/$srcind-$tgtind.$ref_letter.txt
        output_file_dir=$repo_path/llama/results/$srcind-$tgtind/translations
        source_repeat=$output_file_dir/repeated/$srcind-$tgtind.src.repeated$n_samples
        target_repeat=$output_file_dir/repeated/$srcind-$tgtind.$ref_letter.repeated$n_samples

        translations_file=$output_file_dir/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-translations
        
        metrics_dir=$repo_path/llama/results/$srcind-$tgtind/metrics
        metrics_corpus=$metrics_dir/corpus/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples
        metrics_segment=$metrics_dir/segment/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples


        mkdir $output_file_dir/rerank-cometkiwi
        mkdir $output_file_dir/rerank-cometoracle
        mkdir $output_file_dir/rerank-singleprediction

        best_cometkiwi=$output_file_dir/rerank-cometkiwi/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples
        best_cometoracle=$output_file_dir/rerank-cometoracle/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples
        single_pred=$output_file_dir/rerank-singleprediction/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples

        source $env_path/bin/activate

        python3 rerank.py \
            $translations_file \
            $metrics_segment \
            $n_samples \
            --save-cometkiwi $best_cometkiwi \
            --save-cometoracle $best_cometoracle \
            --save-singleprediction $single_pred
            #--save-cometkiwixxl $best_cometkiwixxl \

        metrics_corpus_cometkiwi=$metrics_dir/corpus/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-cometkiwi
        metrics_segment_cometkiwi=$metrics_dir/segment/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-cometkiwi
        metrics_corpus_cometoracle=$metrics_dir/corpus/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-cometoracle
        metrics_segment_cometoracle=$metrics_dir/segment/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-cometoracle
        metrics_corpus_singlepred=$metrics_dir/corpus/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-singlepred
        metrics_segment_singlepred=$metrics_dir/segment/prompt$prompt-$model_size-temp$temperature-topp$top_p-n$n_samples-singlepred

        python3 $repo_path/chatgpt/code/score-qe.py \
            $best_cometkiwi \
            $target_file \
            --src $source_file \
            --save-segment-level $metrics_segment_cometkiwi\
            --save-corpus-level $metrics_corpus_cometkiwi \
            --no-comet-qe-xxl

        python3 $repo_path/chatgpt/code/score-qe.py \
            $best_cometoracle \
            $target_file \
            --src $source_file \
            --save-segment-level $metrics_segment_cometoracle \
            --save-corpus-level $metrics_corpus_cometoracle \
            --no-comet-qe-xxl

        python3 $repo_path/chatgpt/code/score-qe.py \
            $single_pred \
            $target_file \
            --src $source_file \
            --save-segment-level $metrics_segment_singlepred \
            --save-corpus-level $metrics_corpus_singlepred \
            --no-comet-qe-xxl

    done

}

main