connect-graph

$users = @"
ievgen.salmin.intimetechnologies@sonymusic.com
rick.mohr.objectlab@sonymusic.com
justin.cortez@sonymusic.com
irina.beregovich.intimetechnologies@sonymusic.com
yuriy.ryabko.intimetechnologies@sonymusic.com
utkarsh.mishra.ahinfotech@sonymusic.com
rohan.mhamunkar.ahi@sonymusic.com
hariharan.palanivel.ahi@sonymusic.com
vijay.subramaniam@sonymusic.com
narhari.jagadle.ext@sonymusic.com
vinit.mokal.creo@sonymusic.com
vipin.kumar.ahi@sonymusic.com
alex.moldoveanu@sonymusic.com
colbert.xuan.reyktech@sonymusic.com
tom.koshy@sonymusic.com
raghavendra.bhagavath.ahinfotech@sonymusic.com
phani.venkata.ahi@sonymusic.com
matthew.spagnoli.ahinfotech@sonymusic.com
eldin.begovic.reyktech@sonymusic.com
uday.vallabhaneni.creo@sonymusic.com
someswara.rao.creo@sonymusic.com
rahulrajish.nathan.ahi@sonymusic.com
charlie.tang.itopia@sonymusic.com
surjit.sing.ahi@sonymusic.com
alem.zekic.reyktech@sonymusic.com
vitaliy.stefanchak.reyktech@sonymusic.com
joowon.park@sonymusic.com
chris.mollis@sonymusic.com
bohdan.lozinskyi.intimetechnologies@sonymusic.com
rebecca.wang.ext@sonymusic.com
brajesh.sahoo.infotechlimited@sonymusic.com
tatyana.savchenko.intimetechnologies@sonymusic.com
deepak.kumar.ahi@sonymusic.com
abhijeet.singh.ahi@sonymusic.com
shaquille.johnson.spantech@sonymusic.com
Vivek.Dutta.PRKConsulting@sonymusic.com
ryan.donovan.ahi@sonymusic.com
peter.salvione@sonymusic.com
jake.chadrow.reyktech@sonymusic.com
sindhu.sn.ahi@sonymusic.com
jamsheed.siyar@sonymusic.com
manuela.brice.asburymedia@sonymusic.com
kirill.stoletnev.intimetechnologies@sonymusic.com
subrahmanyuam.shastry.infotechlimited@sonymusic.com
Nathaniel.Lovett@sonymusic.com
sasikanth.alula.ahi@sonymusic.com
Vamsikrishna.Gollapudi@sonymusic.com
kiran.kumar.ahi@sonymusic.com
Victoria.Lowther@sonymusic.com
mithran.selvaraj.ahinfotech@sonymusic.com
oleksandr.sidelnykov.intimetechnologies@sonymusic.com
Markus.Kramme@sonymusic.com
sergiy.durov.intimetechnologies@sonymusic.com
philippe.charles@sonymusic.com
Matt.Carpenter.Asburymedia@sonymusic.com
Vivien.Leung@sonymusic.com
roraj01@sonymusic.com
rithwikreddy.koripelly.ext@sonymusic.com
dan.callahan.beaconhill@sonymusic.com
andriy.shynder.intimetechnologies@sonymusic.com
alex.zhovnuvaty.intimetechnologies@sonymusic.com
winfried.baier@sonymusic.com
petar.novakovic.reyktech@sonymusic.com
Tom.Haller.Hallertech@sonymusic.com
jennifer.segura@sonymusic.com
nalini.kariappa@sonymusic.com
abishal.mohan.ahi@sonymusic.com
vyacheslav.homenko.intimetechnologies@sonymusic.com
Mandar.Padsalgikar@sonymusic.com
momcilo.dejanovic.reyktech@sonymusic.com
anton.serozhechkin.intimetechnologies@sonymusic.com
soumya.giri.ahi@sonymusic.com
phani.pothiganti.ext@sonymusic.com
igor.potyomkin.reyktech@sonymusic.com
daniel.higgins.reyktech@sonymusic.com
vinodhan.Siranjeevi.ahinfotech@sonymusic.com
himanshu.sharma.ahi@sonymusic.com
serhii.hinzhul.intimetechnologies@sonymusic.com
greg.taylor.reyktech@sonymusic.com
ivan.larionov.intimetechnologies@sonymusic.com
AZ_SCIM_PagerDuty_Users
gadikota.sukanya.ahi@sonymusic.com
djordje.milosevic.reyktech@sonymusic.com
mohammed.haleem.reyktech@sonymusic.com
ravishankar.eswaran.ahinfotech@sonymusic.com
"@ -split [System.Environment]::NewLine
    <# Specify a list of distinct values #>

$GroupId = '7d009239-3255-45a5-844a-dc27b105a595'

foreach ($user in $users) {
    $GraphUser = Get-MgUser -UserId $user
    $UserId = $GraphUser.Id
    New-MgGroupMember -GroupId $GroupId -DirectoryObjectId $UserId
}

