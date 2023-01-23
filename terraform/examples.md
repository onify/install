Example of onify functions:
This function will be replaces in the namespace "client_code+client_instance" so it´s important that the client has been deployed first. 

```
module "function-whoami" {
 source = "github.com/onify/terraform//modules/onify-functions" // Source for Terraform modules
 name = "function-whoami"
 image = "containous/whoami"   //example image url
 port = 80
 public = true
 tls = "staging"   // staging och prod
 external-dns-domain = "onify.net"
 client_code = "oni"
 client_instance = "demo1"
 envs = {
  SOMETHING = "ANYTHING"
 }
}
```
