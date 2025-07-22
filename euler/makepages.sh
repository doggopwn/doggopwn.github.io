#!/bin/bash
## repl {task-number} with PE_number
## repl {task-name} with PE_name
## repl {task-html} with HTML source code
## repl {task-src} with PE url
## IF <!-- VAR --> exists, repl {src} with VAR ELSE delete line

problemdirs=()
# Fetch data for all existing subdirectory problems
for dir in ./*/; do
	if [ "$dir" = "./js/" ]; then continue; fi
	problemdirs+=($(basename "$dir"))
done
echo "Found ${#problemdirs[@]} problem directories - $(printf '%s, ' ${problemdirs[@]})"

problems=$(printf '%s\n' "${problemdirs[@]}" | sort -n)


TMP=$(mktemp -d)
curl -s -o $TMP/problems 'https://projecteuler.net/minimal=problems'
readarray -t names < <(awk -F'##' -v nums_str="$problems" '
BEGIN {
	split(nums_str, nums, "\n")
	for (i=0; i<length(nums); i++){
		targets[nums[i]] = 1
	}
}
$1 in targets {
	print $2
}
' "$TMP/problems")

echo "Fetched ${#names[@]} problem names"

# for ./index file
indexcontent=""

i=0
for problem in ${problemdirs[@]}; do
	PE_number=$problem
	PE_name=${names[$i]}
	PE_src="https://projecteuler.net/problem=$PE_number"
	
	prefix="Generating pages for $PE_number - $PE_name"

	echo -ne "$prefix: downloading task HTML\r"
	curl -s -o "$TMP/$PE_number.task.html" "https://projecteuler.net/minimal=$PE_number"

	echo -ne "$prefix: checking subfiles\r"
	files=()
	filetypes=(pdf js c asm)
	for filetype in ${filetypes[@]}; do
		if [ -f "./$PE_number/solution.$filetype" ]; then
			files+=("solution.$filetype")
		else 
			files+=("null")
		fi
	done

	echo -ne "$prefix: generating index.html\r"
	PE_HTML_src="$(<$TMP/$PE_number.task.html)" awk -v files="$(printf '%s\n' "${files[@]}")" -v num="$PE_number" -v url="$PE_src" -v name="$PE_name" '
	BEGIN {
		replacements["{task-number}"] = num
		replacements["{task-name}"] = name
		replacements["{task-src}"] = url

		replacements["{task-html}"] = ENVIRON["PE_HTML_src"]
		gsub(/&/, "\\\\&", replacements["{task-html}"]) # escape ampersands as valid HTML - not regex lookback

		split(files, file_array, "\n")
	}
match($0, /<!-- ([0-9]+) (.*)-->/, m){
		idx = m[1]
		html_inner = m[2]
		if (idx in file_array && file_array[idx] != "null"){
			gsub(/{src}/, file_array[idx], html_inner);
			print html_inner;
		}
		next
	}
	{
		for (r in replacements){
			gsub(r, replacements[r])
		}
		
		print $0
	}' ./template.html > ./$PE_number/index.html

	echo "$prefix: generated ./$PE_number/index.html";
	
	indexcontent+="$(echo -e "$PE_number\x1f$PE_name")\n"

	i=$i+1
done

printf "$indexcontent" > ./index

echo "Generated index file at ./index"

rm -rf $TMP
