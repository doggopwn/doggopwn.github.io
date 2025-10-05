#!/bin/zsh

fontdirs=()
# Fetch data for all existing subdirectory problems
for dir in ./*/; do
	fontdirs+=($(basename "$dir"))
done
echo "Found ${#fontdirs[@]} font directories - $(printf '%s, ' ${fontdirs[@]})"



indexcontent=""
for font in ${fontdirs[@]}; do
	if [[ $font = "index.html" ]]; then continue; fi
	echo $font
	fontfiles=( ./$font/* )
	FONT_EXT=$(basename ${fontfiles[1]} | cut -d'.' -f2)
	FONT_WEIGHTS=()
	FONT_HTML_ELS=();
	for fontfile in ${fontfiles[@]}; do
		FONT_WEIGHTS+=$(basename $fontfile .$FONT_EXT)
		FONT_HTML_ELS+="<li><a href=\"$(basename $fontfile)\">$(basename $fontfile)</a></li>"
	done;
	echo "$font\x1f$FONT_EXT\x1f${(j:,:)FONT_WEIGHTS}" >> ./index

	cp ./template.html ./$font/index.html
	
	sed -i -e "s/{FONTNAME}/$font/g" -e "s!{FONTLIST}!${(j:\n:)FONT_HTML_ELS}!g" ./$font/index.html
done

echo "Generated index file at ./index"

cat ./index

