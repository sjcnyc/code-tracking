Set-Alias ?: Invoke-Ternary -Option AllScope
filter Invoke-Ternary {
   param
   (
      [scriptblock]
      $decider,
      [scriptblock]
      $ifTrue,
      [scriptblock]
      $ifFalse
   )

   if (&$decider) {
      &$ifTrue
   }
   else {
      &$ifFalse 
   }
}

1..10 | ?: { $_ -gt 5 } { "Greater than 5 - $($_)" } { "Not greater than 5 - $($_)"}