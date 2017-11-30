;;*************************
;; DEFINICIÓN DE VARIABLES:
;;*************************
extensions [gis profiler]

breed [cars car]
breed [pedestrians pedestrian]
;;breed [vSalidas vSalida]
breed [pSalidas pSalida]
breed [exitParkings exitParking]
breed [congestion-detectors congestion-detector]


globals ;; Para definir las variables globales.
[
  sidewalks-dataset
  streets-dataset
  buildings-dataset
  others-dataset
  parkings-dataset
  properties-dataset
  exits-pedestrians-dataset
  exits-cars-dataset
  exits-parkings-dataset
  entrances-cars-dataset
  intersections-dataset
  lanes-dataset
  congestion-detectors-dataset

  ;;Patches que intersecan a los poligonos
  sidewalks-patchset
  streets-patchset
  buildings-patchset
  others-patchset
  properties-patchset
  parkings-patchset
  exits-pedestrians-patchset
  exits-cars-patchset
  exits-parkings-patchset
  entrances-cars-patchset
  intersections-patchset
  lanes-patchset
  congestion-detectors-patchset

  ;;Variables de velocidad
  car-speed
  pedestrian-speed
]
turtles-own ;; Para definir los atributos de las tortugas.
[]

patches-own ;; Para definir los atributos de las parcelas.
[
  coverage
  description
  occupation
]

;;********************
;; variables de breeds
;;********************


cars-own
[
  speed
  max-speed
  selected-exit
]

pedestrians-own
[
  speed
  first-exit
  campus-exit
]

exitParkings-own
[
  occupationParking
]

;;**************************************
;; INICIALIZACIÓN DE VARIABLES GLOBALES:
;;**************************************

to init-globals ;; Para darle valor inicial a las variables globales.
  set car-speed 0.3
  set pedestrian-speed 0.047
end

;;**********************
;; FUNCIONES PRINCIPALES
;;**********************

to setup ;; Para inicializar la simulación.
  ca           ;; Equivale a clear-ticks + clear-turtles + clear-patches +
               ;; clear-drawing + clear-all-plots + clear-output.
  set-patch-size 12
  init-globals
  ;Cargar las coordenadas de los shapefiles
  setup-geo-data
  init-globals ;; Para inicializar variables globales.
  intersect-patches-with-polygons ;; Le asigna los atributos de los poligonos a las tortugas
  init-parking-exits ;; Crea las salidas de los parqueos
  init-congestion-detectors
  ;; Para crear tortugas e inicializar tortugas y parcelas además.
  ask patches
  [
    init-patch
  ]
  init-pedestrians
  init-cars
  reset-ticks  ;; Para inicializar el contador de ticks.
end

to go ;; Para ejecutar la simulación.
  if(ticks mod 60 = 0)
  [
    check-if-hatch
  ]
  ask cars [drive]
   ask pedestrians[walk check-if-pedestrian-exit]
  tick
  if ticks >= 3600  ;; En caso de que la simulación esté controlada por cantidad de ticks.
    [stop]
end

;;*******************************
;; Otras funciones globales:
;;*******************************
to-report random-rayleigh [ p ]
  if p > 0
  [
    let u random-float 1
    report p * sqrt (-2 * log u e )
  ]
end


;;*******************************************************************************************************
;; Funciones espaciales
;;*******************************************************************************************************

