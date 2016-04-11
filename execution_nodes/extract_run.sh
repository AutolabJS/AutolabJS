mkdir -p submissions
cd submissions
mkdir -p $1
cd $1
git clone git@Lenovo-Y50-70:lab_author/lab$2.git
cd lab$2
git clone git@Lenovo-Y50-70:$1/lab$2.git
mv lab$2 student_solution
sh execute.sh
