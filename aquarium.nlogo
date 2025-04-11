;Maakt alle agents/turtles aan
breed [vissen vis]
breed [haaien haai]

;Voegt de variabelen van de haai agents toe
haaien-own [
  h_energie
  h_zwemenergie
  h_leeftijd
  h_sekse
]

;Voegt de variabelen van de vis agents toe
vissen-own [
  energie
  zwemenergie
  leeftijd
  sekse
  zuurstof
]

;Voegt de globale variablen toe
globals [
  percentageAlgen
  aantalVissen
  aantalHaaien
  gemiddeldeEnergieHaaien
  percentageGiftigeAlgen
]

;De functie om alles klaar te zetten
to setup
  clear-all ;Reset de wereld en alle monitors
  reset-ticks ;Reset de ticks
  ; Roept de verschillende setup dingen aan
  maak_algen
  maak_vissen
  maak_haaien
  bepaal_statistiek
end

;Main loop functie van de wereld
to go
  ask haaien [ ; Vraagt alle haai agents om de verschillende dingen te doen
    h_zwem
    h_eet
    if h_energie > 50 [
      h_plant_voort
    ]
  ]
  ask vissen [ ; Vraagt alle vis agents om de verschillende dingen te doen
    eet
    zwem
    if energie > 40 [
      plant_voort
    ]
  ]
  groei_algen ; Groeit alle algen
  if count vissen = 0 [ ; Als alle vissen dood zijn stopt de simulatie
    stop
  ]
  bepaal_statistiek ; Bepaald alle statistieken
  tick
end

; Maakt alle algen aan het begin aan functie
to maak_algen
  ask patches [ ; Vraagt alle patches
    ifelse random 100 < 25 ; 25% kans dat een patch groen wordt
    [
      set pcolor green
    ]
    [
      ifelse random 100 < 1 ; 1% kans dat de patches geel worden
      [
        set pcolor yellow
      ]
      [
        set pcolor blue ; Anders worden ze blauw
      ]
    ]
  ]
end

; Groei alle algen
to groei_algen
  ask patches [ ; Vraagt alle patches
    if count (neighbors with [pcolor = blue]) > 0 and percentageAlgen < 50  [ ; Checkt of er blauw patches als buren zijn, en of er minder 50% groene patches zijn
      ask one-of neighbors with [pcolor = blue] [ ; vraagt alle blauwe patches ernaast
        if random 100 < (percentageAlgen / 100) [
          set pcolor green
        ]
      ]
    ]
    ;Giftige algen, nemen groene algen over.
    if count (neighbors with [pcolor = green]) > 0 and percentageGiftigeAlgen < 5  [ ; Checkt of er groen patches als buren zijn, en of er minder 50% gele patches zijn
      ask one-of neighbors with [pcolor = green] [ ; Vraagt alle groene patches
        if random 100 < (percentageGiftigeAlgen / 100) [
          set pcolor yellow
        ]
      ]
    ]
  ]
end

; Maakt alle vissen aan functie
to maak_vissen
  create-vissen 100 [ ; Maakt 100 vissen
    setxy random-xcor random-ycor ; Zet random coordinaten van de vis
    set energie 10 + random 61 ; Zet de energie random
    set shape "fish" ; Zet de vorm van een vis
    set size 2 ; Zet de groote
    set zwemenergie size ; Zet de zwemenergie kosten het zelfde als de groote
    set heading 90 ; zet welke kant de vis op gaat
    set leeftijd 0 ; zet de leeftijd
    set sekse random(2) ; Kiest man (1) of vrouw (0)
    
    ifelse sekse = 0 [ ; zet de kleur voor man of vrouw
      set color pink
    ][
      set color sky
    ]
  ]
end

; Maakt alle haaien aan functie
to maak_haaien
  create-haaien 12 [ ; Maakt 12 haaien
    setxy random-xcor random-ycor
    set h_energie 20 + random 61
    set shape "shark"  ; Zet de vorm van een haai
    set size 2
    set h_zwemenergie size
    set heading 90
    set h_leeftijd 0
    set h_sekse random(2)

    ifelse h_sekse = 0 [
      set color magenta - 3
    ][
      set color cyan - 3
    ]
  ]
end

