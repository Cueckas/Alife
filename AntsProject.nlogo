globals [
  spawn-delay-counter
  colony-energy
  spawn-delay
  food-pile-timer1
  food-pile-timer2
  food-pile-timer3
  food-pile-interval

  total-food-1
  total-food-2
  total-food-3

  spawn-pile1?
  spawn-pile2?
  spawn-pile3?

  countdown-pile1?
  countdown-pile2?
  countdown-pile3?


  ;for poly only
  colony-energy-1
  colony-energy-2

]

breed [ants1 ant1]
breed [ants2 ant2]


ants1-own[
 health points
 fighting?
]

ants2-own[
 health-points
 fighting?
]

patches-own [
  chemical             ;; amount of chemical on this patch
  food                 ;; amount of food on this patch (0, 1, or 2)
  nest?                ;; true on nest patches, false elsewhere
  nest-scent           ;; number that is higher closer to the nest
  food-source-number   ;; number (1, 2, or 3) to identify the food sources

  ;FOR POLYMORPHISM TEST

  nest1?
  nest2?
  nest-scent1
  nest-scent2
  chemical1
  chemical2

]

turtles-own[
  leader?
  age
  energy
  following?
  followers
  leader
  foodsource
  fake-foodsource
  lost?
  initial-time
  speed
  success-runs
  line-number
  death-delay
  food-carried
  speed-size-penalty

]
;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to setup-poly
  clear-all
  set-default-shape turtles "ant"

  ask patch 0 25 [
  sprout-ants1 100 [
    ;set health-points 2
    set size ifelse-value (random-float 100 < polymorphism) [3] [2]
    if size = 3
      [ set colony-energy-1 colony-energy-1 - 1
        ;set health-points 4]
      ]
    set color red
  ]
]

ask patch 0 -25 [
  sprout-ants2 100 [
    ;set health-points 2
    set size 2
    set color blue
  ]
]

  set spawn-delay-counter 0
  reset-ticks
  setup-patches-for-poly
  set colony-energy maximum-pop

end


to setup-patches-for-poly
   ask patches
  [ setup-nests-poly
    setup-food-poly
    recolor-patch-poly
  ]

end


to setup-nests-poly
  ;; set nest? variable to true inside the nest, false elsewhere
  set nest1? (distancexy 0 25) < 5
  ;; spread a nest-scent over the whole world -- stronger near the nest
  set nest-scent1 200 - distancexy 0 25

  set nest2? (distancexy 0 -25) < 5
  ;; spread a nest-scent over the whole world -- stronger near the nest
  set nest-scent2 200 - distancexy 0 -25

end

to setup-food-poly

  if (distancexy 0 0) < 5
  [set food-source-number 1]

   if (distancexy 25 0) < 5
  [set food-source-number 2]

   if (distancexy -25 0) < 5
  [set food-source-number 3]

  if food-source-number = 1
  [ set food one-of [1 2 3 4 ]
    set total-food-1 total-food-1 + food ]

  if food-source-number = 2
  [ set food one-of [1 2 3 4 ]
    set total-food-2 total-food-2 + food ]

  if food-source-number = 3
  [ set food one-of [1 2 3 4 ]
    set total-food-3 total-food-3 + food ]

end

to recolor-patch-poly

  ifelse nest1?
  [set pcolor red + 3]
  [ ifelse nest2? [set pcolor blue + 3]
    [ ifelse food > 0
    [ if food-source-number = 1 [ set pcolor lime ]
      if food-source-number = 2 [ set pcolor lime]
      if food-source-number = 3 [ set pcolor lime]
      if food-source-number = 4 [ set pcolor lime]]
    ;; scale color to show chemical concentration
    [ ifelse chemical1 < chemical2
        [ set pcolor scale-color turquoise chemical2 0.1 5  ]
        [ set pcolor scale-color yellow chemical1 0.1 5 ]
      ]
    ]
  ]

end

to setup

  clear-all
  set-default-shape turtles "ant"
  set spawn-delay-counter 0
  ;create-turtles population
  ;[
    ;set size ifelse-value (random-float 100 < polymorphism) [3] [2]       ;; easier to see
    ;set color red      ;; red = not carrying food
    ;set leader? false
    ;set followers 0
    ;set speed 1
    ;set success-runs 0
    ;set foodsource patch 0 0
    ;set age 250
  ;]
  reset-ticks
  setup-patches
  set colony-energy maximum-pop
  set spawn-delay 2
  ifelse Scarce-Food
  [ set food-pile-interval 750]
  [ set food-pile-interval 500]

  set food-pile-timer1 food-pile-interval
  set food-pile-timer2 food-pile-interval
  set food-pile-timer3 food-pile-interval
    ; Set the interval for creating a new food pile

  set spawn-pile1? false
  set spawn-pile2? false
  set spawn-pile3? false

  set countdown-pile1? false
  set countdown-pile2? false
  set countdown-pile3? false

