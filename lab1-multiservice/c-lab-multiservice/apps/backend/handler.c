#include "handler.h"
#include "http.h"

#include <stdio.h>

void backend_handle(int client, const char *server_name)
{
    int request = http_read_request(client);
    if (request == 0)
        return;
    if (request < 0) {
        http_send_response(client, 400, server_name, "Bad request\n");
        return;
    }

    char body[256];
    snprintf(body, sizeof(body), "Hello from %s\n", server_name);
    http_send_response(client, 200, server_name, body);
}
