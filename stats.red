Red [
	title: "Statistics for Red"
	author: "hinjolicious"
]

;#include %../fp.red
;#include %misc.red

minimum: function [x [series!]] [ v: first x  forall x [v: min v x/1] ]
maximum: function [x [series!]] [ v: first x  forall x [v: max v x/1] ]
; R
range:   function [x [series!]] [ (maximum x) - (minimum x) ]
; n
count: :length?		; count of items (built-in!)
;sum ; native
; x-
mean:  :average 	; mean (built-in!)

; x~ middle value when sorted
median: function [xx [series!]] [ 
	x: sort copy xx
	n: count xx
	either odd? n [ 
		x/((n + 1) / 2)
	][
		( x/(n / 2)  +  x/((n / 2) + 1) ) / 2 
	]
]

mode: function [xx [series!]] [
	x: sort copy xx
	v: first x  
	c: 1
	last-v: v  
	last-c: 0
	foreach xi next x [
		either xi = v [ 
			c: c + 1
		][ 
			if c > last-c [ last-c: c  last-v: v ]
			v: xi  
			c: 1
		]
	]
	either c > last-c [v][last-v]
]

modes: function [xx [series!]] [
	x: sort copy xx
	v: first x  
	c: 1
	last-v: v  
	last-c: 0
	mm: copy []
	
	foreach xi next x [
		either xi = v [
			c: c + 1
		][ 
			either c > last-c [ 
				last-c: c  
				clear mm
				append mm v
			][
				if c = last-c [ append mm v ]
			]
			v: xi
			c: 1
		]
	]
	either c > last-c [
		mm: reduce [v]
	][
		if c = last-c [append mm v]
	]
	mm
]

; s, sigma, standard deviation
stddev: function [x [series!] /pop /sm m0 [number!]] [
; /pop			population
; /set-mean		set mean to m0
	m: either sm [m0] [mean x]
	sqrt variance/sm/:pop x m
]

; s2, sigma2
variance: function [x [series!] /pop /sm m0 [number!]] [
; /pop			do population mean instead of sample
; /set-mean 	set mean to m0
	m: either sm [m0][mean x]
	( sx: 0  foreach xi x [ sx: sx + ((xi - m) ** 2)] ) / ( (count x) - either pop [0][1] )
]

; MR
mid-range: function [x [series!]] [ ((minimum x) + (maximum x)) / 2]

percentile: function [xx [series!] p [number!]] [
	x: sort copy xx ; x/1 ... x/n
	n: count x
	r: (p / 100 * (n - 1)) + 1 ; rank
	either integer? r [
		pct: x/r
	][	
		ri: to-integer r
		rf: r - ri
		r2: ri + 1
		pct: x/:ri + ( (x/:r2 - x/:ri) * rf )
	]
	pct
]

quantile: function [x [series!] q [number!]] [
; q between 0 and 1 (e.g. 0.25, 0.5, 0.75)
;That’s the “continuous” definition of quantiles — very standard in R, NumPy (default method="linear"), etc.
    percentile x (q * 100)
]

; Q1, Q2, Q3 shortcuts
q1: function [x [series!]] [quantile x 0.25]
q2: function [x [series!]] [quantile x 0.50]; same as median
q3: function [x [series!]] [quantile x 0.75]

; IQR, quantile data 0.9  ; 90th percentile
iqr: function [x [series!]] [ (q3 x) - (q1 x) ]

lower-outliers: function [x [series!]] [ (q1 x) - (1.5 * iqr x) ]
upper-outliers: function [x [series!]] [ (q3 x) + (1.5 * iqr x) ]

; SS
sum-square: function [x [series!]] [ 
	m: mean x
	s: 0 foreach xi x [s: s + ((xi - m) ** 2)]
]

; MAD
mad: function [x [series!]] [ 
	m: mean x
	(s: 0  foreach xi x [s: s + (absolute (xi - m))]) / count x
]

; RMS
rms: function [x [series!]] [ 
	sqrt (s: 0  foreach xi x [s: s + (xi ** 2)])
]