end

to setup-patches
  ask patches
  [ setup-nest
    setup-food
    recolor-patch(false) ]
end

to setup-nest  ;; patch procedure
  ;; set nest? variable to true inside the nest, false elsewhere
  set nest? (distancexy 0 0) < 5
  ;; spread a nest-scent over the whole world -- stronger near the nest
  set nest-scent 200 - distancexy 0 0
end

to setup-food  ;; patch procedure
  ;; setup food source one on the right

  ifelse Scarce-Food
  [
      ;if (distancexy (0.6 * max-pxcor) 0) < 3.25
    ;[ set food-source-number 1 ]
    ;; setup food source two on the lower-left
    if (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 3.5
    [ set food-source-number 2 ]
    ;; setup food source three on the upper-left
    if (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 3.5
    [ set food-source-number 3 ]
    ;; set "food" at sources to either 1 or 2, randomly

  ]
  [
        if (distancexy (0.6 * max-pxcor) 0) < 5
    [ set food-source-number 1 ]
    ;; setup food source two on the lower-left
    if (distancexy (-0.6 * max-pxcor) (-0.6 * max-pycor)) < 5
    [ set food-source-number 2 ]
    ;; setup food source three on the upper-left
    if (distancexy (-0.8 * max-pxcor) (0.8 * max-pycor)) < 5
    [ set food-source-number 3 ]
    ;; set "food" at sources to either 1 or 2, randomly
  ]


  create_pile_1

  create_pile_2

  create_pile_3

end



to recolor-patch[recruit?]  ;; patch procedure
  ;; give color to nest and food sources


  if ticks > 0 and Food-Growth[

    if total-food-1 = 0 and spawn-pile1? = false
      [
        ifelse countdown-pile1? = false
        [set countdown-pile1? true
         set food-pile-timer1 ticks]
        [
          if ticks - food-pile-timer1 >= food-pile-interval
          [ set food-pile-timer1 ticks
            set spawn-pile1? true
          ]
        ]

      ]
     if total-food-2 = 0 and spawn-pile2? = false
      [ ifelse countdown-pile2? = false
        [set countdown-pile2? true
         set food-pile-timer2 ticks]
        [
          if ticks - food-pile-timer2 >= food-pile-interval
          [ set food-pile-timer2 ticks
            set spawn-pile2? true
          ]
        ]
      ]

      if total-food-3 = 0 and spawn-pile3? = false
      [  ifelse countdown-pile3? = false
        [set countdown-pile3? true
         set food-pile-timer3 ticks]
        [
          if ticks - food-pile-timer3 >= food-pile-interval
          [ set food-pile-timer3 ticks
            set spawn-pile3? true
          ]
        ]
      ]

     spawn-piles

  ]

  ifelse nest?
  [ set pcolor violet ]
  [ ifelse food > 0
    [ if food-source-number = 1 [ set pcolor cyan ]
      if food-source-number = 2 [ set pcolor sky  ]
      if food-source-number = 3 [ set pcolor blue ]
      if food-source-number = 4 [ set pcolor magenta]]
    ;; scale color to show chemical concentration
    [ ifelse recruit?
      [set pcolor scale-color green chemical 0.1 5]
      [set pcolor scale-color blue chemical 0.1 5]
    ]
  ]

end


to spawn-turtles-until-max

  let population count turtles
  ;let adjusted-spawn-delay max list 2 (20 - (population / (colony-energy + 1))) ; Growth rate
  let population-factor population / (colony-energy + 1)
  let delay (2 + (population-factor * 5))

  ifelse population > colony-energy or colony-energy = 0 ; ???
    [ set spawn-delay delay ]
    [ set spawn-delay 1]

  show (word "Delay:" spawn-delay)

  let current-turtles count turtles
  let turtles-to-spawn maximum-pop - current-turtles
  if turtles-to-spawn > 0 [
    ifelse count patches with [nest?] > 0 [
      let spawn-patch one-of patches with [nest?]
      ask spawn-patch [
        set spawn-delay-counter spawn-delay-counter + 1
        if spawn-delay-counter >= spawn-delay and colony-energy > 0 [
          sprout 1 [

            set size ifelse-value (random-float 100 < polymorphism) [3] [2]
            if colony-energy < 2
              [set size 2]
            ifelse size = 2
            [ set colony-energy colony-energy - 1
              set speed-size-penalty 0.05
            ]
            [ set colony-energy colony-energy - 2
              set speed-size-penalty 0.1
            ]
            set color red
            set leader? false
            set followers 0
            set speed 1
            set success-runs 0
            set foodsource patch 0 0
            set age 300
            ; ... additional attributes
          ]
          set spawn-delay-counter 0
        ]
      ]
    ] [
      ; Handle the case where there are no patches with [nest?]
      show "No patches with nest? to spawn turtles."
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;
;;; Create ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   Food Pile     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

to create_pile_1

     if food-source-number = 1
  [ set food one-of [1 2 3 4 ]
    set total-food-1 total-food-1 + food ]



end

to create_pile_2

  if food-source-number = 2
  [ set food one-of [1 2 3 4 ]
    set total-food-2 total-food-2 + food ]



end

to create_pile_3

  if food-source-number = 3
  [ set food one-of [1 2 3 4 ]
    set total-food-3 total-food-3 + food ]
end


to spawn-piles

   if spawn-pile1? and not Scarce-Food[
      ;set food-pile-timer1 ticks
      ifelse ticks - food-pile-timer1 < 10
      [create_pile_1]
      [
       set spawn-pile1? false
       set total-food-1 sum [food] of patches with [pcolor = cyan]
       set countdown-pile1? false
      ]
    ]
    if spawn-pile2?[
      ;set food-pile-timer1 ticks
      ifelse ticks - food-pile-timer2 < 10
      [create_pile_2]
      [
       set spawn-pile2? false
       set total-food-2 sum [food] of patches with [pcolor = sky]
       set countdown-pile2? false
      ]
    ]
    if spawn-pile3?[
      ;set food-pile-timer1 ticks
      ifelse ticks - food-pile-timer3 < 10
      [create_pile_3]
      [
       set spawn-pile3? false
       set total-food-3 sum [food] of patches with [pcolor = blue]
       set countdown-pile3? false
      ]
    ]

end

;;;;;;;;;;;;;;;;;;;;;
;;; Poly procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   POLY TEST    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;



to start_poly  ;; forever button
  ;spawn-turtles-until-max
  ask turtles
  [ if who >= ticks [  ] ;; DONT delay initial departure
    set speed 1
    ifelse color = red or color = blue
    [ look-for-food-poly ] ;; not carrying food? look for it]
    [ if color != grey
      [return-to-nest-poly]
    ] ;; carrying food? take it back to nest

    if color = grey [
      set speed 0.2
    ]
    wiggle
    fd 1 * (speed - speed-size-penalty)
  ]

  diffuse chemical1 (diffusion-rate / 100)
  diffuse chemical2 (diffusion-rate / 100)

  ask patches
  [ set chemical1 chemical1 * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    set chemical2 chemical2 * (100 - evaporation-rate) / 100
    recolor-patch-poly]
  tick
  if death-mechanics
   [update-ant-stats]

end

to fight-ants


end

to return-to-nest-poly  ;; turtle procedure

  ifelse breed = ants1[
    ifelse nest1?
  [ ;; drop food and head out again
    set colony-energy-1 colony-energy-1 + food-carried
    set food-carried 0
    set color red
    rt 180 ]
  [ set chemical1 chemical1 + 60  ;; drop some chemical
    uphill-nest-scent1 ]

  ]
  [
    ifelse nest2?
    [ ;; drop food and head out again
    set colony-energy-2 colony-energy-2 + food-carried
    set food-carried 0
    set color blue
    rt 180 ]
    [ set chemical2 chemical2 + 60  ;; drop some chemical
    uphill-nest-scent2 ]         ;; head toward the greatest value of nest-scent

  ]
end

to look-for-food-poly  ;; turtle procedure

  if food > 0
  [
    carry-food
    set food food - food-carried
    rt 180
 ifelse breed = ants1
    [set color orange + 1]
    [set color cyan + 1]

    stop ]
  ;; go in the direction where the chemical smell is strongest

  ifelse breed = ants1 [
    if (chemical1 >= 0.05) and (chemical1 < 2)
    [ uphill-chemical1 ]
  ]
  [if (chemical2 >= 0.05) and (chemical2 < 2)
    [ uphill-chemical2 ]]

end



to uphill-nest-scent1  ;; turtle procedure
  let scent-ahead nest-scent-at-angle1   0
  let scent-right nest-scent-at-angle1  45
  let scent-left  nest-scent-at-angle1 -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to uphill-nest-scent2  ;; turtle procedure
  let scent-ahead nest-scent-at-angle2   0
  let scent-right nest-scent-at-angle2  45
  let scent-left  nest-scent-at-angle2 -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to-report nest-scent-at-angle1 [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent1] of p
end

to-report nest-scent-at-angle2 [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent2] of p
end


to uphill-chemical1;; turtle procedure
  let scent-ahead chemical-scent-at-angle1   0
  let scent-right chemical-scent-at-angle1  45
  let scent-left  chemical-scent-at-angle1 -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end


to-report chemical-scent-at-angle1 [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical1] of p
end

to uphill-chemical2 ;; turtle procedure
  let scent-ahead chemical-scent-at-angle2   0
  let scent-right chemical-scent-at-angle2  45
  let scent-left  chemical-scent-at-angle2 -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end


to-report chemical-scent-at-angle2 [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical2] of p
end

;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    GROUP     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;


to go_group
  spawn-turtles-until-max
  set diffusion-rate 10
  set evaporation-rate 80

  let recruit_chems? false
  ask turtles
      [if who >= ticks [ stop ] ;; delay initial departure
        if color = red
        [ look-for-food-group
          ifelse leader?  = true
          [set speed 0.70]
          [if following? = false and nest? = false
            [set speed 1]
          ]

          ]   ;; not carrying food? look for it
        if color = orange + 1
        [ return-to-nest-group
          set recruit_chems? false] ;; carrying food? take it back to nest
        if color = blue
        [recruit-ants
         ifelse nest?
          [set speed 1.1]
          [set speed 1]
         set recruit_chems? true ]
        if color = green
        [follow-leader-group
          if is-turtle? leader
          [  if [color] of leader != blue
             [set speed 0.68 - ((line-number + [followers] of leader) / (10 + max_group))]
          ]
        ]

        if color = grey [
          ;stop
          set speed 0.2
        ]
        wiggle
        fd 1 * (speed - speed-size-penalty)

      ]

  diffuse chemical (diffusion-rate / 100)
  ask patches
  [ set chemical chemical * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    recolor-patch(false) ]
  tick

  if death-mechanics
   [update-ant-stats]
end

to recruit-ants  ;; turtle procedure
  rt 100
  lt 20
  let min-distance 5

 if any? other turtles in-radius min-distance with [color = red] and (leader? = false) and followers < 1 [
  face one-of other turtles in-radius min-distance with [color = red]
  ]

  let search-time-limit 20;

  ask other turtles with [(color = red) and distance myself < min-distance and (leader? = false) and followers < 1 ]
   [if [followers] of myself < max_group
      [
        face myself
        if nest?
        [set speed 0.65]
        set color green
        set leader? false
        set leader myself
        set following? true
        ;set foodsource [foodsource] of myself
        ask myself [set followers followers + 1]
        set line-number [followers] of myself
        stop
      ]
   ]

  if ticks - initial-time > search-time-limit [
       set color red  ; Return to red if time limit exceeded
       ifelse followers > 0
       [set leader? true
        set speed 0.8
       ]
       [set speed 1
        set leader? false
       ]
    ]


end


to follow-leader-group
  set following? true

  let rand random 100

  if food > 0
  [look-for-food]

  ifelse is-turtle? leader
  [ if [color] of leader = orange + 1 or [leader?] of leader = false[
    set foodsource [foodsource] of leader
    face [foodsource] of leader  ]

    if ((rand <= ([followers] of leader + line-number)) and distance leader > 5)[
    ask leader[
      set followers followers - 1
    ]
    set color red
    set following? false
    set line-number 0
    ]


    if leader != nobody and is-turtle? leader
    [face leader]
    if foodsource = [foodsource] of leader and [leader?] of leader = false and [color] of leader != blue
    [face foodsource]


  ]
  [ set color red ]


  if patch-here = foodsource[

    if is-turtle? leader
    [ ask leader[
      set followers followers - 1]
    ]
    set color red
    set following? false
    set line-number 0
    if patch-ahead 2 != nobody
      [ face patch-ahead 2]
  ]





end




to look-for-food-group  ;; turtle procedure
  ifelse food > 0
  [ ;(size + food)/size
    ;let burden-cap (size + food) / size
    carry-food
    if color != orange + 1
    [
     if success-runs < 4 and leader? = true
     [set success-runs success-runs + 1]
      set color orange + 1     ;; pick up food
      set foodsource patch-here
      set fake-foodsource random-patch-in-radius foodsource 20
      will-get-lost
      ;show ( word "Will get lost: " lost?)
      if lost? = true
      [
        set foodsource fake-foodsource
      ]
      set food food - food-carried        ;; and reduce the food source
      ;rt 180                   ;; and turn around
      set leader? false
      set speed 1;
    ]
    stop
   ]
  [
    let selected-turtle one-of other turtles in-radius 2.5 with [color = red and leader? = true]

    if selected-turtle != nobody and is-turtle? selected-turtle
    [
      face selected-turtle
      ;set speed 0.2
      set color green
      set leader selected-turtle
      set following? true
      ask selected-turtle [set followers followers + 1]
      set foodsource [foodsource] of leader
    ]
  ]


  ;; go in the direction where the chemical smell is strongest
  if (chemical >= 0.05) and (chemical < 2)
    [ uphill-chemical ]
  if leader?
  [
    go-to-food-source
  ]
end

to return-to-nest-group  ;; turtle procedure
  ifelse nest?
  [ ;; drop food and head out again
    set colony-energy colony-energy + food-carried
    set food-carried 0
    let rnd random 100
    ifelse rnd > 45 [
       set color blue
       set initial-time ticks
       recruit-ants
    ][
       set color red
     ]
  ]
  [ set chemical chemical + 30  ;; drop some chemical
    uphill-nest-scent ]         ;; head toward the greatest value of nest-scent
end




;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    TANDEM RUNNING     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;



to go_tandem
  spawn-turtles-until-max
  let recruit_chems? false
  set diffusion-rate 75
  set evaporation-rate 60
  ask turtles
      [if who >= ticks [ stop ] ;; delay initial departure
        if color = red
        [ look-for-food-tandem]   ;; not carrying food? look for it
        if color = orange + 1
        [ return-to-nest-tandem
          set recruit_chems? false] ;; carrying food? take it back to nest
        if color = blue
        [find-closest-ant
         set recruit_chems? true ]
        if color = green
        [follow-leader]
        wiggle
        ifelse leader? = true
        [ set speed 0.5 ]
        [ ifelse following? = true
          [set speed  0.45]
          [set speed 1]
        ]

       if color = grey [
          set speed 0.2
        ]
        fd 1 * (speed - speed-size-penalty)

      ]

  diffuse chemical (diffusion-rate / 100)
  ask patches
  [ set chemical chemical * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    recolor-patch(recruit_chems?) ]
  tick
  if death-mechanics
   [update-ant-stats]
end

to follow-leader
  set following? true
  set speed 0.45

  if is-turtle? leader[

    if [color] of leader = orange + 1 or [leader?] of leader = false[
      ask leader[
        set followers followers - 1
      ]
      if patch-ahead 3 != nobody
      [face patch-ahead 3]
      set color red
      set following? false
    ]
    face leader
  ]

end

to return-to-nest-tandem  ;; turtle procedure
  ifelse nest?
  [ ;; drop food and head out again
    set colony-energy colony-energy + food-carried
    set food-carried 0
    let rnd random 10
    ifelse rnd > 2 [
       set color blue
       set initial-time ticks
       find-closest-ant
    ][
       set color red
     ]
  ]
  [ set chemical chemical + 5  ;; drop some chemical
    uphill-nest-scent ]         ;; head toward the greatest value of nest-scent
end

to find-closest-ant  ;; turtle procedure

  set chemical chemical + 100
  if food > 0 [
    ;look-for-food-tandem
  ]
  ;show ( word "Coord " (max-pxcor + max-pycor - 60))
  let closest-ant nobody
  let min-distance max-pxcor + max-pycor - 60

  let search-time-limit 50 ;

  ask other turtles with [(color = red or color = blue) and leader? = false] [
    let distance1 distance myself
    if distance1 < min-distance [
      set min-distance distance1
      set closest-ant self
    ]
  ]

  if ticks - initial-time > search-time-limit [
       set color red  ; Return to red if time limit exceeded
       set leader? false

    ]
  if closest-ant != nobody and [leader?] of closest-ant = false [
    face closest-ant  ;; Make the current turtle face the closest red ant
    ;fd 1
    wiggle
    if distance closest-ant < 5 [

      if followers < max_group[
        ask closest-ant [
          ; Make the closest red ant follow the current turtle
          face myself
          fd 1
          set color green
          set leader myself
        ]
        set followers followers + 1
        set leader? true
        set color red
      ]

    ]
  ]
end



to look-for-food-tandem  ;; turtle procedure
  if food > 0
  [
    carry-food
    if color != orange + 1
    [
     if success-runs < 4 and leader? = true
     [set success-runs success-runs + 1]
      set color orange + 1     ;; pick up food
      set foodsource patch-here
      set fake-foodsource random-patch-in-radius foodsource 20
      will-get-lost
      ;show ( word "Will get lost: " lost?)
      if lost? = true
      [
        set foodsource fake-foodsource
      ]
      set food food - food-carried        ;; and reduce the food source
      ;rt 180                   ;; and turn around
      set leader? false
    ]
    stop
   ]
  ;; go in the direction where the chemical smell is strongest
  if (chemical >= 0.05) and (chemical < 2)
    [ uphill-chemical ]
  if leader?
  [
    go-to-food-source
  ]
end

to will-get-lost
  let rand random 100
  let modifier success-runs * 7
  let baseline 67
  ifelse rand <= 67 + modifier
  [ set lost? false]
  [ set lost? true]
end

to go-to-food-source
  face foodsource
  wiggle
  ifelse patch-here = foodsource or food > 0
  [
    set color red
    set leader? false
  ]
  [
    rt random 60
    lt random 60
    ;face patch-ahead 1
  ]
end



;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   MASS  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;


to go_mass  ;; forever button
  spawn-turtles-until-max
  set diffusion-rate 75
  set evaporation-rate 10
  ask turtles
  [ if who >= ticks [ stop ] ;; delay initial departure
    ifelse color = red
    [ look-for-food  ;; not carrying food? look for it
      ifelse chemical > 20
      [ set speed 1.2]
      [ set speed 1]
    ]
    [ if color != grey
      [return-to-nest
       set speed 0.8]
    ] ;; carrying food? take it back to nest

    if color = grey [
      set speed 0.2
    ]
    wiggle
    fd 1 * (speed - speed-size-penalty)

  ]
  diffuse chemical (diffusion-rate / 100)
  ask patches
  [ set chemical chemical * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    recolor-patch(true) ]
  tick
  if death-mechanics
   [update-ant-stats]
end



to return-to-nest  ;; turtle procedure
  ifelse nest?
  [ ;; drop food and head out again
    set colony-energy colony-energy + food-carried
    set food-carried 0
    set color red
    rt 180 ]
  [ set chemical chemical + 60  ;; drop some chemical
    uphill-nest-scent ]         ;; head toward the greatest value of nest-scent
end

to look-for-food  ;; turtle procedure
  if food > 0
  [
    carry-food
    set color orange + 1     ;; pick up food
    set food food - food-carried        ;; and reduce the food source
    rt 180                   ;; and turn around
    set leader? false
    stop ]
  ;; go in the direction where the chemical smell is strongest
  if (chemical >= 0.05) and (chemical < 2)
    [ uphill-chemical ]
end



;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   SOLITARY    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

to go_solitary  ;; forever button
  spawn-turtles-until-max
  set diffusion-rate 0
  set evaporation-rate 100
  ask turtles
  [ if who >= ticks [ stop ] ;; delay initial departure
    set speed 1.2
    ifelse color = red
    [ look-for-food ] ;; not carrying food? look for it]
    [ if color != grey
      [return-to-nest]
    ] ;; carrying food? take it back to nest

    if color = grey [
      set speed 0.2
    ]
    wiggle
    fd 1 * (speed - speed-size-penalty)
  ]

  diffuse chemical (diffusion-rate / 100)
  ask patches
  [ set chemical chemical * (100 - evaporation-rate) / 100  ;; slowly evaporate chemical
    recolor-patch(true) ]
  tick
  if death-mechanics
   [update-ant-stats]
end



;;;;;;;;;;;;;;;;;;;;;
;;; Other stuff ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   STUFF    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;

;; sniff left and right, and go where the strongest smell is
to uphill-chemical  ;; turtle procedure
  let scent-ahead chemical-scent-at-angle   0
  let scent-right chemical-scent-at-angle  45
  let scent-left  chemical-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

;; sniff left and right, and go where the strongest smell is
to uphill-nest-scent  ;; turtle procedure
  let scent-ahead nest-scent-at-angle   0
  let scent-right nest-scent-at-angle  45
  let scent-left  nest-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to wiggle  ;; turtle procedure
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
end

to-report nest-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [nest-scent] of p
end

to-report chemical-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [chemical] of p
end

to-report random-patch-in-radius [stored-patch radius]

  ; Define the radius
  ; Calculate a random angle
  let random-angle random 360
  ; Calculate the new coordinates based on the angle and radius
  let new-xcor ([pxcor] of stored-patch) + radius * cos random-angle
  let new-ycor ([pycor] of stored-patch) + radius * sin random-angle

  ;let list new-xcor min-pxcor
  ;let list new-ycor min-pycor

  let mx max list new-xcor min-pxcor
  let my max list new-ycor min-pycor
  ; Ensure the new coordinates are within world boundsada
  set new-xcor min list my max-pxcor
  set new-ycor min list mx max-pycor

  ; Get the patch at the new coordinates
  let rand-patch patch new-xcor new-ycor
  report rand-patch
end

to carry-food

  ifelse size = 2
  [ ifelse food = 1
    [set food-carried 1]
    [set food-carried 2]
  ]
  [
    set food-carried food
  ]
  if food-source-number = 1 [set total-food-1 total-food-1 - food-carried]
  if food-source-number = 2 [set total-food-2 total-food-2 - food-carried]
  if food-source-number = 3 [set total-food-3 total-food-3 - food-carried]

end

to update-ant-stats

  ask turtles
  [ ;if population > colo
    ifelse count turtles > colony-energy * 2 ; starving?
    [set age age - 1]
    [set age age - 1]
    if age <= 20
    [ set color grey
      set leader? false
      set followers 0
      set following? false
    ]
    if age <= 0
    [ die ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
536
65
1250
780
-1
-1
9.944
1
10
1
1
1
0
0
0
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
84
71
164
104
NIL
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

SLIDER
31
106
221
139
diffusion-rate
diffusion-rate
0.0
99.0
50.0
1.0
1
NIL
HORIZONTAL

SLIDER
31
141
221
174
evaporation-rate
evaporation-rate
0.0
99.0
15.0
1.0
1
NIL
HORIZONTAL

BUTTON
409
514
489
547
NIL
go_mass
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
5
197
248
476
Food in each pile
time
food
0.0
50.0
0.0
120.0
true
false
"" ""
PENS
"food-in-pile1" 1.0 0 -11221820 true "" "plotxy ticks sum [food] of patches with [pcolor = cyan]"
"food-in-pile2" 1.0 0 -13791810 true "" "plotxy ticks sum [food] of patches with [pcolor = sky]"
"food-in-pile3" 1.0 0 -13345367 true "" "plotxy ticks sum [food] of patches with [pcolor = blue]"

BUTTON
276
516
370
549
NIL
go_tandem
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
38
590
210
623
max_group
max_group
1
20
11.0
1
1
NIL
HORIZONTAL

BUTTON
279
448
364
481
NIL
go_group
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
1364
106
1536
139
polymorphism
polymorphism
0
100
15.0
1
1
NIL
HORIZONTAL

PLOT
303
233
499
383
Population over time
time
population
0.0
50.0
0.0
50.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

SWITCH
41
545
190
578
death-mechanics
death-mechanics
1
1
-1000

BUTTON
399
449
492
482
NIL
go_solitary
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
302
383
499
428
Population
count turtles
17
1
11

MONITOR
266
584
359
629
NIL
colony-energy
17
1
11

SLIDER
332
101
504
134
maximum-pop
maximum-pop
0
200
200.0
1
1
NIL
HORIZONTAL

MONITOR
6
477
86
522
NIL
total-food-1
17
1
11

MONITOR
89
478
169
523
NIL
total-food-2
17
1
11

MONITOR
171
478
251
523
NIL
total-food-3
17
1
11

MONITOR
366
586
527
631
NIL
count patches with [nest?]
17
1
11

SWITCH
168
657
293
690
Scarce-Food
Scarce-Food
0
1
-1000

SWITCH
165
694
293
727
Food-Growth
Food-Growth
1
1
-1000

BUTTON
1351
292
1441
325
NIL
setup-poly
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
1470
293
1558
326
NIL
start_poly
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
1344
340
1448
385
NIL
colony-energy-1
17
1
11

MONITOR
1460
340
1564
385
NIL
colony-energy-2
17
1
11

TEXTBOX
1289
189
1611
286
This is a setup to solely test polymorphism on the standard model. Do not use the buttons below in conjunction with the buttons in the left side! (The polymorphism slider can be used with the rest)
15
14.0
0

@#$#@#$#@
## WHAT IS IT?

In this project, a colony of ants forages for food. Though each ant follows a set of simple rules, the colony as a whole acts in a sophisticated way.

## HOW IT WORKS

When an ant finds a piece of food, it carries the food back to the nest, dropping a chemical as it moves. When other ants "sniff" the chemical, they follow the chemical toward the food. As more ants carry food to the nest, they reinforce the chemical trail.

## HOW TO USE IT

Click the SETUP button to set up the ant nest (in violet, at center) and three piles of food. Click the GO button to start the simulation. The chemical is shown in a green-to-white gradient.

The EVAPORATION-RATE slider controls the evaporation rate of the chemical. The DIFFUSION-RATE slider controls the diffusion rate of the chemical.

If you want to change the number of ants, move the POPULATION slider before pressing SETUP.

## THINGS TO NOTICE

The ant colony generally exploits the food source in order, starting with the food closest to the nest, and finishing with the food most distant from the nest. It is more difficult for the ants to form a stable trail to the more distant food, since the chemical trail has more time to evaporate and diffuse before being reinforced.

Once the colony finishes collecting the closest food, the chemical trail to that food naturally disappears, freeing up ants to help collect the other food sources. The more distant food sources require a larger "critical number" of ants to form a stable trail.

The consumption of the food is shown in a plot.  The line colors in the plot match the colors of the food piles.

## EXTENDING THE MODEL

Try different placements for the food sources. What happens if two food sources are equidistant from the nest? When that happens in the real world, ant colonies typically exploit one source then the other (not at the same time).

In this project, the ants use a "trick" to find their way back to the nest: they follow the "nest scent." Real ants use a variety of different approaches to find their way back to the nest. Try to implement some alternative strategies.

The ants only respond to chemical levels between 0.05 and 2.  The lower limit is used so the ants aren't infinitely sensitive.  Try removing the upper limit.  What happens?  Why?

In the `uphill-chemical` procedure, the ant "follows the gradient" of the chemical. That is, it "sniffs" in three directions, then turns in the direction where the chemical is strongest. You might want to try variants of the `uphill-chemical` procedure, changing the number and placement of "ant sniffs."

## NETLOGO FEATURES

The built-in `diffuse` primitive lets us diffuse the chemical easily without complicated code.

The primitive `patch-right-and-ahead` is used to make the ants smell in different directions without actually turning.

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Wilensky, U. (1997).  NetLogo Ants model.  http://ccl.northwestern.edu/netlogo/models/Ants.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was developed at the MIT Media Lab using CM StarLogo.  See Resnick, M. (1994) "Turtles, Termites and Traffic Jams: Explorations in Massively Parallel Microworlds."  Cambridge, MA: MIT Press.  Adapted to StarLogoT, 1997, as part of the Connected Mathematics Project.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 1998.

<!-- 1997 1998 MIT -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -16777216 true false 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -16777216 true false 78 58 99 116 139 123 137 128 95 119
Polygon -16777216 true false 48 103 90 147 129 147 130 151 86 151
Polygon -16777216 true false 65 224 92 171 134 160 135 164 95 175
Polygon -16777216 true false 235 222 210 170 163 162 161 166 208 174
Polygon -16777216 true false 249 107 211 147 168 147 168 150 213 150

ant-has-food
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -16777216 true false 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -16777216 true false 78 58 99 116 139 123 137 128 95 119
Polygon -16777216 true false 48 103 90 147 129 147 130 151 86 151
Polygon -16777216 true false 65 224 92 171 134 160 135 164 95 175
Polygon -16777216 true false 235 222 210 170 163 162 161 166 208 174
Polygon -16777216 true false 249 107 211 147 168 147 168 150 213 150
Circle -1184463 true false 138 21 23

anthill
false
1
Polygon -6459832 true false 60 225 105 105 135 120 165 120 195 105 240 210 150 225
Polygon -6459832 false false 107 106 135 94 162 93 191 103 165 120 137 123
Polygon -16777216 true false 112 109 134 99 162 98 185 105 162 122 135 122
Line -7500403 false 195 105 195 30
Rectangle -2674135 true true 116 30 191 60
Polygon -2674135 true true 72 191 53 204 69 217 156 217 234 192 228 185 248 190 248 220 48 233 50 205
Polygon -2674135 true true 71 197 57 207 63 216

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

butter-fly2
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 124 148 85 105 40 90 15 105 0 150 -5 135 10 180 25 195 70 194 124 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60
Circle -16777216 true false 116 221 67

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
