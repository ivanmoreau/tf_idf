# tf_idf (P04 -  CCOS 264 Information retrieval)

A tool for CCOS 264 (Information retrieval). :)

Usage:

Get files from https://github.com/ivanmoreau/prep_textos

```bash
ivanmolinarebolledo@Ivans-macOS tf_idf % stack run -- --help
The tfidf program

tfidf [COMMAND] ... [OPTIONS]

Common flags:
  -? --help         Display help message
  -V --version      Print version information

tfidf matrix [OPTIONS]

  -f --from=ITEM  
  -t --to=ITEM    

tfidf query [OPTIONS]

  -o --ogfile=ITEM
  -m --matrix=ITEM
  -q --query=ITEM 
ivanmolinarebolledo@Ivans-macOS boolean_model % 
```

Grammar
```bash
Query -> a
a -> o ("and" o)*
o -> term ("or" term)*
term -> "not" Query | "(" Query ")" | Identifier
Identifier -> alphaNum (alphaNum | "'")* 
```


Query examples:

```bash
ivanmolinarebolledo@Ivans-macOS tf_idf % stack run -- query -o="Tweets.txt" -m="mm.ths" -q="cama or museo"        
[13] @LuisGcortez tweeted: Parece que falta algo de atención y mantenimiento al museo de la ciudad por parte del @ICAdifusion http://t.co/FLbC5SbcoF (W: 8.45532722030456)
[201] @JaAC9510 tweeted: Hoy me niego a levantarme de mi cama (W: 7.455327220304562)
[16] @yosoyloagui tweeted: Tu y yo juntos en un lugar perfectollamado mi cama *.* (W: 7.455327220304562)

ivanmolinarebolledo@Ivans-macOS tf_idf % stack run -- query -o="Tweets.txt" -m="mm.ths" -q="(invito and not carnal) or novio"
[186] @Andresrgtz tweeted: Mi amiga se besó a una mujer muy sexi el fin de semana no le digan a su novio (W: 6.870364719583405)
[49] @KarlyyRG tweeted: Nada mejor que tener un novio super divertido que en lugar de limitarte, te sigue el pedo. (W: 6.870364719583405)
[42] @KarlyyRG tweeted: Lo que mas me encanta de mi novio es que me hace morir de risa. (W: 6.870364719583405)

ivanmolinarebolledo@Ivans-macOS tf_idf % stack run -- query -o="Tweets.txt" -m="mm.ths" -q="vida and riesgo or dios"
[206] @alex_dsr01 tweeted: Ni pedo la vida es un riesgo -Fergus (W: 8.45532722030456)
[345] @CaballoNegroII tweeted: RT @MyRyCaR: Gracias por tu presencia en mi vida...un regalo de Dios 😆 teee amooo @CaballoNegroII http://t.co/grQRS43NK1 (W: 6.133399125417199)
[203] @abrilushiZ tweeted: RT @_equiswe: Si Dios me quita la vida antes que a ti... (W: 6.133399125417199)

ivanmolinarebolledo@Ivans-macOS tf_idf % stack run -- query -o="Tweets.txt" -m="mm.ths" -q="tortillas or hambre or feliz"
[69] @PiernasAlLomo tweeted: @La_Montserrat a las tortillas? (W: 8.45532722030456)
[27] @IAN_BLACK26 tweeted: Mitad de quincena que comiencen los juegos del hambre. (W: 7.455327220304562)
[14] @mc_gabucha tweeted: Ahora entiendo por que se juntó la necesidad con el hambre... ¡Que gente tan acomplejada! (W: 7.455327220304562)
[325] @123anotaz tweeted: RT @CarlaMorrAgs: La mujer es una obra de arte que ilumina los ojos de quien la mira. Feliz Dia de la Mujer @CarlaMorrisonmx ♥ (W: 6.455327220304562)
[265] @fantasmaluigui tweeted: Siempre recuerda: No tomes decisiones cuando estés enojado, y no hagas promesas cuando estés feliz. (W: 6.455327220304562)
[236] @nichelopezc tweeted: Hoy ni la pizza me hace feliz carajo!!\' (W: 6.455327220304562)
[109] @zubyelynl tweeted: Hola feliz domingo tengan tod@s hoy les presento esta capa o poncho que se puede usar tanto en temporada de frio... http://t.co/qh1xeinf22 (W: 6.455327220304562)

ivanmolinarebolledo@Ivans-macOS tf_idf % stack run -- query -o="Tweets.txt" -m="mm.ths" -q="amiga and novio"
[186] @Andresrgtz tweeted: Mi amiga se besó a una mujer muy sexi el fin de semana no le digan a su novio (W: 6.870364719583405)
```