;De zwem functie voor de vissen
to zwem
  ; Zet random bewegings snelheden
  rt random 2
  lt random 2
  fd 1 + random 2 
  set energie energie - zwemenergie ; zorgt ervoor dat het energie kost om te zwemmen
  set zuurstof zuurstof - 2 ; zorgt ervoor dat het zuurstof kost om te zwemmen
  
  ; Zorgt ervoor dat de vissen dood gaan wanneer nodig
  if energie <= 0 [
    die
  ]
  if leeftijd > 80 [
    die
  ]
  if zuurstof <= 0[
    die
  ]
end

;Zwem functie voor de haaien, werkt hetzelfde als de vissen
to h_zwem
  rt random 2
  lt random 2
  fd 2 + random 3
  set h_energie h_energie - h_zwemenergie
  if h_energie <= 0 [
    die
  ]
  if h_leeftijd > 100 [
    die
  ]
end

;De eet functie voor de vissen
to eet
  if pcolor = green [ ; als een vis op een groene patch komt krijgt die energie
    set energie energie + energie_uit_algen
    groei
    set pcolor blue
  ]
  if pcolor = yellow[ ; als de vis op een gele patch komt is er een 10% kans dat die dood gaat anderes kost het energie
    set pcolor blue
    ifelse random 100 < 10[
      die
    ][
      set energie energie - 10
    ]
  ]
  if pcolor = blue[ ; krijgt zuurstof van blauwe patches
    set zuurstof zuurstof + 5
  ]
end

;De eet functie van de haaien
to h_eet
  if any? vissen in-radius 2 [ ; checkt of er vissen in een 2 patch radius zijn
    let prooi one-of vissen in-radius 2 ; kiest een van de vissen in de radius 2, slaat op in lokale variabel
    set h_energie h_energie + energie_uit_vissen ; krijgt energie van de vissen
    h_groei ; groeit de haai
    ask prooi [ die ] ; verwijdert de vis
  ]
end

; Groeit de vis
to groei
  if energie > (2 * zwemenergie) [ ; als de energie groter is dan 2 keer de zwem energie dan groeit de vis
    set zwemenergie 1 + leeftijd ; grotere zwem energie koste
    set leeftijd leeftijd + 1 ; hogere leeftijd
  ]
end

; Groeit de haai, doet inprincipe hetzelfde als de vis groei functie
to h_groei
  if h_energie > (2 * h_zwemenergie) [
    set h_zwemenergie 1 + h_leeftijd
    set h_leeftijd h_leeftijd + 1
  ]
end

; Plant de vis voor
to plant_voort
 if sekse = 0 [ ; checkt of de vis een vrouw is
    let partner one-of vissen in-radius 1 with [sekse = 1 and energie > 30] ; lokale variabel voor een van de mannelijke vissen met genoeg energie in een 1 patch radius
    if partner != nobody and energie > 30 [ ; checkt of de partner niet leeg is
      hatch 2 [ ; krijgt 2 vissen
        ; zet all start waardens van de nieuwe vissen
        set energie 20
        set shape "fish"
        set sekse random 2
        set leeftijd 0
        ifelse sekse = 0 [
          set color pink
        ][
          set color sky
        ]
        set size 2
        set zwemenergie size
      ]
      set energie energie - 30 ; kost energie voor de vis
      ask partner [ set energie energie - 30 ] ; kost energie voor de partner vis
    ]
  ]
end

; Plant de haai voor, werkt in principe hetzelfde als de vis plant voor functie
to h_plant_voort
 if h_sekse = 0 and h_leeftijd > 1[
    let partner one-of haaien in-radius 5 with [h_sekse = 1 and h_energie > 30 and h_leeftijd > 1]
    if partner != nobody and h_energie > 30 [
      hatch 1[
        set h_energie 20 + random(61)
        set shape "shark"
        set h_sekse random 2
        set h_leeftijd 0
        ifelse h_sekse = 0 [
        set color magenta - 3
        ][
          set color cyan - 3
        ]
        set size 2
        set h_zwemenergie size
      ]
      set h_energie h_energie - 30
      ask partner [ set h_energie h_energie - 30 ]
    ]
  ]
end
; bepaalt alle statistieken voor de monitors
to bepaal_statistiek
  set percentageAlgen count patches with [pcolor = green] / count patches * 100
  set percentageGiftigeAlgen count patches with [pcolor = yellow] / count patches * 100
  set aantalVissen count vissen
  set aantalHaaien count haaien
end
