/*
 * Copyright (c) 2016 Intel Corporation
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>

#include <version_info.h>

LOG_MODULE_REGISTER(main);

/* 1000 msec = 1 sec */
#define SLEEP_TIME_MS 1000

/* The devicetree node identifier for the "led0" alias. */
#define LED0_NODE DT_ALIAS(led0)

/*
 * A build error on this line means your board is unsupported.
 * See the sample documentation for information on how to fix this.
 */
static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(LED0_NODE, gpios);

int main(void)
{
	/* Print to logger */
	version_info_print();

	int err;

	if (!device_is_ready(led.port)) {
		return -1;
	}

	err = gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);
	if (err) {
		LOG_ERR("Unable to configure LED GPIO, err: %d", err);
		return -1;
	}
	int count = 0;

	while (1) {
		LOG_INF("Hello world: count %u", count++);
		err = gpio_pin_toggle_dt(&led);
		if (err) {
			LOG_ERR("Unable to toggle LED GPIO, err: %d", err);
			return -1;
		}
		k_sleep(K_MSEC(SLEEP_TIME_MS));
	}
}
