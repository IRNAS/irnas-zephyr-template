#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/shell/shell.h>
#include <zephyr/shell/shell_uart.h>

#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

static struct gpio_callback prv_gpio_cb;
static struct gpio_dt_spec prv_gpio_int = GPIO_DT_SPEC_GET(DT_PATH(inputs, gpio_int), gpios);

/**
 * @brief Prints "pong" to the shell.
 */
static int cmd_ping(const struct shell *shell, size_t argc, char **argv)
{
	shell_print(shell, "pong");
	return 0;
}

SHELL_CMD_REGISTER(ping, NULL, "ping", cmd_ping);

static void prv_interrupt_handler(const struct device *dev, struct gpio_callback *cb, uint32_t pin)
{
	shell_print(shell_backend_uart_get_ptr(), "GPIO Interrupt fired\n\n\n");
}

static void prv_configure_interrupt_gpio(struct gpio_callback *gpio_cb,
					 const struct gpio_dt_spec *gpio)
{
	__ASSERT(device_is_ready(gpio->port), "GPIO for interrupt not ready");

	int rc = gpio_pin_configure_dt(gpio, GPIO_INPUT);
	__ASSERT(!rc, "failed to configure gpio_int pin %d (err=%d)", gpio->pin, rc);

	/* Prepare GPIO callback for interrupt pin */
	gpio_init_callback(gpio_cb, prv_interrupt_handler, BIT(gpio->pin));

	rc = gpio_add_callback(gpio->port, gpio_cb);
	__ASSERT(!rc, "failed to add callback (err=%d)", rc);

	rc = gpio_pin_interrupt_configure_dt(gpio, GPIO_INT_EDGE_TO_ACTIVE);
	__ASSERT(!rc, "failed to configure attn_p_gpio pin %d as interrupt (err=%d)", rc);
}

int main(void)
{
	prv_configure_interrupt_gpio(&prv_gpio_cb, &prv_gpio_int);

	return 0;
}
