# Onify Hub containers

Here is a detailed matrix for the containers required for Onify Hub. 

> Note: Elasticseach could also be hosted outside the Onify Hub.

## List of containers and services

|                                | APP                                                  | API                                      | WORKER                                   | AGENT-SERVER                                      | ELASTICSEARCH                                           |
| ------------------------------ | ---------------------------------------------------- | ---------------------------------------- | ---------------------------------------- | ------------------------------------------------- | ------------------------------------------------------- |
| \-- DEPLOYMENT --              |                                                      |                                          |                                          |                                                   |                                                         |
| Service                        | app                                                  | api                                      | worker                                   | agent-server                                      | elasticsearch                                           |
| Ports                          | 3000                                                 | 8181                                     | n/a                                      | 8080                                              | 9200                                                    |
| Public                         | Yes                                                  | Optional                                 | n/a                                      | Yes                                               | No                                                      |
| Stateless                      | Yes                                                  | Yes                                      | Yes                                      | Yes                                               | No                                                      |
| Internet access                | No                                                   | Yes                                      | Yes                                      | No                                                | No                                                      |
| Depends on                     | api                                                  | elasticearch, agent-server               | elasticearch, agent-server               | n/a                                               | n/a                                                     |
| Pods                           | 1+                                                   | 1+                                       | 1+                                       | 1                                                 | 1                                                       |
| Source                         | Node.js                                              | Node.js                                  | Node.js                                  | Golang                                            | Java                                                    |
| DNS name                       | Yes                                                  | Optional                                 | No                                       | Yes                                               | No                                                      |
| SSL cert                       | Yes                                                  | Optional                                 | n/a                                      | Yes                                               | n/a                                                     |
| Image                          | eu.gcr.io/onify-images/hub/app:{version}             | eu.gcr.io/onify-images/hub/api:{version} | eu.gcr.io/onify-images/hub/api:{version} | eu.gcr.io/onify-images/hub/agent-server:{version} | docker.elastic.co/elasticsearch/elasticsearch:{version} |
| \-- ENVIRONMENT --             |                                                      |                                          |                                          |                                                   |                                                         |
| ES\_JAVA\_OPTS                 | n/a                                                  | n/a                                      | n/a                                      | n/a                                               | \-Xms1g -Xmx1g                                          |
| discovery.type                 | n/a                                                  | n/a                                      | n/a                                      | n/a                                               | single-node                                             |
| cluster.name                   | n/a                                                  | n/a                                      | n/a                                      | n/a                                               | onify                                                   |
| NODE\_ENV                      | production                                           | production                               | production                               | n/a                                               | n/a                                                     |
| ENV\_PREFIX                    | ONIFY\_                                              | ONIFY\_                                  | ONIFY\_                                  | n/a                                               | n/a                                                     |
| INTERPRET\_CHAR\_AS\_DOT       | \_                                                   | \_                                       | \_                                       | n/a                                               | n/a                                                     |
| ONIFY\_autoinstall             | n/a                                                  | TRUE                                     | TRUE                                     | n/a                                               | n/a                                                     |
| ONIFY\_db\_elasticsearch\_host | n/a                                                  | http://{elasticsearch}:9200              | http://{elasticsearch}:9200              | n/a                                               | n/a                                                     |
| ONIFY\_db\_indexPrefix         | n/a                                                  | onify                                    | onify                                    | n/a                                               | n/a                                                     |
| ONIFY\_client\_secret          | n/a                                                  | \*\*\*                                   | \*\*\*                                   | n/a                                               | n/a                                                     |
| ONIFY\_client\_code            | n/a                                                  | {CLIENT CODE}                            | {CLIENT CODE}                            | n/a                                               | n/a                                                     |
| ONIFY\_client\_instance        | n/a                                                  | {INSTANCE CODE}                          | {INSTANCE CODE}                          | n/a                                               | n/a                                                     |
| ONIFY\_initialLicense          | n/a                                                  | {LICENSE}                                | {LICENSE}                                | n/a                                               | n/a                                                     |
| ONIFY\_adminUser\_username     | n/a                                                  | admin                                    | admin                                    | n/a                                               | n/a                                                     |
| ONIFY\_adminUser\_password     | n/a                                                  | \*\*\*                                   | \*\*\*                                   | n/a                                               | n/a                                                     |
| ONIFY\_adminUser\_email        | n/a                                                  | noreply@onify.co                         | noreply@onify.co                         | n/a                                               | n/a                                                     |
| ONIFY\_apiTokens\_app\_secret  | n/a                                                  | \*\*\*                                   | \*\*\*                                   | n/a                                               | n/a                                                     |
| ONIFY\_resources\_baseDir      | n/a                                                  | ./data/resources                         | ./data/resources                         | n/a                                               | n/a                                                     |
| ONIFY\_resources\_tempDir      | n/a                                                  | ./data/storage                           | ./data/storage                           | n/a                                               | n/a                                                     |
| ONIFY\_websockets\_agent\_url  | n/a                                                  | ws://{agent-server}:8080/hub             | ws://{agent-server}:8080/hub             | n/a                                               | n/a                                                     |
| ONIFY\_worker\_cleanupInterval | n/a                                                  | n/a                                      | 30                                       | n/a                                               | n/a                                                     |
| ONIFY\_api\_admintoken         | Bearer {base64(app:{ONIFY\_apiTokens\_app\_secret})} | n/a                                      | n/a                                      | n/a                                               | n/a                                                     |
| ONIFY\_api\_internalUrl        | http://{api}:8181/api/v2                             | n/a                                      | n/a                                      | n/a                                               | n/a                                                     |
| ONIFY\_api\_externalUrl        | /api/v2                                              | n/a                                      | n/a                                      | n/a                                               | n/a                                                     |

### Explanation

Here we explain the meaning of the different DEPLOYMENT settings.


| What            | Meaning                                                                                        |
| --------------- | ---------------------------------------------------------------------------------------------- |
| Service         | Name of the service                                                                            |
| Ports           | What ports that are used for the container. These should be forwarded to port 80 or 443.       |
| Public          | If the container should be exposed outside the cluster.                                        |
| Stateless       | Neither reads nor stores information about its state from one time that it is run to the next. |
| Internet access | The service requires internet access. Mostly used for Git communication.                       |
| Depends on      | What other containers/services that it depends on (or links to).                               |
| Pods            | If the container can be scaled or not.                                                         |
| Source          | Source code for logging purposes.                                                              |
| DNS name        | Does the service need a seperate DNS name or not.                                              |
| SSL cert        | Does the service need a SSL certificate. Related to DNS name.                                  |
| Image           | Container (Docker) image.                                                                      |