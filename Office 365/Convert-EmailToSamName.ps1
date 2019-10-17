function Get-SamFromEmail {

    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [string]$InputCSV,
        [string]$OutputCSV,
        [string]$username
    )

    Import-Module -Name ActiveDirectory

    $result = New-Object System.Collections.ArrayList

    $props = @{
        Properties = @('SamAccountName', 'Mail')
    }


            $user = Get-ADUser -Filter { Mail -eq $username } @props -Server me.sonymusic.com | Select-Object $props.Properties

            $info = [pscustomobject]@{
                'originalName'    = $username
                'SamaccountaName' = $user.SamAccountName
                'Mail'            = $user.Mail
            }
            $null = $result.Add($info)

    $result #| Export-Csv $OutputCSV -NoTypeInformation -Append
}

$users =@"
alex.brody@redmusic.com
alicia.nelson@sonymusic.com
adam.poch@redmusic.com
abhijeet.shere.wns@sonymusic.com
angie.troici@sonymusic.com
kevin.beazer.peak@sonymusic.com
barbara.farley.citadelny@sonymusic.com
sangeeta.bhuyan@ap.sony.com
brian.sherman@sonymusic.com
beth.stopper@sonymusic.com
herman.calloway.citadelny@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
chena.life@sonymusic.com
thomas.colello@redmusic.com
cary.ryan@sonymusic.com
candice.surrency@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
carlos.tolentino.citadelny@sonymusic.com
debbie.eisen@rcarecords.com
donna.haynes@sonymusic.com
davidv.smith@sonymusic.com
david.steffens@pmgsonymusic.com
dan.tousignant@redmusic.com
eliana.espinosa@sonymusic.com
joseph.fasulo.citadelny@sonymusic.com
scott.finchler.itopia@sonymusic.com
"kelly.fitzgerald@sonymusic.com	"
jerry.flores.citadelny@sonymusic.com
carlos.gamboa.citadelny@sonymusic.com
askshay.ghosh.wns@sonymusic.com
gerry.kuster@rcarecords.com
Hallie.Swidler@sonymusic.com
imran.hussain.peak@sonymusic.com
babu.iismayil.itopia@sonymusic.com
joe.chernik@sonymusic.com
john.conway@sonymusic.com
john.graziani@sonymusic.com
joyce.lee@sonymusic.com
joyce.moyik@sonymusic.com
jacqueline.rottmann@sonymusic.com
karenjoy.deang.citadelny@sonymusic.com
karleen.esposito@sonymusic.com
akman@theorchard.com
keith.persaud@sonymusic.com
kathy.schubach@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
rachael.lee@sonymusic.com
lisa.grauso@sonymusic.com
lina.lozada@sonymusic.com
miguel.lopez@sonymusic.com
Lori.Weber@sonymusic.com
sagar.madhiboina.wns@sonymusic.com
sanskruti.margaj.wns@sonymusic.com
michael.botta@sonymusic.com
mike.gallagher@sonymusic.com
kaim.mulla.wns@sonymusic.com
neva.bray@sonymusic.com
cecile.nunez@sonymusic.com
bhavna.palav.wns@sonymusic.com
biswajit.parida.itopia@sonymusic.com
niko.petruzzella@sonymusic.com
patricia.jackson@sonymusic.com
peter.posimato@sonymusic.com
patty.schreiber@sonymusic.com
Parikshit.Sharma@ap.sony.com
phil.zaks@sonymusic.com
nikunj.rajgor.wns@sonymusic.com
rose.evans@sonymusic.com
shabista.rizvi.itopia@sonymusic.com
Robert.Kordisch@redmusic.com
ruben.robles@sonymusic.com
richard.sager@sonymusic.com
rick.sulling@sonymusic.com
shabarish.sasidharan.itopia@sonymusic.com
sunil.balkawade.wns@sonymusic.com
steve.bickerton@sonymusic.com
sharon.cardella@sonymusic.com
sue.danz@sonymusic.com
bharat.sharma.itopia@sonymusic.com
Srinivasan.Murugesan@ap.sony.com
emily.supercynski@sonymusic.com
scott.wood@sonymusic.com
alex.syner.citadelny@sonymusic.com
alec.tebbenhoff@sonymusic.com
terence.gonsalves@sonymusic.com
trish.lubonski@sonymusic.com
terry.mcgibbon@redmusic.com
tuesday.ryan-jones@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
vicki.snyder@sonymusic.com
osama.waseem.ums@sonymusic.com
gail.worthen@pmgsonymusic.com
al.lam@sonymusic.com
kevin.beazer.peak@sonymusic.com
sangeeta.bhuyan@ap.sony.com
brian.waslenko@sonymusic.com
herman.calloway.citadelny@sonymusic.com
lesley.callaghan@sonymusic.com
anne.marie.carducci@sonymusic.com
carrie.boyd@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
cleve.meikle@sonymusic.com
michelle.cordeiro@sonymusic.com
chris.shepherd@sonymusic.com
chris.smith@sonymusic.com
maria.dsouza@sonymusic.com
enza.sergi@sonymusic.com
emily.stiver@sonymusic.com
elaine.yam@sonymusic.com
joseph.fasulo.citadelny@sonymusic.com
scott.finchler.itopia@sonymusic.com
carlos.gamboa.citadelny@sonymusic.com
cynthia.gebrayel@sonymusic.com
imran.hussain.peak@sonymusic.com
babu.iismayil.itopia@sonymusic.com
joel.duchesne@sonymusic.com
jerry.flores@sonymusic.com
jd.parent@sonymusic.com
janet.tomkins@sonymusic.com
karenjoy.deang.citadelny@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
milijana.batricevic@sonymusic.com
biswajit.parida.itopia@sonymusic.com
nitin.patel_tcs@sonymusic.com
Parikshit.Sharma@sonymusic.com
paola.tataj@sonymusic.com
chakrabarti.rudradip@sonydadc.com
shabista.rizvi.itopia@sonymusic.com
shabarish.sasidharan.itopia@sonymusic.com
bharat.sharma.itopia@sonymusic.com
michael.daniluk@sonymusic.com
michael.daniluk@sonymusic.com
michael.daniluk@sonymusic.com
michael.daniluk@sonymusic.com
Srinivasan.Murugesan@ap.sony.com
alex.syner.citadelny@sonymusic.com
tony.ramnauth@sonymusic.com
trudy.sharples@sonymusic.com
kulwinder.singh.itopia@sonymusic.com
osama.waseem.ums@sonymusic.com
wendy.hoskins@sonymusic.com
yoko.king@sonymusic.com
"@ -split [environment]::NewLine

foreach ($user in $users) {
    Get-SamFromEmail -username $user | Export-Csv D:\Temp\users_for_mike2.csv -NoTypeInformation -Append
}