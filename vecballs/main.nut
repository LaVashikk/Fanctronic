::projectileModes <- ArrayEx()

IncludeScript("fanctronic/vecballs/blue")
IncludeScript("fanctronic/vecballs/green")
IncludeScript("fanctronic/vecballs/purple")
IncludeScript("fanctronic/vecballs/orange")
// IncludeScript("fanctronic/vecballs/red") // todo!
IncludeScript("fanctronic/vecballs/gray")

printl("Available Vecballs:")
foreach(idx, ball in projectileModes){
    dev.fprint("► {} [{}]", ball.GetName(), idx + 1)
}