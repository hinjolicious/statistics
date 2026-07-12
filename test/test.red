Red []

#include %../../functional/fp.red
#include %../stats.red
#include %../freq-dist.red
;#include %../../support/misc.red

data: [22 86 24 97 66 42 25 70 54 3 54 45 2 95 95 77 62 13 7 4 37 31 85 85 78 93 27 23 91 90 5 3 76 89 54 41 89 55 3 4 1 5 40 13 50 2 100 7 94 71 95 83 37 84 74 43 58 48 25 11 72 4 34 83 69 95 35 83 26 71 61 29 99 20 58 56 1 80 22 77 84 84 1 62 73 73 28 34 35 42 94 6 33 22 52 49 14 59 24 87]

; Descriptive Stats
; https://www.calculatorsoup.com/calculators/statistics/descriptivestatistics.php

data |> [juxt-map it [
	'Mean	[|> [mean it] --> m]
	'Min	minimum
	'Max	maximum
	'Range	range
	'Size	count
	'Sum	sum
	'Median median
	'Modes	modes 
	
	'StdDev		[stddev/sm it m]
	'StdDev-pop [stddev/sm/pop it m]
	
	'Variance 		[variance/sm it m]
	'Variance-pop 	[variance/sm/pop it m]
	
	'Mid-Range 		mid-range 
	'Q1 			q1
	'Q2 			q2
	'Q3 			q3
	'IQR 			iqr
	'Upper-Outliers upper-outliers
	'Lower-Outliers lower-outliers
	'Sum-Square 	sum-square
	'MAD 			mad
	'RMS 			rms
	'SE-Mean 		se-mean
	
	'Median-Skewness 		[median-skewness/sm it m]
	
	'Skewness				[skewness/sm it m]
	'Skewness-pop 			[skewness/pop/sm it m]
	'Kurtosis 				[kurtosis/sm it m]
	'Kurtosis-pop 			[kurtosis/pop/sm it m]
	'Kurtosis-excess 		[kurtosis/excess/sm it m]
	'Kurtosis-excess-pop 	[kurtosis/excess/pop/sm it m]
	
	'CV 			coeff-var
	'RSD 			rel-stddev
	'Gini 			gini
	'Freq-Dist 		[freq-dist it 10]
	'Top-10-Freq	[top-freq it 10]
	]]
	|> [ foreach [i j] it [print [i mold j]] ]

