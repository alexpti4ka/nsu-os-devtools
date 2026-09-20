#include <string.h>
#include <unistd.h>
#include "policy.h"

int main(void)
{
    TextStats stats = { .lines = 2, .words = 3, .characters = 17, .longest_word = 5 };
    if (strcmp(policy_name(), "balanced") != 0) return 1;
    if (policy_score(&stats) != 28) return 1;
    sleep(2);
    return 0;
}
