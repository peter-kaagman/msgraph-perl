# Using the MS Graph api with Perl and LWP

## Preface
Guess my brains are just to old to learn yet another programming language. For my work I need te interact with MS Graph. The no-brainer for this would be using PowerShell or Node-JS. I did manage to do some work with Node-JS using the Axios lib. But the language is just to awkward to me. I would really prefer doing this with Perl. I did do some API work with Perl on our Sonicwall firewall. Used libcurl for that. I guess a simular approach should work for MS Graph. Am making the switch to LWP because this is a more native Perl approach.

## App registration
Making daemon like scripts or running from the shell or cron I need an app registration. You can set ione up in Azure. There are lots of site on the internet who walk you through the process of making those, i.e. [Learn.microsoft.com](https://learn.microsoft.com/en-us/graph/auth-register-app-v2). You will end up with the following:

- An app_id
- An app_secret
- A tenant_id
- A graph endpoint
- A login endpoint

You will need all of them to interact with MS Graph. I'm using a configuration file groups.cfg for these.

## Curl/Bash
The most basic way of doing HTTP request that I know of would be curl from the command line. Took me a while to get that working. What I came up with in the end is the `script bash_token.sh`. I did know (but forgot at first) I had to specify a "scope" for the token request, in my case `https://graph.microsoft.com/.default`. The thing that had me going for a while was the "resource". This should be set to the graph endpoint.
The bash scipt is basicly curl requests to Graph. The first request is for the access token. The token is filtered out of the reply by using a nifty tool called [jq](https://www.baeldung.com/linux/jq-command-json), did not even know it beforehand. The second curl request uses the access token from the first request to get some actual data from Graph. You could request any data that Graph allows you, by forming the URL, to request given that you grant the proper permission in the app registration.
The [graph explorer](https://developer.microsoft.com/en-us/graph/graph-explorer) can be used to play around with the API.
## LWP
At first I started using Curl in my Perl scripts, soon to find out I'd better use [LWP](https://www.google.com/search?q=perl+lwp). Most important for me is it being pure Perl and the fact that I could find more documentation on it than for using Curl in Perl scripts ([YMMV](https://www.google.com/search?q=your+mileage+may+vary)).
## Moose
I took the opportunity to make this an OOP project. Used [Moose](https://www.google.com/search?q=perl+moose) to create a parent module (`MsGraph.pm`) which does nothing really interresting other than fetching an access token. Kinda the first line of the bash script. The modules that actually do something are `MsGroups.pm` and `MsUser.pm`. Both made for something I needed at work at the time of writing them.
## Perl
At the user level there are two script using the modules. The first I wrote is `msgraph_lwp.pl`, the second `msuser.pl`. I used the first to familiarize mysel with interacting to Graph with Perl (and learning a bit of Moose on the way). Had something to do with groups having owners or not, can't really remember what got me going. 
The `msuser.pl` script is used to find the userPrincipalName of a user by searching for his samAccountName. Must admit that the module `MsUser.pm` is tailored to that purpose. It could be more generic. But I needed this to decouple an other app I made from AD (LDAP) to use AAD (Graph) instead.
## To conclude
I share my "research" here. No guaranties are given or implied. The work is "as is", complete with all my errors, bugs and style booboos. For me it has been fun to discover the possibilities. What more can you ask for. All thanks to a lot of googling and even some question to Perl Monks. I'll problably work on it some more in the future as the need arises.
