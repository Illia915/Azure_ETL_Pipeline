Get-Content .env | Foreach-Object {
    $name, $value = $_.split('=')
    Set-Content "env:$name" $value
}
databricks bundle validate 