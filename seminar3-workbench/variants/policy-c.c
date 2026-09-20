#include "policy.h"
const char *policy_name(void) { return "compact"; }
long policy_score(const TextStats *s) { return (long)s->characters - (long)s->words + (long)s->longest_word; }
