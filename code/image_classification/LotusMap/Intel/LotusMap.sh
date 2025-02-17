# !/bin/bash

program_path_prefix="code/image_classification/LotusMap/Intel"
python_path=$(which python)
programs=("Loader.py" "Normalize.py" "RandomHorizontalFlip.py" "RandomResizedCrop.py" "ToTensor.py" "Collation.py")
vtune_record="vtune -collect hotspots -start-paused"
vtune_report="vtune -report hotspots"
vtune_result_dir="code/image_classification/LotusMap/Intel/tmp_vtune_result_dir"
csv_dir="code/image_classification/LotusMap/Intel/logs"

# check if all the above directories exist
if [ ! -d "$program_path_prefix" ]; then
    echo "Program path prefix does not exist"
    exit 1
fi

if [ ! -d "$csv_dir" ]; then
    echo "CSV directory does not exist"
    exit 1
fi

for program_ in "${programs[@]}"
do
    program=$program_path_prefix/$program_
    if [ ! -f "$program" ]; then
        echo "$program does not exist"
        exit 1
    fi
done


# Running multiple times and taking "AND" operation of the reported function
total_runs=20

for run in $(seq 1 $total_runs)
do
    for program_ in "${programs[@]}"
    do
        program=$program_path_prefix/$program_
        # remove .py from program_
        result_dir=$csv_dir/${program_::-3}
        # check if result_dir exists
        if [ ! -d "$result_dir" ]; then
            mkdir $result_dir
        fi
        csv_file=$result_dir/$run.csv
        echo "Running $program for run $run"
        $vtune_record -result-dir $vtune_result_dir -- $python_path $program
        $vtune_report -result-dir $vtune_result_dir -format csv -csv-delimiter comma -report-output $csv_file
        rm -rf $vtune_result_dir
    done
done
echo "Done running all programs"