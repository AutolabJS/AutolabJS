unset JAVA_TOOL_OPTIONS
marks=()
filename="info_file.txt"
while read -r line
do
  case_details=$line
  testcase=$(echo "$case_details" | awk '{print $1}')
  classname=$(echo "$case_details" | awk '{print $2}')
  timelimit=$(echo "$case_details" | awk '{print $3}')
  # echo $testcase
  # echo $classname
  # echo $timelimit
  cp -a ./author_solution/. ./working_dir/
  rm -rf ./working_dir/$classname
  cp -a ./student_solution/$classname ./working_dir
  cp ./test_cases/$testcase ./working_dir
  cp Driver.java ./working_dir
  cd working_dir
  javac -nowarn *.java 2>> log.txt
  cat log.txt >> ../log.txt
  errors=$(wc -l log.txt | awk '{print $1}')
  if [ $errors -eq 0 ];
  then
    # timeout -k 0.5 $timelimit java Driver >> ../scores.txt
    timeout -k 0.5 $timelimit java Driver >> abc.txt
    sc=$(tail -n1 abc.txt)
    status=$(echo $?)
    if [ $status -ne 0 ];
    then
      # echo "0" >> ../scores.txt
      sc="0"
    fi
  else
    # echo "0" >> ../scores.txt
    sc="0"
  fi
  rm -rf *
  # echo $sc >> ../scores.txt
  marks+=($sc)
  cd ..
done < $filename
rm scores.txt
for each in "${marks[@]}"
do
  echo "$each" >> scores.txt
done
