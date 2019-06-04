$Notes = New-Object -TypeName psobject -Property @{
  REST    = 0
  GbelowC = 196
  A       = 220
  Asharp  = 233
  B       = 247
  C       = 262
  Csharp  = 277
  D       = 294
  Dsharp  = 311
  E       = 330
  F       = 349
  Fsharp  = 370
  G       = 392
  Gsharp  = 415
  AA      = 440
  AAsharp = 466
  BB      = 493
  CC      = 523
  CCsharp = 554
  DD      = 587
  DDsharp = 622
  EE      = 659
  FF      = 698
  FFsharp = 740
  GG      = 784
  GGsharp = 830
}
 
$Duration = New-Object -TypeName psobject -Property @{
  WHOLE     = 1600
  HALF      = 800
  QUARTER   = 400
  EIGHTH    = 200
  SIXTEENTH = 100
}
 
 
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.QUARTER)
[console]::beep($Notes.C, $Duration.HALF   )
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.QUARTER)
[console]::beep($Notes.D, $Duration.HALF   )
Start-Sleep -m $Duration.EIGHTH
[console]::beep($Notes.D, $Duration.EIGHTH )
[console]::beep($Notes.E, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
 
[console]::beep($Notes.E, $Duration.HALF)
Start-Sleep -m $Duration.EIGHTH
[console]::beep($Notes.E, $Duration.EIGHTH)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.HALF)
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.QUARTER)
[console]::beep($Notes.C, $Duration.HALF   )
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.EIGHTH )
[console]::beep($Notes.C, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.QUARTER)
[console]::beep($Notes.D, $Duration.HALF   )
Start-Sleep -m $Duration.QUARTER
[console]::beep($Notes.D, $Duration.EIGHTH )
 
 
[console]::beep($Notes.E, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.EIGHTH)
[console]::beep($Notes.DD, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.HALF)
[console]::beep($Notes.CC, $Duration.HALF)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.HALF)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.HALF)
 
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.EIGHTH)
[console]::beep($Notes.AA, $Duration.HALF)
Start-Sleep -m $Duration.EIGHTH
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.EIGHTH)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.EIGHTH)
[console]::beep($Notes.AA, $Duration.EIGHTH)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.HALF)
[console]::beep($Notes.CC, $Duration.HALF)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.HALF)
 
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.HALF)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.EIGHTH)
[console]::beep($Notes.AA, $Duration.HALF)
Start-Sleep -m $Duration.EIGHTH
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.EIGHTH)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.QUARTER)
[console]::beep($Notes.AA, $Duration.EIGHTH)
[console]::beep($Notes.AA, $Duration.EIGHTH)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.CC, $Duration.QUARTER)
[console]::beep($Notes.BB, $Duration.QUARTER)
[console]::beep($Notes.G, $Duration.QUARTER)
[console]::beep($Notes.F, $Duration.HALF)