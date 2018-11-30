breed [protesters1 protester1]
breed [protesters2 protester2]
breed [police policeman]

protesters1-own [
  xinit1
  dest1
  averse1a
  averse1
]
protesters2-own [
  xinit2
  dest2
  averse2a
  averse2
]
police-own [
  xinitp
  target
  destp
]

globals [
  totaltick
]

;; export a 30 frame movie of the view
extensions [vid]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;setup;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to setup

  clear-all
  setup-police
  setup-protesters1
  setup-protesters2
  setup-video
  set totaltick 0
  reset-ticks

end


to setup-video
vid:start-recorder
vid:record-view ;; show the initial state
repeat 30
[ go
  vid:record-view ]
vid:save-recording "out.mp4"
end

to setup-protesters1
  set-default-shape protesters1 "person"
  create-protesters1 num-protesters1
  [
    set color red
    set size 1
    ; 'random' only calls numbers from 0 to 'number'.
    ; Fiddle so that the number is 1 above police line.
    set xinit1 random (15 - (0.5 * police-width))
    setxy (xinit1 + (0.5 * police-width) + 1) random-ycor
    set dest1 patch -16 ycor
    set averse1 random-normal averse-mean1 (averse-mean1 - averse-mean1 / 2)
    ; set averse1a random-gamma 2 1 ; for left-skewed distribution (gamma is right-skewed)
    ;set averse1 -1 * averse1a + averse-mean1 ; for left-skewed distribution (mirror image of gamma)
    ; set averse1 averse1a ; for right-skewed (i.e. aggressive)
    if averse1 < 1
    [
    set averse1 averse-mean1
    ]
    ]
end
to setup-protesters2
  set-default-shape protesters2 "person"
  create-protesters2 num-protesters2
  [
    set color green
    set size 1
    ; 'random' only calls numbers from 0 to 'number'.
    ; Fiddle so that the number is 1 below police line.
    set xinit2 random ((0.5 * police-width) - 14)
    setxy (xinit2 - (0.5 * police-width) - 2) random-ycor
    set dest2 patch 16 ycor
    set averse2 random-normal averse-mean2 (averse-mean2 - averse-mean2 / 2)
    ;set averse2a random-gamma 2 1 ; for left-skewed distribution (gamma is right-skewed)
    ;set averse2 -1 * averse2a + averse-mean2 ; for left-skewed distribution (mirror image of gamma)
    ;set averse2 averse2a ; for right-skewed (i.e. aggressive)
    if averse2 < 1
    [
    set averse2 averse-mean2
    ]
    ]
end

