# ESPHome Component LD2410S

<p align="center">
    <img src="https://www.hlktech.net/res/_cache/auto/15/1575.png" width="50%"><br />
    Hi-Link LD2410S 8m mmWave Presence Sensor
</p>

This custom component is based on [PR #8486](https://github.com/esphome/esphome/pull/8486) on ESPHome. I've copied it here since I doubt it will be merged into ESPHome. There is risk that it could disappear on ESPHome and it's not setup as an external component in [NovakIrs repository](https://github.com/NovakIrs/esphome/tree/ld2410s). This PR works just fine. Again all credit goes to [NovakIrs](https://github.com/NovakIrs) repository.

I have made changes to this component. Specifically a recent update to the documentation indicates the older serial documentation may be out of date. The new documentation indicates the Threshold command now contains the Trigger and Hold Thresholds for the first 8 gates and the SNR command contains the Trigger and Hold Thresholds for the last 8 gates. The first 8 gates have a rang of 10 to 95dB and the last 8 gates have a range of 5 to 63dB. It's worth noting that the documentation implies the sensor is only good at tracking Moving AND Still targets in the first 8 gates. The last 8 gates may only work for Moving targets and possibly with dimenishing results as you get close to the last gate.

I have also made a lot of changes to make the component match the LD2410 component and to follow ESPHome guidelines. Just couldn't help myself. There are basically no changes to the serial comms and it's associated command parsing.

```yaml
external_components:
  - source:
      type: git
      url: https://github.com/mikelawrence/esphome-component-ld2410s

uart:
  - id: ld2410s_uart
    tx_pin: GPIO17
    rx_pin: GPIO18
    baud_rate: 115200
    parity: NONE
    stop_bits: 1

ld2410s:
  id: ld2410s_radar
  uart_id: ld2410s_uart
```

## Configuration Variables

* **id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **uart_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID of the UART Component to use. Required if you have multiple UARTs configured.

## Buttons

The `ld2410s` button allows you to perform `calibration start` actions on your LD2410S.

```yaml
button:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    cal_start:
      name: Calibration Start
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **cal_start** (*Optional*): When you click this button the built-in LD2410S Auto-Calibration will start. Be sure to have the room in the idle state, i.e. no people, pets or robot vaccumes running. All Options from [Button Component](https://esphome.io/components/button/#base-button-configuration).

## Binary Sensors

The `ld2410s` binary sensor `has target` and `calibration running` state information on your LD2410S.

```yaml
binary_sensor:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    has_target:
      name: MMWAVE Presence
    cal_running:
      name: Calibration Running
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **has_target** (*Optional*): When `true` the radar has detected a target either moving or still. This is effectivly presence. All Options from [Binary Sensor Component](https://esphome.io/components/binary_sensor/#base-binary-sensor-configuration).

* **calibration_running** (*Optional*): When `true` Auto-Calibration is running and `false` when not. All Options from [Binary Sensor Component](https://esphome.io/components/binary_sensor/#base-binary-sensor-configuration).

> [!NOTE]
> The has_target [Binary_Sensor](https://esphome.io/components/binary_sensor/#base-binary-sensor-configuration) above includes the following [Filter](https://https://esphome.io/components/binary_sensor/#binary-sensor-filters).
> `- settle: 1s`
> If you have defined other filters, this default will be overridden; you may of course add it back to your custom filter(s) as above if you wish.
> To remove the default filter for any given sensor instance, add `filters: []` to its configuration.

## Numbers

The `ld2410s` number platform allows you to control the gate distance, no detection delay, reporting frequency and threshold hold and threshold trigger for each gate of your LD2410S.

```yaml
number:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    max_distance:
      name: Max Detect Distance
    min_distance:
      name: Min Detect Distance
    no_delay:
      name: No detect Report Delay
    status_reporting_frequency:
      name: Status Reporting Frequency
    distance_reporting_frequency:
      name: Distance Reporting Frequency
    g0:
      trigger_threshold:
        name: G0 Trigger Threshold
      hold_threshold:
        name: G0 Hold Threshold
    g1:
      trigger_threshold:
        name: G1 Trigger Threshold
      hold_threshold:
        name: G1 Hold Threshold
    g2:
      trigger_threshold:
        name: G2 Trigger Threshold
      hold_threshold:
        name: G2 Hold Threshold
    g3:
      trigger_threshold:
        name: G3 Trigger Threshold
      hold_threshold:
        name: G3 Hold Threshold
    g4:
      trigger_threshold:
        name: G4 Trigger Threshold
      hold_threshold:
        name: G4 Hold Threshold
    g5:
      trigger_threshold:
        name: G5 Trigger Threshold
      hold_threshold:
        name: G5 Hold Threshold
    g6:
      trigger_threshold:
        name: G6 Trigger Threshold
      hold_threshold:
        name: G6 Hold Threshold
    g7:
      trigger_threshold:
        name: G7 Trigger Threshold
      hold_threshold:
        name: G7 Hold Threshold
    g8:
      trigger_threshold:
        name: G8 Trigger Threshold
      hold_threshold:
        name: G8 Hold Threshold
    g9:
      trigger_threshold:
        name: G9 Trigger Threshold
      hold_threshold:
        name: G9 Hold Threshold
    g10:
      trigger_threshold:
        name: G10 Trigger Threshold
      hold_threshold:
        name: G10 Hold Threshold
    g11:
      trigger_threshold:
        name: G11 Trigger Threshold
      hold_threshold:
        name: G11 Hold Threshold
    g12:
      trigger_threshold:
        name: G12 Trigger Threshold
      hold_threshold:
        name: G12 Hold Threshold
    g13:
      trigger_threshold:
        name: G13 Trigger Threshold
      hold_threshold:
        name: G13 Hold Threshold
    g14:
      trigger_threshold:
        name: G14 Trigger Threshold
      hold_threshold:
        name: G14 Hold Threshold
    g15:
      trigger_threshold:
        name: G15 Trigger Threshold
      hold_threshold:
        name: G15 Hold Threshold
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **max_distance_gate** (*Optional*): This is the maximum detection gate. Default is 15 with a range of 0 to 15 in steps of 1. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

* **min_distance_gate** (*Optional*): This is the minimum detection gate. Default is 0 with a range of 0 to 15 in steps of 1. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

* **no_delay** (*Optional*): This is the no detection delay. Basically a delay off function. Default is 10 seconds (s) with a range of 0 to 120s in steps of 1s. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

* **status_reporting_frequency** (*Optional*): This is `has_target` binary sensor reporting frequency. Default is 8.0Hz with a range of 0.5 to 8.0Hz. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

* **distance_reporting_frequency** (*Optional*): This is `target_distance` binary sensor reporting frequency. Default is 8.0Hz with a range of 0.5 to 8.0Hz. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

* **gX** (*Optional*): Thresholds for the Xth gate (X => 0 to 15). The gate sparation is 0.7m. Note the datsheet indicates static detection is effective only in the first 8 gates. The higher gates will still detect motion.

  * **threshold_hold** (*Optional*): This represents the threshold to which a target will no longer be detected for the given gate. Default is gate specific and range is 10 to 95dB for gates 0 - 7 and 5 to 63dB for gate 8 - 15 in steps of 1dB. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

  * **threshold_trigger** (*Optional*): Trigger Threshold detemine when the energy is enough to switch to target detected for the given gate. Default is gate specific and range is 10 to 95dB for gates 0 - 7 and 5 to 63dB for gate 8 - 15 in steps of 1dB. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

## Selects

The `ld2410s` select allows you to control the response speed of your LD2410S.

```yaml
select:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    response_speed:
      name: Response Speed
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **response_speed** (*Optional*): This is how quickly the sensor switches to no occupancy.You have two options `Normal` and `Fast`. All Options from [Select Component](https://esphome.io/components/select/#base-select-configuration).

## Sensors

The `ld2410s` sensor reports the `target distance`, `calibration progress` and gate energies for each gate of your LD2410S.

```yaml
sensor:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    cal_progress:
      name: Calibration Progress
    g0_energy:
      name: G0 Energy
    g1_energy:
      name: G1 Energy
    g2_energy:
      name: G2 Energy
    g3_energy:
      name: G3 Energy
    g4_energy:
      name: G4 Energy
    g5_energy:
      name: G5 Energy
    g6_energy:
      name: G6 Energy
    g7_energy:
      name: G7 Energy
    g8_energy:
      name: G8 Energy
    g9_energy:
      name: G9 Energy
    g10_energy:
      name: G10 Energy
    g11_energy:
      name: G11 Energy
    g12_energy:
      name: G12 Energy
    g13_energy:
      name: G13 Energy
    g14_energy:
      name: G14 Energy
    g15_energy:
      name: G15 Energy
    target_distance:
      name: Target Distance
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **cal_progress** (*Optional*): This is the current Auto-Calibration progress in perecent (%). All Options from [Sensor Component](https://esphome.io/components/sensor/#base-sensor-configuration).

* **gX energy** (*Optional*): Energies for the Xth gate (X => 0 to 15). Range is 0 to 100dB in steps of 1dB. Only operates when Minimal Output is off. All Options from [Number Component](https://esphome.io/components/number/#base-number-configuration).

* **target_distance** (*Optional*): This sensor indicates current distance to target in meters (m). All Options from [Sensor Component](https://esphome.io/components/sensor/#base-sensor-configuration).

> [!NOTE]
> Each of the [Sensor Components](https://esphome.io/components/sensor/#base-sensor-configuration) above include the following [Filter](https://esphome.io/components/sensor/#sensor-filters).
> `- throttle_with_priority: 1s`
> If you have defined other filters, this default will be overridden; you may of course add it back to your custom filter(s) as above if you wish.
> To remove the default filter for any given sensor instance, add `filters: []` to its configuration.

## Switches

The `ld2410s` switch allows to the turn on `minimal output` on your LD2410S.

```yaml
switch:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    minimal_output:
      name: Minimal Output
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **minimal_output** (*Optional*): When turned on the unit stops sending detailed target parameters like individual gate data and only streams simple presence states over the serial port . All Options from [Switch Component](https://esphome.io/components/switch/#base-switch-configuration).

## Text Sensors

The `ld2410s` text sensor reports the `firmware version` of your LD2410S.

```yaml
text_sensor:
  - platform: ld2410s
    ld2410s_id: ld2410s_radar
    fw_version:
      name: Firmware version
```

### Configuration Variables

* **ld2410s_id** (*Optional*, [ID](https://esphome.io/guides/configuration-types/#id)): Manually specify the ID for the ld2410s component. Required if there are multiple LD2410Ss configured.

* **fw_version** (*Optional*): The is the LD2410S firmware version. All Options from [Sensor Component](https://esphome.io/components/text_sensor/#base-text-sensor-configuration).
