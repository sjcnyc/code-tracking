$data = @"
ID	Name	State	Favourite animal
1	John	Oregon	Dog
1	John	Oregon	Bee
1	John	Oregon	Orangutan
2	Kyle	California	Turtle
2	Kyle	California	Iguana
2	Kyle	California	Gecko
3	Benjamin	Maryland	Red panda
3	Benjamin	Maryland	Snail
4	Nathan	Maine	Koala
5	Oliver	Tennessee	Owl
"@

$data = $data | ConvertFrom-Csv -Delimiter "`t"

$data = $data | Group-Object "ID"

$groupedData = @()

foreach ($record in $data) {

    $groupedData += [PSCustomObject]@{

        "ID"                = $record.group."ID" | Select-Object -Unique
        "Name"              = $record.group."Name" | Select-Object -Unique
        "State"             = $record.group."State" | Select-Object -Unique
        "Favourite animals" = $record.group."Favourite animal"
    }
}