to setup-police
   let vertical-spacing (world-height / 4)
   let min-ypos (min-pycor - 0.5 + vertical-spacing / 2)
   set-default-shape police "person police"
   create-police num-police
  [
    set color blue
    set size 1
    let row who / 4
    setxy 0 (min-ypos + row * vertical-spacing)
    set destp patch 0 (min-ypos + row * vertical-spacing)
    ; random police set up - commented out below
;    set xinitp random police-width ; random placements within thin blue line
;    setxy xinitp - (0.5 * police-width) random-ycor
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;go;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go

 ask police
 [
   police-step
 ]
 ask protesters1
 [
   protester1-step
 ]
 ask protesters2
 [
   protester2-step
 ]
 if totaltick > 5000 [
  ;file-open "protester1_states.txt" ; open file
  ;;ask protesters1 [file-write xcor] ; get and save data
  ;file-write count protesters1 with [xcor < 0]

  ;file-open "protester2_states.txt" ; open file
  ;;ask protesters2 [file-write xcor] ; get and save data
  ;file-write count protesters2 with [xcor > 0]

  file-open "averse_normal.txt" ; open file
  ask protesters1 [file-print averse1 file-print "\n"] ; get and save data
  ask protesters2 [file-print averse2 file-print "\n"] ; get and save data
  file-close-all

  ;file-close-all

    stop


  ] ; a tick doesn't exactly correspond to a time-unit, but with 100000 it takes on the order of 30 sec at normal speed
  set totaltick totaltick + 1 ; ticking along


end

to police-step
  ; ifelse random < 0 ; randomly choose whether to face protester1 or protester2, 50/50
  ifelse random-float 1 <  num-protesters1 / (num-protesters1 + num-protesters2) ; randomly choose whether to face protester1 or protester2, based on ratio of protesters
  [ ; if facing protester1 first
    ifelse (xcor > (- 0.5 * police-width)) and (xcor < (0.5 * police-width))
    [
      ; if within the thin blue line and protester1 in sight
      ifelse (any? protesters1 in-cone police-keenness 120) ;
      [ ; move towards protester1
        set target one-of protesters1 in-cone police-keenness 120
        face target
        forward 1
      ] ; close "move towards protester1"
      [ ; open within the thin blue line and protesterB in sight
        ifelse (any? protesters2 in-cone police-keenness 120)
        [; move towards protester2
          set target one-of protesters2 in-cone police-keenness 120
          face target
          forward 1
        ] ; close "move towards protester2"
        [ ; open "else move back to original position"
          face destp ; face destination
          forward 1
        ]
      ] ; close " within the thin blue line and protester2 in sight"
    ] ; close "within the thin blue line and protester2 in sight"
    [ ; Otherwise move to destp
      face destp
      forward 1
    ]
  ] ; close if facing protester1 first
  [ ; open elseif facing protester2 first
    ifelse (xcor > (- 0.5 * police-width)) and (xcor < (0.5 * police-width))
    [   ; If within the thin blue line,
      ; if within the thin blue line and protester2 in sight
      ifelse (any? protesters2 in-cone police-keenness 120) ;
      [ ; move towards protester2
        set target one-of protesters2 in-cone police-keenness 120
        face target
        forward 1
      ] ; close "move towards protester2"
      [ ; open within the thin blue line and protesterB in sight
        ifelse (any? protesters1 in-cone police-keenness 120)
        [; move towards protester1
          set target one-of protesters1 in-cone police-keenness 120
          face target
          forward 1
        ] ; close "move towards protester1"
        [ ; open "else move back to original position"
          face destp ; face destination
          forward 1
        ]
      ] ; close " within the thin blue line and protester2 in sight"
    ] ; close "within the thin blue line and protester2 in sight"
    [ ; Otherwise move to destp ;
      face destp
      forward 1
    ]
   ]
end

to protester1-step
  face dest1
  ; If police within view, then turn around
  ifelse any? police in-cone averse1 120
  [
    left 180
    fd 1
  ]
  [
    right random 45
    left random 45
    forward 1
  ]
end

to protester2-step
  face dest2
  ifelse any? police in-cone averse2 120
  [
    right 180
    fd 1
  ]
  [
    right random 45
    left random 45
    forward 1
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
46
50
125
83
Set up
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
52
120
115
153
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
27
185
205
218
num-protesters1
num-protesters1
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
25
251
197
284
num-police
num-police
16
100
16.0
1
1
NIL
HORIZONTAL

SLIDER
18
310
196
343
num-protesters2
num-protesters2
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
17
362
189
395
police-width
police-width
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
26
516
198
549
averse-mean2
averse-mean2
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
246
511
420
544
police-keenness
police-keenness
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
25
422
197
455
averse-mean1
averse-mean1
1
20
10.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

Two opposing protest groups.
Each protester has an 'aversion' rating that varies normally.
They all want to make it to the other side, but some are more adverse to police than others.
Police have the same keeness. They will be collect towards protesters.

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experimentA" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count protestors1 with [xcor &lt; 0]</metric>
    <metric>count protestors2 with [xcor &gt; 0]</metric>
    <enumeratedValueSet variable="police-width">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adverse-mean1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protestors1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-police" first="16" step="1" last="100"/>
    <enumeratedValueSet variable="police-keenness">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adverse-mean2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protestors2">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentB" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count protestors1 with [xcor &lt; 0]</metric>
    <metric>count protestors2 with [xcor &gt; 0]</metric>
    <steppedValueSet variable="police-width" first="2" step="1" last="5"/>
    <enumeratedValueSet variable="adverse-mean1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protestors1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-police" first="16" step="1" last="200"/>
    <enumeratedValueSet variable="police-keenness">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adverse-mean2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protestors2">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentC" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count protestors1 with [xcor &lt; 0]</metric>
    <metric>count protestors2 with [xcor &gt; 0]</metric>
    <steppedValueSet variable="police-width" first="1" step="1" last="5"/>
    <enumeratedValueSet variable="adverse-mean1">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-protestors1" first="25" step="25" last="100"/>
    <steppedValueSet variable="num-police" first="16" step="1" last="100"/>
    <enumeratedValueSet variable="police-keenness">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adverse-mean2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protestors2">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experimentD" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count protestors1 with [xcor &lt; 0]</metric>
    <metric>count protestors2 with [xcor &gt; 0]</metric>
    <steppedValueSet variable="police-width" first="1" step="1" last="5"/>
    <enumeratedValueSet variable="adverse-mean1">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-protestors1" first="25" step="25" last="100"/>
    <steppedValueSet variable="num-police" first="16" step="1" last="100"/>
    <enumeratedValueSet variable="police-keenness">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="adverse-mean2">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-protestors2" first="25" step="25" last="100"/>
  </experiment>
  <experiment name="experiment_normal_keen2_" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count protesters1 with [xcor &lt; 0]</metric>
    <metric>count protesters2 with [xcor &gt; 0]</metric>
    <enumeratedValueSet variable="police-width">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="averse-mean1">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-protesters1" first="25" step="25" last="100"/>
    <steppedValueSet variable="num-police" first="16" step="1" last="100"/>
    <enumeratedValueSet variable="police-keenness">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="averse-mean2">
      <value value="10"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-protesters2" first="25" step="25" last="100"/>
  </experiment>
  <experiment name="experiment_normal_vary_w_k" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count protesters1 with [xcor &lt; 0]</metric>
    <metric>count protesters2 with [xcor &gt; 0]</metric>
    <steppedValueSet variable="police-width" first="1" step="2" last="5"/>
    <enumeratedValueSet variable="averse-mean1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protesters1">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="num-police" first="16" step="1" last="100"/>
    <steppedValueSet variable="police-keenness" first="2" step="4" last="10"/>
    <enumeratedValueSet variable="averse-mean2">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-protesters2">
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
