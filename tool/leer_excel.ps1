# Extrae el contenido de una hoja de un .xlsx a texto plano.
#
# Sirve para el escenario V10 de quickstart.md: comparar lo que la app calcula
# contra el plan de referencia del entrenador.
#
# Uso:  powershell -File tool/leer_excel.ps1 -Ruta "<archivo.xlsx>" -Hoja <n>

param(
  [Parameter(Mandatory = $true)][string]$Ruta,
  [Parameter(Mandatory = $true)][int]$Hoja
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = [System.IO.Compression.ZipFile]::OpenRead($Ruta)

function Leer-Entrada($zip, $nombre) {
  $entrada = $zip.Entries | Where-Object { $_.FullName -eq $nombre }
  if (-not $entrada) { return $null }
  $lector = New-Object System.IO.StreamReader($entrada.Open())
  $texto = $lector.ReadToEnd()
  $lector.Close()
  return $texto
}

# Cadenas compartidas: las celdas de texto guardan un indice a esta tabla.
$compartidas = @()
$xmlCompartidas = Leer-Entrada $zip 'xl/sharedStrings.xml'
if ($xmlCompartidas) {
  $doc = [xml]$xmlCompartidas
  foreach ($si in $doc.sst.si) {
    if ($si.t -is [string]) {
      $compartidas += $si.t
    } elseif ($si.t.'#text') {
      $compartidas += $si.t.'#text'
    } else {
      # Texto con formato mixto: se concatenan los tramos.
      $compartidas += (($si.r | ForEach-Object {
        if ($_.t -is [string]) { $_.t } else { $_.t.'#text' }
      }) -join '')
    }
  }
}

$xmlHoja = Leer-Entrada $zip "xl/worksheets/sheet$Hoja.xml"
$zip.Dispose()

if (-not $xmlHoja) {
  Write-Error "No se encontro la hoja $Hoja"
  exit 1
}

$doc = [xml]$xmlHoja
foreach ($fila in $doc.worksheet.sheetData.row) {
  $celdas = @()
  foreach ($celda in $fila.c) {
    $valor = ''
    if ($celda.t -eq 's') {
      $indice = [int]$celda.v
      if ($indice -lt $compartidas.Count) { $valor = $compartidas[$indice] }
    } elseif ($celda.v) {
      $valor = $celda.v
    } elseif ($celda.'is'.t) {
      $valor = $celda.'is'.t
    }
    if ($valor -ne '') { $celdas += "$($celda.r)=$valor" }
  }
  if ($celdas.Count -gt 0) {
    Write-Output ("[$($fila.r)] " + ($celdas -join ' | '))
  }
}
