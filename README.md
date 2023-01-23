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
