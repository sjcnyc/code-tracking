function test {
  $al=[System.Collections.ArrayList](1..10)

  #,$al # will return System.Collections.ArrayList
  $al # will return System.Object[]
}

(Test).GetType().FullName


 @(1,2,3,4).gettype()



$list = Write-Output banana apple green orange

$list.gettype()