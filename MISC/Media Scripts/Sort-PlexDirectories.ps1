$path = 'E:\media\movies'

foreach ($movie in(Get-ChildItem $path -Directory | Select-Object name, fullname)) {

    $filter = [regex]::match($movie.Name,'\(([^\)]+)\)').Groups[1].Value
    
    switch -Wildcard ($filter)
       { 
                 '193*'      {move-item $movie.FullName -destination "$path\_1930s and older" }
                 '194*'      {move-item $movie.FullName -destination "$path\_1940s"}
                 '195*'      {move-item $movie.FullName -destination "$path\_1950s"}
                 '196*'      {move-item $movie.FullName -destination "$path\_1960s"}
                 '197*'      {move-item $movie.FullName -destination "$path\_1970s"}
                 '198*'      {move-item $movie.FullName -destination "$path\_1980s"}
                 '199*'      {move-item $movie.FullName -destination "$path\_1990s"}
                 '200*'      {move-item $movie.FullName -destination "$path\_2000s"}
                 '201*'      {move-item $movie.FullName -destination "$path\_2010s"}                    
        } 
}