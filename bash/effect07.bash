#	Image Effect 
#	Espoo, Finland, August 2012 
#	Petri Leskinen, petri.leskinen@aalto.fi

#	Locations of input and output images:
infile=$1 
outfile=$2 


convert $infile \
	-auto-level \
	-selective-blur "5x2+4%" -selective-blur "5x2+4%" \
	-unsharp "100x20+2.0+0.05" \
	$outfile


	


