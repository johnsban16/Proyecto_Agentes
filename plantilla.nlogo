;;*************************
;; DEFINICIÓN DE VARIABLES:
;;*************************
extensions [gis profiler]

breed [vehiculos vehiculo]
breed [peatones peaton]
;;breed [vSalidas vSalida]
breed [pSalidas pSalida]


globals ;; Para definir las variables globales.
[
  aceras-dataset
  calles-dataset
  edificios-dataset
  otros-dataset
  parqueos-dataset
  propiedades-dataset
  salidas-peatones-dataset
  salidas-vehiculos-dataset
  entradas-vehiculos-dataset
  intersecciones-dataset
  carriles-dataset

  ;;Patches que intersecan a los poligonos
  aceras-patchset
  calles-patchset
  edificios-patchset
  otros-patchset
  propiedades-patchset
  parqueos-patchset
  salidas-peatones-patchset
  salidas-vehiculos-patchset
  entradas-vehiculos-patchset
  intersecciones-patchset
  carriles-patchset
]
turtles-own ;; Para definir los atributos de las tortugas.
[]

patches-own ;; Para definir los atributos de las parcelas.
[
  coverage
  descripcion
  ocupacion
]

;;********************
;; variables de breeds
;;********************


vehiculos-own
[
  velocidad
]

peatones-own
[
]


;;**************************************
;; INICIALIZACIÓN DE VARIABLES GLOBALES:
;;**************************************

to init-globals ;; Para darle valor inicial a las variables globales.

end

;;**********************
;; FUNCIONES PRINCIPALES
;;**********************

to setup ;; Para inicializar la simulación.
  ca           ;; Equivale a clear-ticks + clear-turtles + clear-patches +
               ;; clear-drawing + clear-all-plots + clear-output.
  set-patch-size 10
  ;Cargar las coordenadas de los shapefiles
  setup-geo-data
  init-globals ;; Para inicializar variables globales.
  intersecar-pacthes-con-poligonos
  ;; Para crear tortugas e inicializar tortugas y parcelas además.
  ask patches
  [
    init-patch
  ]
  init-peatones
  init-vehiculos
  reset-ticks  ;; Para inicializar el contador de ticks.
end

to go ;; Para ejecutar la simulación.
    ;profiler:start
  ask vehiculos [drive]
  tick
  actualizar-salidas
  if ticks >= 3000  ;; En caso de que la simulación esté controlada por cantidad de ticks.
    [stop]
 ; profiler:stop
 ; print profiler:report  ;; view the results
 ; profiler:reset         ;; clear the data
end

;;*******************************
;; Otras funciones globales:
;;*******************************

to actualizar-salidas ;; Para actualizar todas las salidas del modelo.
end

