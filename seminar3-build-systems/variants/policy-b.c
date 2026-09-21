#include "policy.h"
const char *policy_name(void) { return "word-heavy"; }
long policy_score(const TextStats *s) { return (long)(3 * s->words) + (long)s->lines + (long)s->longest_word; }
