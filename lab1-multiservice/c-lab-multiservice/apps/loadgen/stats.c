#include "stats.h"

#include <stdio.h>
#include <string.h>

void stats_header(FILE *output)
{
    fprintf(output, "request_id,backend,latency_ms,status\n");
}

int stats_record(FILE *output, int request_id, const char *response, double latency_ms)
{
    int status = 0;
    char backend[128] = "none";
    sscanf(response, "HTTP/%*d.%*d %d", &status);

    const char *header = strstr(response, "\r\nX-Backend: ");
    if (header) {
        header += strlen("\r\nX-Backend: ");
        const char *end = strstr(header, "\r\n");
        if (end && end > header && (size_t)(end - header) < sizeof(backend)) {
            memcpy(backend, header, (size_t)(end - header));
            backend[end - header] = '\0';
        }
    }

    fprintf(output, "%d,%s,%.3f,%d\n", request_id, backend, latency_ms, status);
    return status == 200;
}
