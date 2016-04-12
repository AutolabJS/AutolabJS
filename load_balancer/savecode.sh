mkdir -p submissions
cd submissions
mkdir -p lab$2
cd lab$2
mkdir -p $1
cd $1
rm -rf *
git clone git@Lenovo-Y50-70:$1/lab$2.git
