Red [
	Title: "Data Frequency Binning Function"
	author: "hinjolicious"
	purpose: {
		Group data into a number of bins and count the frequencies in each bins.
		Output: x-list: [...bins...] and y-list: [...frequencies...]
		or plot-output: [x1 y1 x2 y2 ... ] suitable for plotting in Red/Draw.
	}
]

min-of: func [s [series!] /local m] [m: first s  foreach v s [if v < m [m: v]]  m]
max-of: func [s [series!] /local m] [m: first s  foreach v s [if v > m [m: v]]  m]

freq-dist: func [
	data     [block!]  "The input list of numbers"
	num-bins [integer!] "The number of bins desired"
	/set-min smin
	/set-max smax
	/plot-output		"Returns [x1 y1 x2 y2...] suitable for plotting"
	return:  [block!]	"Returns [[x-list] [y-list]]"
	/local min-val max-val bin-size x-list y-list val bin-index
][
	;; 1. Find the range of the data dynamically
	min-val: either set-min [smin][min-of data]
	max-val: either set-max [smax][max-of data]
	
	;; Handle edge case where all numbers are identical
	if min-val = max-val [max-val: max-val + 1]
	
	;; Calculate the size of each bin
	bin-size: (max-val - min-val) / num-bins

	;; 2. Generate X List (the starting boundary of each bin)
	x-list: collect [
		repeat i num-bins [
			keep (min-val + ((i - 1) * bin-size))
		]
	]

	;; 3. Initialize Y List (frequencies set to 0)
	y-list: copy/deep append/dup clear [] 0 num-bins

	;; 4. Populate Frequencies
	foreach val data [
		;; Determine 1-indexed bin location
		bin-index: to integer! ((val - min-val) / bin-size) + 1
		
		;; Ensure data points exactly on max-val don't overflow the block boundary
		if bin-index > num-bins [bin-index: num-bins]
		if bin-index < 1 [bin-index: 1]
		
		;; Increment frequency
		poke y-list bin-index ((pick y-list bin-index) + 1)
	]

	;; 5. Return both lists nested in a single block
	either plot-output [ ; plot ready output
		collect [repeat i length? x-list [
			keep x-list/:i  keep y-list/:i
		]]
	][ ; separate x and y lists
		reduce [x-list y-list]
	]	
]

comment {
num-gen: function [min max num][
	random/seed now/time/precise
	collect [ loop num [ keep min + random (max - min) ]]
]

dat: freq-dist/set-min/set-max (num-gen 0.0 1.0 1000) 20 0.0 1.0
print mold dat/1
print mold dat/2 
}