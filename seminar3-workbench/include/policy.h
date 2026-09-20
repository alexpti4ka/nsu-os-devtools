#ifndef POLICY_H
#define POLICY_H

#include "textstat.h"

const char *policy_name(void);
long policy_score(const TextStats *stats);

#endif
