function Print-TextToConsle([array]$text,[int]$delay, [int]$sleep) {
    Clear-Host
    do {
        $text = $text -split''
        $running = $true
        $text | ForEach-Object { Write-Host -Object $_ -NoNewline -ForegroundColor Green
            Start-Sleep -Milliseconds $sleep
            $running = $false
            }
       }
    while ($running)
  Start-Sleep -Seconds 5
  # Clear-Host
}

Print-TextToConsle -text "Loading snow subroutine........" -delay 100 -sleep 20
./snow.exe
Print-TextToConsle -text "Constructing WolframAlpha Christmas tree..." -delay 100 -sleep 20


$wolf = @"
PD = .5;
s[t_, f_] := t^.6 - f
dt[cl_, ps_, sg_, hf_, dp_, f_, flag_] :=
    Module[{sv, basePt},
           {PointSize[ps],
            sv = s[t, f];
            Hue[cl (1 + Sin[.02 t])/2, 1, .3 + sg .3 Sin[hf sv]],
            basePt = {-sg s[t, f] Sin[sv], -sg s[t, f] Cos[sv], dp + sv};
            Point[basePt],
           If[flag,
              {Hue[cl (1 + Sin[.1 t])/2, 1, .6 + sg .4 Sin[hf sv]], PointSize[RandomReal[.01]],
               Point[basePt + 1/2 RotationTransform[20 sv, {-Cos[sv], Sin[sv], 0}][{Sin[sv], Cos[sv], 0}]]},
              {}]
          }]

frames = ParallelTable[
                       Graphics3D[Table[{
                                         dt[1, .01, -1, 1, 0, f, True], dt[.45, .01, 1, 1, 0, f, True],
                                         dt[1, .005, -1, 4, .2, f, False], dt[.45, .005, 1, 4, .2, f, False]},
                                        {t, 0, 200, PD}],
                                  ViewPoint -> Left, BoxRatios -> {1, 1, 1.3}, 
                                  ViewVertical -> {0, 0, -1},
                                  ViewCenter -> {{0.5, 0.5, 0.5}, {0.5, 0.55}}, Boxed -> False,
                                  PlotRange -> {{-20, 20}, {-20, 20}, {0, 20}}, Background -> Black],
                       {f, 0, 1, .01}];
"@

Print-TextToConsle -text $wolf -delay 0 -sleep 5
Print-TextToConsle -text "IT WOULDN'T BE CHRISTMAS WITHOUT A POSH CHRISTMAS TREE!! :)" -delay 10 -sleep 10
 
 ./tree.gif