to setup-geo-data
  set sidewalks-dataset gis:load-dataset "data/ACERAS_RodrigoFacio.shp"
  set streets-dataset gis:load-dataset "data/CALLES_RodrigoFacio.shp"
  set buildings-dataset gis:load-dataset "data/EDIFICIOS_RodrigoFacio.shp"
  set others-dataset gis:load-dataset "data/OTROS_RodrigoFacio.shp"
  set parkings-dataset gis:load-dataset "data/PARQUEOS_RodrigoFacio.shp"
  set properties-dataset gis:load-dataset "data/PROPIEDADES_RodrigoFacio.shp"
  set exits-pedestrians-dataset gis:load-dataset "data/SALIDAS_P.shp"
  set exits-cars-dataset gis:load-dataset "data/SALIDAS_V.shp"
  set exits-parkings-dataset gis:load-dataset "data/SALIDAS_PARQUEOS.shp"
  set entrances-cars-dataset gis:load-dataset "data/ENTRADAS_V.shp"
  set intersections-dataset gis:load-dataset "data/INTERSECCIONES_CALLES.shp"
  set lanes-dataset gis:load-dataset "data/CARRILES.shp"
  set congestion-detectors-dataset gis:load-dataset "data/CONGESTIONES.shp"

  ;Crear el "mundo"
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of sidewalks-dataset)
                                                (gis:envelope-of streets-dataset)
                                                (gis:envelope-of buildings-dataset)
                                                (gis:envelope-of others-dataset)
                                                (gis:envelope-of parkings-dataset)
                                                (gis:envelope-of properties-dataset)
                                                (gis:envelope-of exits-pedestrians-dataset)
                                                (gis:envelope-of exits-parkings-dataset)
                                                (gis:envelope-of exits-cars-dataset)
                                                (gis:envelope-of entrances-cars-dataset)
                                                (gis:envelope-of intersections-dataset)
                                                (gis:envelope-of lanes-dataset)
                                                (gis:envelope-of congestion-detectors-dataset))
  foreach gis:feature-list-of properties-dataset
  [
    gis:set-drawing-color green
    gis:fill properties-dataset 1.0
  ]

  foreach gis:feature-list-of parkings-dataset
  [
    gis:set-drawing-color 2
    gis:fill parkings-dataset 1.0
  ]

  foreach gis:feature-list-of streets-dataset
  [
    gis:set-drawing-color gray
    gis:fill streets-dataset 1.0
  ]

  foreach gis:feature-list-of sidewalks-dataset
  [
    gis:set-drawing-color 86
    gis:fill sidewalks-dataset 1.0
  ]

  foreach gis:feature-list-of buildings-dataset
  [
    gis:set-drawing-color 73
    gis:fill buildings-dataset 1.0
  ]

  foreach gis:feature-list-of others-dataset
  [
    gis:set-drawing-color 73
    gis:fill others-dataset 1.0
  ]

   foreach gis:feature-list-of exits-pedestrians-dataset
  [
    gis:set-drawing-color brown
    gis:fill exits-pedestrians-dataset 1.0
  ]

  foreach gis:feature-list-of exits-cars-dataset
  [
    gis:set-drawing-color 125
    gis:fill exits-cars-dataset 1.0
  ]
  foreach gis:feature-list-of entrances-cars-dataset
  [
    gis:set-drawing-color 105
    gis:fill entrances-cars-dataset 1.0
  ]
  foreach gis:feature-list-of intersections-dataset
  [
    gis:set-drawing-color 9
    gis:fill intersections-dataset 1.0
  ]
 foreach gis:feature-list-of lanes-dataset
 [
   gis:set-drawing-color green
   gis:fill lanes-dataset 1.0
 ]
  foreach gis:feature-list-of congestion-detectors-dataset
 [
   gis:set-drawing-color yellow
   gis:fill congestion-detectors-dataset 1.0
 ]
 ;foreach gis:feature-list-of exits-parkings-dataset
 ;[
 ;  gis:set-drawing-color yellow
 ;  gis:fill exits-parkings-dataset 1.0
 ;]
end

to intersect-patches-with-polygons
  gis:apply-coverage properties-dataset "DESCRIPCIO" coverage
  set properties-patchset patches with [coverage = "Propiedad"]
  ask properties-patchset [
    set description "Property"
  ]
  gis:apply-coverage sidewalks-dataset "DESCRIPCIO" coverage
  set sidewalks-patchset patches with [coverage = "Acera"]
  ask sidewalks-patchset [
    set description "Sidewalk"
  ]
  gis:apply-coverage streets-dataset "DESCRIPCIO" coverage
  set streets-patchset patches with [coverage = "Calle"]
  ask streets-patchset [
    set description "Street"
  ]
  gis:apply-coverage buildings-dataset "TIPO" coverage
  set buildings-patchset patches with [coverage = "Edificio"]
  ask buildings-patchset [
    set description "Building"
  ]
  gis:apply-coverage parkings-dataset "DESCRIPCIO" coverage
  set parkings-patchset patches with [coverage = "Parqueo"]
  ask parkings-patchset [
    set description "Parking"
  ]
  gis:apply-coverage parkings-dataset "CAPACIDAD" occupation
  gis:apply-coverage others-dataset "TIPO" coverage
  set others-patchset patches with [coverage = "Otro"]
  ask others-patchset [
    set description "Other"
  ]
  gis:apply-coverage exits-pedestrians-dataset "TIPO" coverage
  set exits-pedestrians-patchset patches with [coverage = "SalidaPeaton"]
  ask exits-pedestrians-patchset [
    set description "PedestrianExit"
  ]
  gis:apply-coverage exits-cars-dataset "TIPO" coverage
  set exits-cars-patchset patches with [coverage = "SalidaVehiculo"]
  ask exits-cars-patchset [
    set description "CarExit"
  ]
  gis:apply-coverage entrances-cars-dataset "TIPO" coverage
  set entrances-cars-patchset patches with [coverage = "EntradaVehiculo"]
  ask entrances-cars-patchset [
    set description "CarEntrace"
  ]
  gis:apply-coverage lanes-dataset "TIPO" coverage
  set lanes-patchset patches with [coverage = "Carril"]
  ask lanes-patchset [
    set description "Lane"
  ]
