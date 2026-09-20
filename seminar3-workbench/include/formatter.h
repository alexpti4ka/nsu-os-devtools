#ifndef FORMATTER_H
#define FORMATTER_H

#include "textstat.h"

void formatter_print(const char *path, const TextStats *stats, long score, const char *policy);

#endif
