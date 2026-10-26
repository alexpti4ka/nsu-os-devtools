#ifndef LAB_STATS_H
#define LAB_STATS_H

#include <stdio.h>

void stats_header(FILE *output);
int stats_record(FILE *output, int request_id, const char *response, double latency_ms);

#endif