; SEx-
se-mean: function [x [series!]] [ (stddev x) / sqrt count x ]

;== SKEWNESS ==

median-skewness: function [x [series!] /sm m0[number!]] [
; Pearson's median skewness (Bowley/Yule-Kendall)
; (3 * (mean - median)) / std
; Pro: Easy, more robust to outliers
; Cons: Cruder, less "moment" information
; Often used in exploratory data analysis or when median is more stable than mean.
; 3(x - median) / sd
	m: either sm [m0] [mean x]
	3 * (m - (median x)) / (stddev/sm x m)
]

; Y1 Skewness
skewness: function [x [series!] /pop /sm m0 [number!]] [
; moment skewness
; SAMPLE skewness in calculatorsoup
	n: count x
	m: either sm [m0] [mean x]
	sd: stddev/sm x m
	if sd = 0 [return 0.0]
	
	either pop [ ; population
		(s: 0  foreach xi x [ s: s + ((xi - m) ** 3) ]) 
			/ (n * (sd ** 3))
	][ ; sample
		n / ((n - 1) * (n - 2)) 
			* ( s: 0  foreach xi x [ s: s + (((xi - m) / sd) ** 3) ] )
	]
]

; == KURTOSIS ==

kurtosis: function [x [series!] /excess /pop /sm m0 [number!]] [ 
; kurtosis for sample (calculatorsoup)
	n: count x 
	m: either sm [m0] [mean x]
	sd: stddev/sm x m
	if sd = 0 [return 0.0]

	either excess [ ; kurtosis excess (alpha4) - in Excell / Sheets
		( n * (n + 1)) 
			/ ((n - 1) * (n - 2) * (n - 3)) 
			* ( s: 0  foreach xi x [ s: s + (((xi - m) / sd) ** 4) ] )
			- ( (3 * ((n - 1) ** 2)) / ((n - 2) * (n - 3)) )
			- either pop [3][0] ; minus 3 for population
	][ ; kurtosis (beta2)
		either pop [ ; population
			1 / n * ( s: 0  foreach xi x [ s: s + (((xi - m) / sd) ** 4) ] )
		][ ; sample
			( n * (n + 1)) 
				/ ((n - 1) * (n - 2) * (n - 3)) 
				* ( s: 0  foreach xi x [ s: s + (((xi - m) / sd) ** 4) ] )
		]
	]
]

; CV
coeff-var:  function [x [series!]] [ (stddev x) / (mean x) ]
; RSD
rel-stddev: function [x [series!]] [ absolute (100 * (stddev x) / (mean x)) ]

gini: function [xx [series!]] [
; standard "relative mean difference" / lorenz curve definition of gini coeff
; calc
; G=n⋅∑i=1n​xi​2∑i=1n​i⋅xi​​−nn+1​
    x: sort copy xx
    n: count x
    s: sum x
    if zero? s [return 0.0]   ; all zero case
    g: 0
    i: 1
    foreach xi x [
        g: g + (i * xi)
        i: i + 1
    ]
    (2 * g) / (n * s) - ((n + 1) / n)
]

top-freq: function [xx [series!] nn [number!]] [
; top-n list with frequencies
	x: sort copy xx
	n: count x
	top: min (min 10 nn) n ; max 10 or nn or n
	v: first x  
	c: 1
	frq: copy []
	foreach xi next x [
		either xi = v [ ; same val, count it
			c: c + 1
		][ ; val changed
			insert/only frq reduce [v c] 
			sort/compare frq func [a b][a/2 > b/2] ; sort it by its count, reversed
			if (length? frq) > top [ 
				take/last frq ; remove the last one
			]
			v: xi
			c: 1
		]
	]
	insert/only frq reduce [v c]
	sort/compare frq func [a b][a/2 > b/2]
	if (length? frq) > top [
		take/last frq
	]
	frq
]

moving-average: function [series [series!] window [integer!]] [
	collect [ repeat i (length? series) - window + 1 [
		slice: copy/part at series i window
		keep average slice
	]]
]
