/** @file tc_util_user_override.h
 *
 * @brief This file contains the output customization overrides for ztest.
 *
 * @note: To learn more about this see:
 * https://docs.zephyrproject.org/latest/develop/test/ztest.html#customizing-test-output
 */

#ifndef TC_UTIL_USER_OVERRIDE_H
#define TC_UTIL_USER_OVERRIDE_H

#ifdef __cplusplus
extern "C" {
#endif

#define RESET "[0m" /* Reset to default colors */

#define TEXT_BLACK "[2;30m"
#define BG_BLACK   "[24;40m"
#define BG_RED	   "[24;41m"
#define BG_GREEN   "[24;42m"
#define BG_YELLOW  "[24;43m"
#define BG_BLUE	   "[24;44m"
#define BG_MAGENTA "[24;45m"
#define BG_CYAN	   "[24;46m"
#define BG_WHITE   "[24;47m"

#define BG_BRIGHT_BLACK	  "[4;40m"
#define BG_BRIGHT_RED	  "[4;41m"
#define BG_BRIGHT_GREEN	  "[4;42m"
#define BG_BRIGHT_YELLOW  "[4;43m"
#define BG_BRIGHT_BLUE	  "[4;44m"
#define BG_BRIGHT_MAGENTA "[4;45m"
#define BG_BRIGHT_CYAN	  "[4;46m"
#define BG_BRIGHT_WHITE	  "[4;47m"

#define TC_PASS_STR BG_GREEN TEXT_BLACK "PASS" RESET
#define TC_FAIL_STR BG_RED TEXT_BLACK "FAIL" RESET
#define TC_SKIP_STR BG_YELLOW TEXT_BLACK "SKIP" RESET

#ifdef __cplusplus
}
#endif

#endif /* TC_UTIL_USER_OVERRIDE_H */
