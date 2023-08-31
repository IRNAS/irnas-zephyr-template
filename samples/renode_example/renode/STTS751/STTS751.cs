//
// Copyright (c) IRNAS d.o.o.
//
// This file is licensed under the MIT License.
// Full license text is available in 'licenses/MIT.txt'.
//

// Chip documentation: https://www.st.com/en/mems-and-sensors/stts751.html#documentation

using System;
using System.Collections.Generic;
using System.Linq;
using Antmicro.Renode.Exceptions;
using Antmicro.Renode.Logging;
using Antmicro.Renode.Peripherals.I2C;
using Antmicro.Renode.Peripherals.Sensor;
using Antmicro.Renode.Core.Structure.Registers;
using Antmicro.Renode.Utilities;

namespace Antmicro.Renode.Peripherals.Sensors
{
public class STTS751 : II2CPeripheral,
		       IProvidesRegisterCollection<ByteRegisterCollection>,
		       ITemperatureSensor
{
	public STTS751()
	{
		RegistersCollection = new ByteRegisterCollection(this);
		registerAddress = 0;
		DefineRegisters();
	}

	public void Reset()
	{
		RegistersCollection.Reset();
	}

	// Must be implemented due to I2CPeripheral
	public byte[] Read(int count)
	{
		this.Log(LogLevel.Noisy, "Reading {0} bytes from register {1} (0x{1:X})", count,
			 registerAddress);
		var result = new byte[count];
		for (var i = 0; i < result.Length; i++) {
			result[i] = RegistersCollection.Read((byte)registerAddress);
			this.Log(LogLevel.Noisy, "Read value {0} from register {1} (0x{1:X})",
				 result[i], registerAddress);
		}
		return result;
	}

	// Must be implemented due to I2CPeripheral
	public void Write(byte[] data)
	{
		if (data.Length == 0) {
			this.Log(LogLevel.Warning, "Unexpected write with no data");
			return;
		}

		this.Log(LogLevel.Noisy, "Write with {0} bytes of data: {1}", data.Length,
			 Misc.PrettyPrintCollectionHex(data));
		registerAddress = (Registers)data[0];
		data = data.Skip(1).ToArray();

		InternalWrite(data);
	}

	private void InternalWrite(byte[] data)
	{
		for (var i = 0; i < data.Length; i++) {
			this.Log(LogLevel.Noisy, "Writing 0x{0:X} to register {1} (0x{1:X})",
				 data[i], registerAddress);
			RegistersCollection.Write((byte)registerAddress, data[i]);
		}
	}

	// Must be implemented due to I2CPeripheral
	public void FinishTransmission()
	{
	}

	public decimal Temperature
	{
		get => temperature;
		set {
			if (value<MinTemperature | value> MaxTemperature) {
				this.Log(LogLevel.Warning,
					 "Temperature is out of range. Supported range: {0} - {1}",
					 MinTemperature, MaxTemperature);
			} else {
				temperature = value;

				// Convert given temperature into two's complement binary fraction
				// representation The resolution register is not implemented yet.
				temperatureHighByte = (byte)Math.Abs(value);

				var decimalPart = Math.Abs(value - Decimal.Truncate(value));

				temperatureLowByte = 0;

				for (var i = 0; i < 4; i++) {
					decimalPart *= 2;

					if (decimalPart >= 1) {
						temperatureLowByte |= (byte)(1 << 3 - i);
						decimalPart -= 1;
					}
				}

				if (value < 0) {
					temperatureLowByte = (byte)~temperatureLowByte;
					temperatureHighByte = (byte)~temperatureHighByte;
					temperatureLowByte += 1;

					if (((temperatureLowByte >> 4) & 1) == 0) {
						temperatureHighByte += 1;
					}
				}

				temperatureLowByte <<= 4;
			}
		}
	}
	private string GetBinaryString(byte n)
	{
		char[] b = new char[8];
		int pos = 7;
		int i = 0;

		while (i < 8) {
			if ((n & (1 << i)) != 0) {
				b[pos] = '1';
			} else {
				b[pos] = '0';
			}
			pos--;
			i++;
		}
		return new string(b);
	}

	public ByteRegisterCollection RegistersCollection { get; }

	public float StepSize { get; set; }
	public int TemperatureResolution { get; set; }
	public bool RunMode { get; private set; }

	// https://github.com/renode/renode-infrastructure/blob/master/src/Emulator/Main/Core/Structure/Registers/PeripheralRegisterExtensions.cs
	private void DefineRegisters()
	{
		Registers.TemperatureHighByte.Define(this).WithValueField(
			0, 8, FieldMode.Read, name: "TEMP_HIGH",
			valueProviderCallback: _ => temperatureHighByte);

		Registers.Status.Define(this)
			.WithFlag(0, FieldMode.Read, name: "THERM_LIMIT",
				  valueProviderCallback: _ => false)
			.WithReservedBits(1, 4)
			.WithFlag(5, FieldMode.Read, name: "TEMP_LOW",
				  valueProviderCallback: _ => false)
			.WithFlag(6, FieldMode.Read, name: "TEMP_HIGH",
				  valueProviderCallback: _ => false)
			.WithFlag(7, FieldMode.Read, name: "BUSY",
				  valueProviderCallback: _ => false);

		Registers.TemperatureLowByte.Define(this).WithValueField(
			0, 8, FieldMode.Read, name: "TEMP_LOW",
			valueProviderCallback: _ => temperatureLowByte);

		Registers.Configuration.Define(this)
                .WithReservedBits(0, 2)
                .WithEnumField(2, 2, out outTempResolution, writeCallback: (_, __) => {
                    switch (outTempResolution.Value)
                    {
                        case TemperatureResolutionConfig.Resolution10bits:
                            StepSize = 0.25f;
                            TemperatureResolution = 10;
                            break;
                        case TemperatureResolutionConfig.Resolution11bits:
                            StepSize = 0.125f;
                            TemperatureResolution = 11;
                            break;
                        case TemperatureResolutionConfig.Resolution12bits:
                            StepSize = 0.0625f;
                            TemperatureResolution = 12;
                            break;
                        case TemperatureResolutionConfig.Resolution9bits:
                            StepSize = 0.5f;
                            TemperatureResolution = 9;
                            break;
                        default:
                            TemperatureResolution = 12;
                            StepSize = 0.0625f;
                            break;
                    }
                    this.Log(LogLevel.Noisy, "TemperatureResolution set to {0}", TemperatureResolution);
                    this.Log(LogLevel.Noisy, "Step Size set to {0}", StepSize);
                }, name: "Step size selection (Tres1:Tres0)")
                .WithReservedBits(4, 1)
                .WithTag("0", 5, 0)
                .WithFlag(6, FieldMode.Read, name: "Run/Stop", writeCallback: (_, val) => {
                    RunMode = (bool)val;
                })
                .WithTag("MASK1", 7, 0);

		Registers.ConversionRate.Define(this)
			.WithTag("CONV0", 0, 0)
			.WithTag("CONV1", 1, 0)
			.WithTag("CONV2", 2, 0)
			.WithTag("CONV3", 3, 0)
			.WithTag("CONV4", 4, 0)
			.WithTag("CONV5", 5, 0)
			.WithTag("CONV6", 6, 0)
			.WithTag("CONV7", 7, 0);

		Registers.TemperatureHighLimitHighByte.Define(this).WithValueField(
			0, 8, name: "TEMP_HIGH_LIMIT_HIGH", valueProviderCallback: _ => 0x00);

		Registers.TemperatureHighLimitLowByte.Define(this).WithValueField(
			0, 8, name: "TEMP_HIGH_LIMIT_LOW", valueProviderCallback: _ => 0x00);

		Registers.TemperatureLowLimitHighByte.Define(this).WithValueField(
			0, 8, name: "TEMP_LOW_LIMIT_HIGH", valueProviderCallback: _ => 0x00);

		Registers.TemperatureLowLimitLowByte.Define(this).WithValueField(
			0, 8, name: "TEMP_LOW_LIMIT_LOW", valueProviderCallback: _ => 0x00);

		Registers.OneShot.Define(this).WithTag("OneShot", 0, 8);

		Registers.ThermLimit.Define(this).WithValueField(0, 8, name: "THERM_LIMIT",
								 valueProviderCallback: _ => 0x0f);

		Registers.ThermHysteresis.Define(this).WithValueField(
			0, 8, name: "THERM_HYSTERESIS", valueProviderCallback: _ => 0x00);

		Registers.SMBusTimeoutEnable.Define(this).WithTag("SMBusTimeoutEnable", 0, 8);

		Registers.ProductID.Define(this).WithValueField(0, 8, name: "Product ID",
								valueProviderCallback: _ => 0x00);

		Registers.ManufacturerID.Define(this).WithValueField(
			0, 8, name: "Manufacturer ID", valueProviderCallback: _ => 0x53);

		Registers.RevisionNumber.Define(this).WithValueField(
			0, 8, name: "Revision Number", valueProviderCallback: _ => 0x01);
	}

	private decimal temperature;
	private byte temperatureLowByte;
	private byte temperatureHighByte;
	private int resolution;
	private int stepSize;
	// private UInt16 conversionConfig = TemperatureResolutionConfig.Resolution12bits;

	private IEnumRegisterField<TemperatureResolutionConfig> outTempResolution;

	private const decimal MinTemperature = -40;
	private const decimal MaxTemperature = 85;

	private Registers registerAddress;

	private enum TemperatureResolutionConfig : byte {
		Resolution10bits = 0,
		Resolution11bits = 1,
		Resolution12bits = 2,
		Resolution9bits = 3
	}

	// Register map
	private enum Registers : byte {
		TemperatureHighByte = 0x00,
		Status = 0x01,
		TemperatureLowByte = 0x02,
		Configuration = 0x03,
		ConversionRate = 0x04,
		TemperatureHighLimitHighByte = 0x05,
		TemperatureHighLimitLowByte = 0x06,
		TemperatureLowLimitHighByte = 0x07,
		TemperatureLowLimitLowByte = 0x08,
		OneShot = 0x0F,
		ThermLimit = 0x20,
		ThermHysteresis = 0x21,
		SMBusTimeoutEnable = 0x22,
		ProductID = 0xFD,
		ManufacturerID = 0xFE,
		RevisionNumber = 0xFF
	}
}
}
