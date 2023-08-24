#include <example_lib.h>

#include <zephyr/ztest.h>

ZTEST_SUITE(sample_test_suite, NULL, NULL, NULL, NULL, NULL);

ZTEST(sample_test_suite, test_example_1)
{
	zassert_equal(1, 1, "1 should be equal to 1");
}

ZTEST(sample_test_suite, test_example_2)
{
	zassert_not_equal(1, 0, "1 should not be equal to 0");
}

ZTEST(sample_test_suite, test_example_lib)
{
	int result = example_lib_calculate(true, 1, 1);

	zassert_equal(2, result, "Result should be equal to 1, but is %d", result);

	/* We are intentionally not testing example_lib_calculate(false, x, y); so that we can
	 * demonstrate branch coverage in coverage report.
	 */
}
