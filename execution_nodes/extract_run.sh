cd submissions/$1
unzip $1.zip -d . > /dev/null
unzip test_content.zip -d . > /dev/null
sh execute.sh
