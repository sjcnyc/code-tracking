<###############################################
	Variables
################################################>

$MyDir = Split-Path $MyInvocation.MyCommand.Definition
. "$MyDir\OU-Visio.ps1"
$WarningPreference='SilentlyContinue'

# load Quest Snapin-Module
Import-Module (get-pssnapin Quest.ActiveRoles.ADManagement -Registered).ModuleName

<###############################################
	Functions
################################################>

function connect-visioobject 
{
   param
   (
     [Object]
     $firstObj,

     [Object]
     $secondObj
   )
 
 $shpConn = $pagObj.Drop($pagObj.Application.ConnectorToolDataObject, 0, 0) 
 #// Connect its Begin to the 'From' shape:
 $connectBegin = $shpConn.CellsU('BeginX').GlueTo($firstObj.CellsU('PinX'))     
 #// Connect its End to the 'To' shape:
 $connectEnd = $shpConn.CellsU('EndX').GlueTo($secondObj.CellsU('PinX'))
 }

function add-visioobject 
{
   param
   (
     [Object]
     $mastObj,

     [Object]
     $item,

     [Object]
     $x,

     [Object]
     $y
   )
      
 Write-Host "Adding $item"    
 # Drop the selected stencil on the active page, with the coordinates x, y      
 $shpObj = $pagObj.Drop($mastObj, $x, $y)     
 # Enter text for the object      
 $shpObj.Text = $item
 #Return the visioobject to be used
 return $shpObj
 }

function New-VisioDocument 
{
   param
   (
     [Object]
     $visible
   )

$AppVisio = New-Object -ComObject Visio.Application
$AppVisio.Visible = $visible
$docsObj = $AppVisio.Documents
$DocObj = $docsObj.Add('ActDir_M.vst')

$pagsObj = $AppVisio.ActiveDocument.Pages
$pagObj = $pagsObj.Item(1)

$AppVisio
}

function recOUStructure 
{
   param
   (
     [Object]
     $item,

     [Object]
     $parent
   )

Write-Host $item
$ous = Get-QADObject -Type 'organizationalUnit' -SearchScope OneLevel -SearchRoot $item
if ($ous)
{
	foreach($ou in $ous)
	{
		$accessList = Get-QADPermission -Identity $ou.ToString() -WarningAction $WarningPreference -Allow
		$x += 0.3
		$object = add-visioobject $OUItem $ou.Name $x $y
		if ($accessList) {
			Foreach ($shape in $object.Shapes) {$shape.Cells('FillForegnd').FormulaU = 'RGB(255,0,0)'}
			$notiz = $NotizItem.Masters.ItemU('Box Callout')
			
			$f = $pagObj.DropCallout($notiz, $object)
			$f.CellsSRC($visSectionCharacter, 0, $visCharacterSize).FormulaU = '6 pt'
			$f.CellsSRC($visSectionParagraph, 0, $visHorzAlign).FormulaU = '0'
			$f.CellsSRC($visSectionObject, $visRowText, $visTxtBlkVerticalAlign).FormulaU = '0'
			$f.CellsSRC($visSectionObject, $visRowFill, $visFillForegnd).FormulaU = 'THEMEGUARD(MSOTINT(THEME("AccentColor4"),80))'
						
			$f.Text = ''
						
			Foreach ($access in $accessList) {
				$zeile = $access.Account.Name + ' | ' + $access.ApplyToDisplay + ' | ' + $access.RightsDisplay + "`n"
				$f.Text += $zeile
			}
			$f.Text = $f.Text.Substring(0,$f.Text.Length - 1)
			$f.CellsU('Width').Formula = 'MAX(TEXTWIDTH(theText), 8 * Char.Size)'
			$f.CellsU('PinX').FormulaU = '0'
			$f.CellsU('PinY').FormulaU = '0'
		
			$color = $Host.UI.RawUI.ForegroundColor
			$Host.UI.RawUI.ForegroundColor = 'cyan'
			$accessList
		 	$Host.UI.RawUI.ForegroundColor = $color
		}
		connect-visioobject $parent $object
		$y += 0.3
		$pagObj.PageSheet.CellsSRC($visSectionObject, $visRowPageLayout, $visPLOPlaceStyle).FormulaForceU = '7'
		$pagObj.PageSheet.CellsSRC($visSectionObject, $visRowPageLayout, $visPLORouteStyle).FormulaForceU = '3'
		$pagObj.Layout()
		recOUStructure $ou $object
	}
}
}


<###############################################
	MAIN
################################################>

# Definitions
$VisioDocu = New-VisioDocument $true
$pagObj = $VisioDocu.ActiveDocument.Pages.Item(1)

$domainItem = $VisioDocu.Documents.Item('ADO_M.vss').Masters.ItemU('Domain')
$OUItem = $VisioDocu.Documents.Item('ADO_M.vss').Masters.ItemU('Organizational unit')
$NotizItem = $VisioDocu.Documents.OpenEx($VisioDocu.GetBuiltInStencilFile($visBuiltinStencilCallouts, $visMSDefault), $visOpenHidden)

# set Root
$root = add-visioobject $domainItem 'domainname.com'

# LOOP OU-structure
recOUStructure (Get-QADRootDSE).DefaultNamingContext $root

# Set Layout
$pagObj.PageSheet.CellsSRC($visSectionObject, $visRowPageLayout, $visPLOPlaceStyle).FormulaForceU = '7'
$pagObj.PageSheet.CellsSRC($visSectionObject, $visRowPageLayout, $visPLORouteStyle).FormulaForceU = '3'
$pagObj.Layout()
$pagObj.ResizeToFitContents()

# Reset coordinates of all CallOuts
Foreach ($id in $pagObj.GetCallouts(0)) {
	$pagObj.Shapes.ItemFromID($id).CellsU('PinX').FormulaU = 'CALLOUTTARGETREF()!PinX + 2'
	$pagObj.Shapes.ItemFromID($id).CellsU('PinY').FormulaU = 'CALLOUTTARGETREF()!PinY + 1'
	$pagObj.Shapes.ItemFromID($id).SendToBack()
}

$Background = $VisioDocu.Documents.OpenEx($VisioDocu.GetBuiltInStencilFile($visBuiltinStencilBackgrounds, $visMSDefault), $visOpenHidden)
$nil = $pagObj.Drop($Background.Masters.ItemU('Vertical Gradient'), 4.133858, 5.850394)
$Titel = $VisioDocu.Documents.OpenEx($VisioDocu.GetBuiltinStencilFile($visBuiltinStencilBorders, $visMSDefault), $visOpenHidden)
$Titel_drop = $pagObj.Drop($Titel.Masters.ItemU('Blocks'), 7.723097, 7.46063)
$pagObj.Layout()
$pagObj.ResizeToFitContents()