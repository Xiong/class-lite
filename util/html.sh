#! /bin/sh

# This script invokes pod2cpanhtml to generate HTML from POD. 
# This is done so the rendering can be checked by eye. 

mkdir -p html/Class/
pod2cpanhtml lib/Class/Lite.pm html/Class/Lite.html

exit 0
