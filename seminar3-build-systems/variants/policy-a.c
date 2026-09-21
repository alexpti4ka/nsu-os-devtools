#include "policy.h"
const char *policy_name(void) { return "balanced"; }
long policy_score(const TextStats *s) { return (long)s->words + (long)(10 * s->lines) + (long)s->longest_word; }
