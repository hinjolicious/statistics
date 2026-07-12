Red []

#include %../stats.red
#include %../freq-dist.red
#include %../../plotter/plotter.red
#include %../../plotter/nice-range.red
#include %../../plotter/nice-bands.red

list: reduce [
	number-gen 0.0 1.0 100  
	number-gen 0.0 1.0 1000  
	number-gen 0.0 1.0 10000
	number-gen 0.0 1.0 100000
	number-gen 0.0 1.0 1000000
	;number-gen 0.0 1.0 10000000
]

print "Random Number Test"	
print [pad "Items" 10 pad "Mean" 20 pad "StdDev" 20]
foreach nums list [
	print [pad count nums 10 pad mean nums 20 pad stddev nums 20]
]

; visualize 

foreach nums list [
	tab: freq-dist/plot-output/set-min/set-max nums 25 0.0 1.0 

	demo-data: compose/deep [ [[histogram "Random numbers" sky dot 0.7 fit red 2] [(tab)]] ]

	; 2. (Optional) Inherit or change properties on the fly
	chart-engine: make PLOTTER [
		plot-config/margin: 50x40 ; Alter padding just for this module instance
	]

	view compose/deep [
		title "Random Number Test"
		canvas: base 600x400 white 
		do [
			canvas/draw: chart-engine/plot/title/x-label/y-label ;/x-range
				600x400 
				demo-data 
				(rejoin ["Random Number - " length? nums " items"])
				"Sample" 
				"Frequency"
				;[-0.05 1.0]
		]
	]
]