end



;;*******************************************************************************************************
;; Funciones de patches:
;;*******************************************************************************************************

to init-patch ;; Para inicializar una parcela a la vez.

end

to p-comportamiento-patch ;; Cambiar por nombre significativo de comportamiento de patch

end


;;*******************************************************************************************************
;; Funciones de breeds:
;;*******************************************************************************************************
;;---------------------------
;; Funciones de exitParkings:
;;---------------------------
to init-parking-exits
  let parkings-exits-patches patches with [gis:intersects? self exits-parkings-dataset]
  ask parkings-exits-patches
  [
    sprout-exitParkings 1
    [
      let closest-parking patches in-radius 3 with [description = "Parking"]
      set occupationParking [occupation] of one-of closest-parking * percentage-occupation-parking
      hide-turtle
    ]
  ]
end

to check-if-hatch
  ask exitParkings
  [
    let prob random-rayleigh (desesperation)
    ;show prob

    if prob > random-float 100 and occupationParking > 0 and not any? cars in-radius 5 and not any? pedestrians in-radius 1
    [
      hatch-cars 1
      [
        show-turtle ;los hijos heredan los atributos del padre, por lo que se debe reestablecer el valor de hidden
        set color one-of remove gray base-colors
        set shape "car"
        set size 1.5
        set max-speed 0.3 + random-float 0.5
        set speed car-speed
        set selected-exit false
        ask self [check-for-exit-near-parking]

      ]
      set occupationParking occupationParking - 1
    ]
  ]

end

;Detection-congestion
to init-congestion-detectors
  let congestion-detectors-points patches with [gis:intersects? self congestion-detectors-dataset]
  ask congestion-detectors-points
  [
    sprout-congestion-detectors 1
    [
      ;hide-turtle
    ]
  ]
end

;;------------------------
;; Funciones de cars:
;;------------------------

to init-cars
  create-cars occupation-street
  [
    set color one-of remove gray base-colors
    set shape "car"
    set size 1.5
    set max-speed 0.5 + random-float 0.5
    set speed car-speed
    set selected-exit false
    ask self [check-for-exit-near-parking]

  ]
  ask cars[
    if any? streets-patchset [move-to one-of streets-patchset with [not any? cars in-radius 2]]
  ]
end


to drive

  if patch-ahead 3 != nobody and ([description] of patch-ahead 3 != "Street" or gis:intersects? patch-ahead 3 lanes-dataset)
  [
    if selected-exit = false [ask self [steer]]
  ]

  ask self [check-for-intersection]
  ask self [check-for-exit]
  ask self [check-if-exits]
  ask self [move-forward]
end


to steer
  let front-terrain patch-ahead 3
  ifelse any? patches in-radius 2 with [gis:intersects? self lanes-dataset]
  [
    ifelse [description] of front-terrain != "Street" and not gis:intersects? front-terrain lanes-dataset
    [
      lt 20
    ]
    [if gis:intersects? front-terrain lanes-dataset
      [rt 20]
    ]
  ]
  [
    ask self [steer-without-lanes]
  ]
end



to steer-without-lanes
  let ohead heading
  let rc 0
  let lc 0
  while [[description] of patch-ahead 3  != "Street"]
  [
    if rc >= 18 [stop]
    set rc rc + 1
    rt 20
  ]
  let right-heading heading
  set heading ohead
  while [[description] of patch-ahead 3 != "Street"]
  [
    if lc >= 18 [stop]
    set lc lc + 1
    lt 20
  ]
  if rc < lc
  [ set heading right-heading]

end

to move-forward
  speed-up-car
  let blocking-cars other cars in-cone (3 + speed) 50
  let blocking-car min-one-of blocking-cars [ distance myself ]
  if blocking-car != nobody [
   set speed [ speed ] of blocking-car
   slow-down-car
  ]
  let blocking-pedestrians pedestrians in-cone (2 + speed) 45
  if any? blocking-pedestrians
  [
    set speed 0
  ]
  forward speed
end


