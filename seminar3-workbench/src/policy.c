#include "policy.h"

const char *policy_name(void)
{
    return "balanced";
}

long policy_score(const TextStats *stats)
{
    return (long) stats->words + (long) (10 * stats->lines) + (long) stats->longest_word;
}
