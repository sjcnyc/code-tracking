$cred = Get-Credential -UserName "admSConnea-azr@SonyMusicEntertainment.onmicrosoft.com" -Message "Credential"

Connect-MsolService -Credential $cred

$users = @"
Tara.Bruh@sonymusic.com
Kobie.Brown@sonymusic.com
Kevin.Brenneman@sonymusic.com
Stuart.Bondell@sonymusic.com
susan.annarumma@sonymusic.com
carina.paz@sonymusic.com
debbie.richard.esroyalties@sonymusic.com
ian.dee.esroyalties@sonymusic.com
ryan.vasta@sonymusic.com
Irene.Sourlis@sonymusic.com
matthew.smith@sonymusic.com
Toby.Silver@sonymusic.com
sarah.sieminski@sonymusic.com
Peter.Shershin@sonymusic.com
Lindy.Sevier@sonymusic.com
Michelle.Sangenito@sonymusic.com
john.rybicki@sonymusic.com
aneil.sahota@sonymusic.com
nathaniel.rosenzweig@sonymusic.com
Jose.Rogel@sonymusic.com
john.roberts@sonymusic.com
juana.rivera@sonymusic.com
yvonne.penzakov@sonymusic.com
jesse.mosello@sonymusic.com
amy.modell@sonymusic.com
Susan.Meisel@sonymusic.com
Andre.Martindale@sonymusic.com
marc.makowski@sonymusic.com
alex.livadas@sonymusic.com
Michelle.LaMaison@sonymusic.com
eugene.koenig@sonymusic.com
Steve.Kenton@sonymusic.com
Belinda.Kai@sonymusic.com
kelly.haggerty@sonymusic.com
Perry.Guzzi@sonymusic.com
robin.gordon@sonymusic.com
jaimie.glover@sonymusic.com
Corey.Foncette@sonymusic.com
robert.faulstich@sonymusic.com
Ali.Evans@sonymusic.com
Marisa.DiLemme@sonymusic.com
John.DeSantis@sonymusic.com
Rachel.Deguzman@sonymusic.com
ellie.davidson@sonymusic.com
james.colson@sonymusic.com
jessica.chan@sonymusic.com
alli.champagne@sonymusic.com
Adele.Cerniglia@sonymusic.com
jazmin.azize@sonymusic.com
corey.anderson@sonymusic.com
alfredo.torres.peak@sonymusic.com
carlos.tolentino.citadelny@sonymusic.com
mackenzie.tsalickis.sme@sonymusic.com
jorge.ocampo.peak@sonymusic.com
sean.connealy.peak@sonymusic.com
stephanie.yu@sonymusic.com
Gary.Wong@sonymusic.com
melissa.yermes@sonymusic.com
ronnie.tuchman@sonymusic.com
Lisa.Trinchillo@sonymusic.com
Eric.Taylor@sonymusic.com
michael.spinelli@sonymusic.com
Mark.Springer@sonymusic.com
roger.skelton@sonymusic.com
julie.shapiro@sonymusic.com
jeffrey.schulberg@sonymusic.com
Michelle.Ryang@sonymusic.com
andrew.ross@sonymusic.com
nancy.roof@sonymusic.com
Michael.Roberson@sonymusic.com
Kim.Rappaport@sonymusic.com
christina.osborn@sonymusic.com
jim.olsen@sonymusic.com
megan.blitstein@sonymusic.com
jeff.monachino@sonymusic.com
Beth.Miller@sonymusic.com
ron.mirro@sonymusic.com
Deirdre.McDonald@sonymusic.com
Jono.Medwed@sonymusic.com
Vinnie.Maressa@sonymusic.com
Nancy.Marcus.Seklir@sonymusic.com
Angie.Magill@sonymusic.com
wade.leak@sonymusic.com
david.jacoby@sonymusic.com
Ashley.Johnson@sonymusic.com
Karen.Hope@sonymusic.com
Heidi.Herman@sonymusic.com
Jason.Heller@sonymusic.com
Jerome.Hagel@sonymusic.com
Sarah.Greenwood@sonymusic.com
brian.goldberg@sonymusic.com
Jennifer.Goodman@sonymusic.com
josh.green@sonymusic.com
dalia.glickman@sonymusic.com
andrea.finkelstein@sonymusic.com
Rose.Evans@sonymusic.com
Damon.Ellis@sonymusic.com
mark.dillon@sonymusic.com
bekah.connolly@sonymusic.com
David.Castagna@sonymusic.com
caitlin.oliveira@sonymusic.com
brian.boyle@sonymusic.com
kevin.beazer.peak@sonymusic.com
oliver.williams.sme@sonymusic.com
katya.shkrutz@sonymusic.com
john.isemann@sonymusic.com
catherine.crotty@sonymusic.com
amanda.dworetsky@sonymusic.com
tom.gnolfo@sonymusic.com
blair.lamendola@sonymusic.com
coral.rivera@sonymusic.com
christina.roberson.sme@sonymusic.com
lorraine.perez@sonymusic.com
brittany.kinsella@sonymusic.com
ellen.diner@sonymusic.com
bbanner@sonymusic.com
michaella.bloom@sonymusic.com
lauren.collins@sonymusic.com
rhett.butler@sonymusic.com
marilyn.monroe@sonymusic.com
ava.gardner@sonymusic.com
marty.mcfly@sonymusic.com
luke.cage@sonymusic.com
lizzet.senti@sonymusic.com
barry.fiedel@sonymusic.com
"@ -split [environment]::NewLine

$grpObjId = (Get-MsolGroup -ObjectId "988fe6c3-b130-4f4b-92c8-9cf82bd9168b").ObjectId

foreach ($user in $users) {

  $usrObjId = (Get-MsolUser -UserPrincipalName $user).ObjectId

  Add-MsolGroupMember -GroupObjectId $grpObjId -GroupMemberObjectId $usrObjId

}