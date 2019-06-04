# Create directory if it doesnt already exist
$dest = "F:\Downloads\Ebook\Ebook_Technical\Microsoft\"
New-Item -ItemType Directory -Force -Path $dest

Import-Module BitsTransfer

# Uncomment the filetypes required
$filetype = "PDF"
#$filetype += "EPUB"
#$filetype += "MOBI"

$downLoadList = "http://ligman.me/2sZVmcG"
$bookList = Invoke-WebRequest $downLoadList

[string[]]$books = ""
$books = $bookList.Content.Split("`n")
$books = $books[1..($books.Length - 1)]

foreach ($book in $books) {
    try {$hdr = Invoke-WebRequest $book -Method Head }catch {$book | Out-File $dest"dead_links.log" -Append}
    $title = $hdr.BaseResponse.ResponseUri.Segments[-1]

    foreach ($dtd in $dtds| Where-Object {$filetype -match $title.Split('.')[1] }) {
        $title = [uri]::UnescapeDataString($title)
        $saveTo = Join-Path $dest $title
        Start-BitsTransfer -Source $book -Destination $saveTo
    }
}