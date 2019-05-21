function Get-RandomPassword {
    param(
        $length = 20,
        $characters =
        'abcdefghkmnprstuvwxyzABCDEFGHKLMNPRSTUVWXYZ123456789!"§$%&/()=?*+#_'
    )
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs = ""
    [String]$characters[$random]
}