to slow-down-car
  let slow-speed (speed - deceleration)
  ifelse slow-speed >= 0
  [set speed slow-speed][set speed 0.01]
end

to speed-up-car
  set speed (speed + acceleration)
  if speed > max-speed [ set speed max-speed ]
end

to check-for-intersection
  if any? patches in-radius 2 with [gis:intersects? self lanes-dataset]
  [
    let patch-right patch-right-and-ahead 90 1
    if gis:intersects? patch-right intersections-dataset or [description] of patch-right = "CarExit"
    [
      set heading towards patch-right
    ]
  ]
end

to check-for-exit-near-parking
  let near-patches nobody
  ifelse entrances-are-exits
  [
    set near-patches other patches in-radius 5 with [description = "CarExit" or description = "CarEntrance"]
  ]
  [
    set near-patches other patches in-radius 5 with [description = "CarExit"]
  ]
  if any? near-patches
  [
    let exit one-of near-patches
    set heading towards exit
    set selected-exit true
  ]
end

to check-for-exit
  let exit nobody
  ifelse entrances-are-exits
  [
    set exit one-of patches in-cone 5 90 with [description = "CarExit" or description = "CarEntrance" ]
  ]
  [
    set exit one-of patches in-cone 5 90 with [description = "CarExit"]
  ]

  ;let exit  one-of patches in-cone 5 90 with [gis:intersects? self exits-cars-dataset]
  if exit = patch-here [set exit nobody]
  if exit != nobody
  [
    set heading towards exit
    set selected-exit true
  ]
end

to check-if-exits
  if gis:intersects? patch-here  exits-cars-dataset
  [
     ;show "sale"
     die
  ]
end


;;------------------------
;; Funciones de pedestrians:
;;------------------------

to init-pedestrians
  create-pedestrians occupation-buildings
  [
    set color white
    set shape "person"
    set size 0.75
    set speed pedestrian-speed
  ]

  ask pedestrians[
    if any? buildings-patchset [move-to one-of buildings-patchset]
  ]
  ask pedestrians [set-evacuation-path2]

end

to set-evacuation-path
  set first-exit set-first-exit self
  set heading towards first-exit
  set campus-exit set-campus-exit first-exit
  set heading towards campus-exit
end

to set-evacuation-path2
  let exits nobody
  let sel-exit nobody
  ifelse any? patches with[description = "PedestrianExit"] in-radius 15
  [
     set exits other patches with [(description = "PedestrianExit") and distance myself > 0]
     set sel-exit min-one-of exits [distance myself]
  ]
  [
    set exits other patches with [(description = "PedestrianExit" or description = "CarExit" or description = "CarEntrance") and distance myself > 0]
    set sel-exit min-one-of exits [distance myself]
  ]
  if sel-exit !=  nobody [set heading towards sel-exit]
end

to-report set-first-exit[ c ]
   let first-exits other patches with [(description = "PedestrianExit" or description = "CarExit" or description = "CarEntrance" or description = "Street") and distance c > 0]
   let fe min-one-of first-exits [distance c]
   report fe
end

to-report set-campus-exit[p]
  let campus-exits other patches with [(description = "PedestrianExit" or description = "CarExit" or description = "CarEntrance")]
  let ce min-one-of campus-exits [distance p]
  report ce
end

to walk
  let ohead heading
  ask self [check-if-pedestrian-steer]
   move-forward-pedestrian
  ;if not any? cars-on patch-ahead 1 [fd speed]
  set heading ohead
end

to move-forward-pedestrian
  ;ifelse any? cars in-cone 2 90
  ;[set speed speed - 0.02]
  ;[set speed 0.05]
  fd speed
end

to check-if-pedestrian-steer
  if any? cars-on patch-ahead 1 or any? cars-on patch-ahead 2
  [lt 90]
  if any? cars-on patch-right-and-ahead 20 1
  [lt 90]
  if any? cars-on patch-right-and-ahead 20 1
  [rt 90]
end

to check-if-pedestrian-exit
  if [description] of patch-here = "CarExit" or [description] of patch-here = "PedestrianExit" or  [description] of patch-here = 0
  [
    die
  ]
end



;;------------------------
;; Funciones de salidas de vehículos:
;;------------------------
;;to init-vSalidas
 ;; let exit-patches patches with [gis:intersects? self salidas-cars-dataset]
 ;;  ask exit-patches [sprout-vSalidas 1]
;;end
@#$#@#$#@
GRAPHICS-WINDOW
455
10
2875
2431
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
242
777
305
810
NIL
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

