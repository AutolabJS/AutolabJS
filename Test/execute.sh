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
    timeout -k 0.5 $timelimit java Driver >> ../scores.txt
    status=$(echo $?)
    if [ $status -ne 0 ];
    then
      echo "0" >> ../scores.txt
    fi
  else
    echo "0" >> ../scores.txt
  fi
  rm -rf *
  cd ..
done < $filename
cat scores.txt
rm scores.txt
