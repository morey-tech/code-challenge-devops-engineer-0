# Known Issues

- `POST` requests to the `/api` endpoints fail when deployed to Kubernetes and accessing it with an `Origin` header not set to `http://localhost:4200` (i.e. when accessing it through a nodeport or ingress).
  - Request generated in Firefox when using the UI fails with `NS_BINDING_ABORTED`. The equivelent `curl` is:
    ```
    $ curl 'http://kanban.example/api/kanbans/' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' --compressed -H 'Referer: http://kanban.example/' -H 'Content-Type: application/json' -H 'Origin: http://kanban.example' -H 'DNT: 1' -H 'Connection: keep-alive' --data-raw '{"title":"test-from-curl"}'
    Invalid CORS request
    ```
    - Removing the Origin header `-H 'Origin: http://kanban.example'` resolved the issue.
    - May be related to expected URL/base domain configuration within the application.
    - When testing from Firefox, the `kanban-ui` log does not print a log entry for the hit, indicating that it doesn't make it to the application (fails in the client browser).
  - When deployed with `docker-compose`, the `curl` command with the `Origin` header works fine, but the browser (Firefox) still does not.
    ```
    $ curl 'http://localhost:4200/api/kanbans/' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' --compressed -H 'Referer: http://localhost:4200/' -H 'Content-Type: application/json' -H 'Origin: http://localhost:4200' -H 'DNT: 1' -H 'Connection: keep-alive' --data-raw '{"title":"test-from-curl"}'
    {"id":16,"title":"test-from-curl","tasks":null}
    ```
    - This could confirm my guess that it's an issue with the hardcoded baseURL/domain values in the application code. Since if the Origin is not set to `http://localhost:4200` it fails with `Invalid CORS request`.
    - The `kanban-ui` logs the following on the failed request:
      ```
      kanban-ui          | 172.23.0.1 - - [21/Jul/2021:16:53:56 +0000] "POST /api/kanbans/ HTTP/1.1" 403 20 "http://localhost:4200/" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:85.0) Gecko/20100101 Firefox/85.0" "-"
      ```
    - It works fine from Chrome. Equivelent curl command:
      ```
      $ curl 'http://localhost:4200/api/kanbans/' \
        -H 'Connection: keep-alive' \
        -H 'Pragma: no-cache' \
        -H 'Cache-Control: no-cache' \
        -H 'sec-ch-ua: " Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"' \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'sec-ch-ua-mobile: ?0' \
        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36' \
        -H 'Content-Type: application/json' \
        -H 'Origin: http://localhost:4200' \
        -H 'Sec-Fetch-Site: same-origin' \
        -H 'Sec-Fetch-Mode: cors' \
        -H 'Sec-Fetch-Dest: empty' \
        -H 'Referer: http://localhost:4200/' \
        -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
        --data-raw '{"title":"w35w35tw"}' \
        --compressed
      ```
  - When connecting from Chrome to the Helm chart deployed `kanban-ui` the POST request returns `403`. Equivelnet curl:
    ```
    $ curl 'http://192.168.49.2:30107/api/kanbans/' \
      >   -H 'Connection: keep-alive' \
      >   -H 'Pragma: no-cache' \
      >   -H 'Cache-Control: no-cache' \
      >   -H 'Accept: application/json, text/plain, */*' \
      >   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.164 Safari/537.36' \
      >   -H 'Content-Type: application/json' \
      >   -H 'Origin: http://192.168.49.2:30107' \
      >   -H 'Referer: http://192.168.49.2:30107/' \
      >   -H 'Accept-Language: en-GB,en-US;q=0.9,en;q=0.8' \
      >   --data-raw '{"title":"235wq5wa5t"}' \
      >   --compressed \
      >   --insecure
    Invalid CORS request
    ```
    - Updating the `Origin` header to `http://localhost:4200` makes it work. Issue is definetly related to the hardcoded baseURL/domain values.