BUTTON
242
737
305
770
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
17
10
240
43
percentage-occupation-parking
percentage-occupation-parking
0.1
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
16
48
194
81
occupation-street
occupation-street
0
100
57.0
1
1
NIL
HORIZONTAL

SLIDER
14
84
212
117
occupation-buildings
occupation-buildings
0
10000
2000.0
500
1
NIL
HORIZONTAL

SLIDER
14
124
186
157
desesperation
desesperation
1
60
30.0
1
1
NIL
HORIZONTAL

SWITCH
16
266
185
299
entrances-are-exits
entrances-are-exits
1
1
-1000

SLIDER
13
161
246
194
acceleration
acceleration
0.001
0.01
0.004
0.001
1
NIL
HORIZONTAL

SLIDER
13
203
239
236
deceleration
deceleration
0.01
0.1
0.01
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## ¿DE QUÉ SE TRATA?

(una descripción general de lo que el modelo trata de modelar o explicar)

## ¿CÓMO FUNCIONA?

(qué reglas usan los agentes para orginar el funcionamiento del modelo)

## ¿CÓMO USARLO?

(cómo usar el modelo, incluye una descripción de cada uno de los controles en la interfaz)

## ¿QUÉ TOMAR EN CUENTA?

(cosas que debe tener en cuenta el usuario al ejecutar el modelo)

## ¿QUÉ PROBAR?

(sugerencias para el usuario sobre qué pruebas realizar (mover los "sliders", los "switches", etc.) con el modelo)

## EXTENDIENDO EL MODELO

(sugerencias sobre cómo realizar adiciones o cambios en el código del modelo para hacerlo más complejo, detallado, preciso, etc.)

## CARACTERÍSTICAS NETLOGO

(características interesantes o inusuales de NetLogo que usa el modelo, particularmente de código; o cómo se logra implementar características inexistentes)

## MODELOS RELACIONADOS 

(otros modelos de interés disponibles en la Librería de Modelos de NetLogo o en otros repositorios de modelos)

## CRÉDITOS AND REFERENCIAS

(referencia a un URL en Internet si es que el modelo tiene una, así como los créditos necesarios, citas y otros hipervínculos)

## ODD - ESPECIFICACIÓN DETALLADA DEL MODELO

## Título
(nombre del modelo)

## Autores
(nombre de los autores del modelo)

## Visión
## 1  Objetivos:
( 1.1  )
## 2  Entidades, variables de estado y escalas:
( 2.1 ) 
## 3  Visión del proceso y programación:
( 3.1  )

## Conceptos del diseño
## 4  Propiedades del modelo:
##  4.1  Básicas:
()
##  4.2  Emergentes:
()
##  4.3  Adaptabilidad:
()
##  4.4  Metas:
()
##  4.5  Aprendizaje:
()
##  4.6  Predictibilidad:
()
##  4.7  Sensibilidad:
()
##  4.8  Interacciones:
()
##  4.9  Estocasticidad:
()
##  4.10  Colectividades:
()
##  4.11  Salidas:
()
## Detalles
##  5  Inicialización:
()
##  6  Datos de entrada:
()
##  7  Submodelos:
()
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

banana
false
0
Polygon -7500403 false true 25 78 29 86 30 95 27 103 17 122 12 151 18 181 39 211 61 234 96 247 155 259 203 257 243 245 275 229 288 205 284 192 260 188 249 187 214 187 188 188 181 189 144 189 122 183 107 175 89 158 69 126 56 95 50 83 38 68
Polygon -7500403 true true 39 69 26 77 30 88 29 103 17 124 12 152 18 179 34 205 60 233 99 249 155 260 196 259 237 248 272 230 289 205 284 194 264 190 244 188 221 188 185 191 170 191 145 190 123 186 108 178 87 157 68 126 59 103 52 88
Line -16777216 false 54 169 81 195
Line -16777216 false 75 193 82 199
Line -16777216 false 99 211 118 217
Line -16777216 false 241 211 254 210
Line -16777216 false 261 224 276 214
Polygon -16777216 true false 283 196 273 204 287 208
Polygon -16777216 true false 36 114 34 129 40 136
Polygon -16777216 true false 46 146 53 161 53 152
Line -16777216 false 65 132 82 162
Line -16777216 false 156 250 199 250
Polygon -16777216 true false 26 77 30 90 50 85 39 69

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
Polygon -7500403 true true 135 285 195 285 270 90 30 90 105 285
Polygon -7500403 true true 270 90 225 15 180 90
Polygon -7500403 true true 30 90 75 15 120 90
Circle -1 true false 183 138 24
Circle -1 true false 93 138 24

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
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