to setup-geo-data
  set aceras-dataset gis:load-dataset "data/ACERAS_RodrigoFacio.shp"
  set calles-dataset gis:load-dataset "data/CALLES_RodrigoFacio.shp"
  set edificios-dataset gis:load-dataset "data/EDIFICIOS_RodrigoFacio.shp"
  set otros-dataset gis:load-dataset "data/OTROS_RodrigoFacio.shp"
  set parqueos-dataset gis:load-dataset "data/PARQUEOS_RodrigoFacio.shp"
  set propiedades-dataset gis:load-dataset "data/PROPIEDADES_RodrigoFacio.shp"
  set salidas-peatones-dataset gis:load-dataset "data/SALIDAS_P.shp"
  set salidas-vehiculos-dataset gis:load-dataset "data/SALIDAS_V.shp"
  set entradas-vehiculos-dataset gis:load-dataset "data/ENTRADAS_V.shp"
  set intersecciones-dataset gis:load-dataset "data/INTERSECCIONES_CALLES.shp"
  set carriles-dataset gis:load-dataset "data/CARRILES.shp"

  ;Crear el "mundo"
  gis:set-world-envelope (gis:envelope-union-of (gis:envelope-of aceras-dataset)
                                                (gis:envelope-of calles-dataset)
                                                (gis:envelope-of edificios-dataset)
                                                (gis:envelope-of otros-dataset)
                                                (gis:envelope-of parqueos-dataset)
                                                (gis:envelope-of propiedades-dataset)
                                                (gis:envelope-of salidas-peatones-dataset)
                                                (gis:envelope-of salidas-vehiculos-dataset)
                                                (gis:envelope-of entradas-vehiculos-dataset)
                                                (gis:envelope-of intersecciones-dataset)
                                                (gis:envelope-of carriles-dataset))
  foreach gis:feature-list-of propiedades-dataset
  [
    gis:set-drawing-color green
    gis:fill propiedades-dataset 1.0
  ]

  foreach gis:feature-list-of parqueos-dataset
  [
    gis:set-drawing-color 2
    gis:fill parqueos-dataset 1.0
  ]

  foreach gis:feature-list-of calles-dataset
  [
    gis:set-drawing-color gray
    gis:fill calles-dataset 1.0
  ]

  foreach gis:feature-list-of aceras-dataset
  [
    gis:set-drawing-color 86
    gis:fill aceras-dataset 1.0
  ]

  foreach gis:feature-list-of edificios-dataset
  [
    gis:set-drawing-color 73
    gis:fill edificios-dataset 1.0
  ]

  foreach gis:feature-list-of otros-dataset
  [
    gis:set-drawing-color 73
    gis:fill otros-dataset 1.0
  ]

   foreach gis:feature-list-of salidas-peatones-dataset
  [
    gis:set-drawing-color brown
    gis:fill salidas-peatones-dataset 1.0
  ]

  foreach gis:feature-list-of salidas-vehiculos-dataset
  [
    gis:set-drawing-color 125
    gis:fill salidas-vehiculos-dataset 1.0
  ]
  foreach gis:feature-list-of entradas-vehiculos-dataset
  [
    gis:set-drawing-color 105
    gis:fill entradas-vehiculos-dataset 1.0
  ]
  foreach gis:feature-list-of intersecciones-dataset
  [
    gis:set-drawing-color 9
    gis:fill intersecciones-dataset 1.0
  ]
 foreach gis:feature-list-of carriles-dataset
 [
   gis:set-drawing-color red
   gis:fill carriles-dataset 1.0
 ]
end

to intersecar-pacthes-con-poligonos
  gis:apply-coverage propiedades-dataset "DESCRIPCIO" coverage
  set propiedades-patchset patches with [coverage = "Propiedad"]
  ask propiedades-patchset [
    set descripcion "Propiedad"
  ]
  gis:apply-coverage aceras-dataset "DESCRIPCIO" coverage
  set aceras-patchset patches with [coverage = "Acera"]
  ask aceras-patchset [
    set descripcion "Acera"
  ]
  gis:apply-coverage calles-dataset "DESCRIPCIO" coverage
  set calles-patchset patches with [coverage = "Calle"]
  ask calles-patchset [
    set descripcion "Calle"
  ]
  gis:apply-coverage edificios-dataset "TIPO" coverage
  set edificios-patchset patches with [coverage = "Edificio"]
  ask edificios-patchset [
    set descripcion "Edificio"
  ]
  gis:apply-coverage parqueos-dataset "DESCRIPCIO" coverage
  set parqueos-patchset patches with [coverage = "Parqueo"]
  ask parqueos-patchset [
    set descripcion "Parqueo"
  ]
  gis:apply-coverage parqueos-dataset "CAPACIDAD" ocupacion
  gis:apply-coverage otros-dataset "TIPO" coverage
  set otros-patchset patches with [coverage = "Otro"]
  ask otros-patchset [
    set descripcion "Otros"
  ]
  gis:apply-coverage salidas-peatones-dataset "TIPO" coverage
  set salidas-peatones-patchset patches with [coverage = "SalidaPeaton"]
  ask salidas-peatones-patchset [
    set descripcion "SalidaPeaton"
  ]
  gis:apply-coverage salidas-vehiculos-dataset "TIPO" coverage
  set salidas-vehiculos-patchset patches with [coverage = "SalidaVehiculo"]
  ask salidas-vehiculos-patchset [
    set descripcion "SalidaVehiculo"
  ]
  gis:apply-coverage entradas-vehiculos-dataset "TIPO" coverage
  set entradas-vehiculos-patchset patches with [coverage = "EntradaVehiculo"]
  ask entradas-vehiculos-patchset [
    set descripcion "EntradaVehiculo"
  ]
  gis:apply-coverage carriles-dataset "TIPO" coverage
  set carriles-patchset patches with [coverage = "Carril"]
  ask carriles-patchset [
    set descripcion "Carril"
  ]
