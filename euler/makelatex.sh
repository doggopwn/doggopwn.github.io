#!/bin/bash
#
bash ./symlinkstyles.sh
problemdirs=()
for dir in ./*/; do
        if [ "$dir" = "./js/" ]; then continue; fi
		if [ ! -f "$dir/solution.tex" ]; then continue; fi
        problemdirs+=($(basename "$dir"))
done
echo "Found ${#problemdirs[@]} problem directories with latex files - $(printf '%s, ' ${problemdirs[@]})"

echo "Untarring minitex.."
tar xzvf minitex.tar.gz >/dev/null
rm minitex.tar.gz

echo "Compiling latex files.."

failed=0
chmod +x ./minitex/bin/x86_64-linux/pdflatex
for problem in "${problemdirs[@]}"; do
	cd $problem
	../minitex/bin/x86_64-linux/pdflatex ./solution.tex 2>&1 >/dev/null
	if [[ $? -eq 0 ]]; then
		echo "Successfully generated $problem/solution.pdf"
		rm ./solution.aux
		rm ./solution.log
	else
		echo "Failed to generate $problem/solution.pdf"
		failed=1
	fi
	cd - >/dev/null
done

rm -rf ./minitex

if [[ "$failed" -eq "1" ]]; then
	exit 1
fi
