#!/bin/bash
#STYLES=(${(f)"$(find . -type f -name '*.sty')"})
#TEXFILES=(${(f)"$(find . -type f -name '*.tex')"})

donedir=()
for texfile in ./**/*.tex; do
	TEXDIR=$(dirname $texfile)
	for style in ./*.sty; do
		if [[ -L $TEXDIR/$(basename $style) ]]; then continue; fi
		ln -s $(readlink -f $style) $TEXDIR
	done	
	donedir+=($TEXDIR)
done