end



;;**********************
;; Funciones de patches:
;;**********************

to init-patch ;; Para inicializar una parcela a la vez.

end

to p-comportamiento-patch ;; Cambiar por nombre significativo de comportamiento de patch

end


;;****************************************
;; Funciones de breeds:
;;****************************************

;;------------------------
;; Funciones de vehiculos:
;;------------------------

to init-vehiculos
  create-vehiculos grado-ocupacion-parqueos
  [
    set color one-of base-colors
    set shape "car"
    set size 1.5
  ]
  ask vehiculos[
    if any? parqueos-patchset [move-to one-of calles-patchset]
  ]
end

to steer-without-lanes
  let ohead heading
  let rc 0
  let lc 0
  ;show "begin steer"
  while [[descripcion] of patch-ahead 3  != "Calle"]
  [
    if rc >= 18 [stop]
    ;show "derecha"
    set rc rc + 1
    rt 20
  ]
  let right-heading heading
  set heading ohead
  while [[descripcion] of patch-ahead 3 != "Calle"]
  [
    if lc >= 18 [stop]
    set lc lc + 1
    lt 20
  ]
  ;if rc = 18 or lc = 18 [die]
  if rc < lc
  [ set heading right-heading]

end

to steer
  let front-terrain patch-ahead 3
  ifelse any? patches in-radius 2 with [gis:intersects? self carriles-dataset]
  [
    ifelse [descripcion] of front-terrain != "Calle" and not gis:intersects? front-terrain carriles-dataset
    [
      lt 20
    ]
    [if gis:intersects? front-terrain carriles-dataset
      [rt 20]
    ]
  ]
  [
    ask self [steer-without-lanes]
  ]


end

to drive

  if [descripcion] of patch-ahead 3 != "Calle" or gis:intersects? patch-ahead 3 carriles-dataset
  [
    ;show "before steer"
    ask self [steer]
  ]

  ask self [check-for-intersection]
  ;if
  fd 1
end

to check-for-intersection
  let patch-right patch-right-and-ahead 90 2
  if gis:intersects? patch-right salidas-vehiculos-dataset
  [
    set heading towards patch-right
  ]
end


;;------------------------
;; Funciones de peatones:
;;------------------------

to init-peatones
  ;cambiar variable
  create-peatones grado-ocupacion-edificios
  [
    set color white
    set shape "person"
    set size 0.75
  ]
  ask peatones[
    if any? edificios-patchset [move-to one-of edificios-patchset]
  ]
end


;;------------------------
;; Funciones de salidas de vehículos:
;;------------------------
;;to init-vSalidas
 ;; let exit-patches patches with [gis:intersects? self salidas-vehiculos-dataset]
 ;;  ask exit-patches [sprout-vSalidas 1]
;;end
@#$#@#$#@
GRAPHICS-WINDOW
496
94
2514
2113
-1
-1
10.0
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
185
43
grado-ocupacion-parqueos
grado-ocupacion-parqueos
1
100
54.0
1
1
NIL
HORIZONTAL

SLIDER
16
48
185
81
grado-ocupacion-calle
grado-ocupacion-calle
0
100
51.0
1
1
NIL
HORIZONTAL

SLIDER
14
84
185
117
grado-ocupacion-edificios
grado-ocupacion-edificios
100
1500
1100.0
100
1
NIL
HORIZONTAL

SLIDER
14
124
186
157
desesperacion
desesperacion
0
100
50.0
1
1
NIL
HORIZONTAL

SWITCH
202
10
371
43
entradas-habilitadas
entradas-habilitadas
1
1
-1000

SLIDER
13
161
185
194
aceleracion
aceleracion
0.001
0.010
0.001
0.001
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
